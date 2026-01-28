-- --------------------------------------------------------------------
-- Creating Databse
CREATE DATABASE customer_seg;
USE customer_seg;
SHOW TABLES;
-- --------------------------------------------------------------------

-- PART 1 — DATA AUDIT & QUALITY CHECKS
-- 1.1 Row, order & customer counts
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_customers
FROM ecommerce_orders;

-- 1.2 Duplicate orders
SELECT order_id, COUNT(*) AS cnt
FROM ecommerce_orders
GROUP BY order_id
HAVING cnt > 1;

-- 1.3 Revenue correctness
SELECT *
FROM ecommerce_orders
WHERE ROUND(price * qty, 2) <> ROUND(total_price, 2);

-- 1.4 Null checks
SELECT *
FROM ecommerce_orders
WHERE user_id IS NULL
   OR order_date IS NULL
   OR total_price IS NULL;
-- --------------------------------------------------------------------

-- PART 2 — EXPLORATORY BUSINESS METRICS
-- 2.1 Total revenue
SELECT ROUND(SUM(total_price), 2) AS total_revenue
FROM ecommerce_orders;

-- 2.2 Revenue by country
SELECT
    country,
    ROUND(SUM(total_price), 2) AS revenue
FROM ecommerce_orders
GROUP BY country
ORDER BY revenue DESC;

-- 2.3 Revenue by category
SELECT
    category,
    ROUND(SUM(total_price), 2) AS revenue
FROM ecommerce_orders
GROUP BY category
ORDER BY revenue DESC;
-- --------------------------------------------------------------------

-- PART 3 — CUSTOMER FACT TABLE
-- 3.1 Create customer metrics view
CREATE OR REPLACE VIEW customer_metrics AS
SELECT
    user_id,
    COUNT(DISTINCT order_id) AS order_count,
    ROUND(SUM(total_price), 2) AS total_spend,
    ROUND(AVG(total_price), 2) AS avg_order_value,
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM ecommerce_orders
GROUP BY user_id;

-- 3.2 Customer lifespan (days)
SELECT
    user_id,
    DATEDIFF(last_order_date, first_order_date) AS customer_lifetime_days
FROM customer_metrics;
-- -----------------------------------------------------------------------

-- PART 4 — WINDOW FUNCTIONS 
-- 4.1 Spend ranking
SELECT
    user_id,
    total_spend,
    RANK() OVER (ORDER BY total_spend DESC) AS spend_rank
FROM customer_metrics;

-- 4.2 Spend percentile
SELECT
    user_id,
    total_spend,
    PERCENT_RANK() OVER (ORDER BY total_spend) AS spend_percentile
FROM customer_metrics;
-- -----------------------------------------------------------------------

-- PART 5 — ADVANCED CUSTOMER SEGMENTATION
-- 5.1 Percentile-based dynamic segmentation
CREATE OR REPLACE VIEW customer_segments AS
SELECT
    user_id,
    order_count,
    total_spend,
    avg_order_value,
    CASE
        WHEN spend_percentile >= 0.90 THEN 'Platinum'
        WHEN spend_percentile >= 0.70 THEN 'Gold'
        WHEN spend_percentile >= 0.40 THEN 'Silver'
        ELSE 'Bronze'
    END AS derived_segment
FROM (
    SELECT
        user_id,
        order_count,
        total_spend,
        avg_order_value,
        PERCENT_RANK() OVER (ORDER BY total_spend) AS spend_percentile
    FROM customer_metrics
) t;

SELECT derived_segment, COUNT(*) 
FROM customer_segments 
GROUP BY derived_segment;

-- -----------------------------------------------------------------------
-- PART 6 — SEGMENT PERFORMANCE SUMMARY
SELECT
    derived_segment,
    COUNT(*) AS customers,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(AVG(order_count), 2) AS avg_orders
FROM customer_segments
GROUP BY derived_segment
ORDER BY avg_spend DESC;
-- ---------------------------------------------------------------------

-- PART 7 — RFM ANALYSIS 
SELECT
    user_id,
    DATEDIFF(CURDATE(), MAX(order_date)) AS recency_days,
    COUNT(order_id) AS frequency,
    ROUND(SUM(total_price), 2) AS monetary
FROM ecommerce_orders
GROUP BY user_id;
-- --------------------------------------------------------------------

-- PART 8 — RETENTION & LOYALTY
-- 8.1 One-time vs repeat customers
SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS customers
FROM customer_metrics
GROUP BY customer_type;

-- 8.2 Repeat purchase rate
SELECT
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*), 2
    ) AS repeat_rate_percentage
FROM customer_metrics;
-- -------------------------------------------------------------------

-- PART 9 — TIME SERIES & COHORT-LIKE ANALYSIS
-- 9.1 Monthly revenue
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    ROUND(SUM(total_price), 2) AS revenue
FROM ecommerce_orders
GROUP BY month
ORDER BY month;

-- 9.2 Monthly active customers
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(DISTINCT user_id) AS active_customers
FROM ecommerce_orders
GROUP BY month
ORDER BY month;
-- ---------------------------------------------------------------------

-- PART 10 — POWER ANALYTICS
-- 10.1 Top 10% customers revenue share
SELECT
    ROUND(SUM(total_spend), 2) AS revenue_from_top_10_percent
FROM (
    SELECT
        user_id,
        SUM(total_price) AS total_spend,
        NTILE(10) OVER (ORDER BY SUM(total_price) DESC) AS bucket
    FROM ecommerce_orders
    GROUP BY user_id
) t
WHERE bucket = 1;
-- -----------------------------------------------------------------------

-- PART 11 — CATEGORY × SEGMENT MATRIX
SELECT
    cs.derived_segment,
    eo.category,
    ROUND(SUM(eo.total_price), 2) AS revenue
FROM ecommerce_orders eo
JOIN customer_segments cs
  ON eo.user_id = cs.user_id
GROUP BY cs.derived_segment, eo.category
ORDER BY cs.derived_segment, revenue DESC;
-- ---------------------------------------------------------------------

-- PART 12 — PERFORMANCE OPTIMIZATION
-- customer lookup
CREATE INDEX idx_user_id ON ecommerce_orders(user_id);
-- time-based analysis
 CREATE INDEX idx_order_date ON ecommerce_orders(order_date);
-- category analytics
CREATE INDEX idx_category ON ecommerce_orders(category(50));

SELECT * FROM customer_segments;
-- -------------------------------------------------------------------------

-- Customer Metrics Query
-- Purpose: proves total spend & order count
SELECT * FROM customer_metrics;

-- Segmentation Logic
-- Show derived segments (Bronze/Silver/Gold/Platinum)
SELECT * FROM customer_segments;

-- Segment Summary
-- Proves segment size summary
SELECT derived_segment, COUNT(*) As Count
FROM customer_segments 
GROUP BY derived_segment;
-- --------------------------------------------------------------------------------

-- Validate Segment Distribution
SELECT
    derived_segment,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM customer_segments
GROUP BY derived_segment;

-- Compare Old vs Derived Segments 
SELECT
    customer_segment AS original_segment,
    derived_segment,
    COUNT(*) AS customers
FROM ecommerce_orders eo
JOIN customer_segments cs
  ON eo.user_id = cs.user_id
GROUP BY original_segment, derived_segment;

-- Query to show “Gold and Platinum customers contribute most revenue.”
SELECT
    derived_segment,
    ROUND(SUM(total_spend), 2) AS total_revenue
FROM customer_segments
GROUP BY derived_segment
ORDER BY total_revenue DESC;

-- Create Final Table
CREATE TABLE final_customer_segments AS 
SELECT * FROM customer_segments
limit 10000;

select * from final_customer_segments
limit 10000;

-- --------------------------------------------------------------------------------------------

SELECT * FROM ecommerce_orders LIMIT 10;

SELECT * FROM customer_metrics LIMIT 10;

SELECT
    derived_segment,
    COUNT(*) AS customers,
    ROUND(AVG(total_spend),2) AS avg_spend
FROM customer_segments
GROUP BY derived_segment;

SELECT DATE_FORMAT(order_date,'%Y-%m') AS month, SUM(total_price)
FROM ecommerce_orders
GROUP BY month;

SELECT user_id,
       DATEDIFF(CURDATE(), MAX(order_date)) AS recency,
       COUNT(order_id) AS frequency,
       SUM(total_price) AS monetary
FROM ecommerce_orders
GROUP BY user_id;



