# 📊 Customer Segmentation & Analytics using MySQL

## 📌 Project Overview

This project demonstrates **customer segmentation** and **business analytics** using MySQL on an e-commerce dataset. The primary goal is to analyze customer purchase behavior, calculate key customer metrics, and segment customers into meaningful tiers for business decision-making.

In addition to basic segmentation, the project implements **advanced, percentile-based loyalty tiers** (Bronze, Silver, Gold, Platinum) derived dynamically from customer spending.

---

## 🛠️ Technologies Used

- **MySQL** - Database management and queries
- **MySQL Workbench** - Development environment
- **SQL** - Views, Window Functions, Indexes for analytics

---

## 📂 Dataset Description

The dataset represents e-commerce order transactions and includes:

- `order_id`, `user_id`
- Product details (category, price, quantity)
- Order date
- Country
- Predefined customer value segment (Low-Value, Mid-Value, High-Value)

Customer information is embedded within the orders table for simplified analysis.

---

## 🎯 Project Objectives

- ✅ Import and analyze e-commerce order data
- ✅ Calculate customer-level metrics:
  - Total spend
  - Order count
  - Average order value
- ✅ Segment customers using spend-based percentiles
- ✅ Compare predefined customer segments with derived loyalty tiers
- ✅ Summarize segment-level performance metrics
- ✅ Optimize query performance using indexing

---

## 🧱 Database Design

| Component | Name |
|-----------|------|
| **Database** | `customer_seg` |
| **Main Table** | `ecommerce_orders` |
| **Analytical Views** | `customer_metrics`, `customer_spend`, `customer_tiers` |
| **Final Output** | `final_customer_segments` |

---

## 🔍 Key Analysis & Features

### 1️⃣ Customer Metrics

A reusable view is created to calculate:

- Total spend per customer
- Order frequency
- Average order value
- First and last purchase dates
- Customer lifetime (days)

This forms the foundation for all segmentation logic.

---

### 2️⃣ Dual Customer Segmentation (Core Enhancement)

This project supports **two types** of customer segmentation:

#### 🔹 Value-Based Segment (Existing Data)

- **Low-Value**
- **Mid-Value**
- **High-Value**

These represent basic customer value labels available in the raw dataset.

#### 🔹 Loyalty-Based Tier Segment (Derived)

Using percentile-based spending, customers are dynamically classified into:

| Tier | Spend Percentile |
|------|------------------|
| **Platinum** | Top 10% |
| **Gold** | 70% – 90% |
| **Silver** | 40% – 70% |
| **Bronze** | Bottom 40% |

This segmentation adapts automatically to the data distribution and avoids hard-coded thresholds.

---

### 3️⃣ Enriched Orders Dataset

Customer loyalty tiers are joined back to the orders table, resulting in an enriched dataset containing:

- Transaction details
- Value-based segment
- Loyalty-based tier segment

This enables flexible analysis for marketing, retention, and revenue insights.

---

### 4️⃣ Segment Performance Summary

For each loyalty tier:

- Number of customers
- Average total spend
- Average order count
- Revenue contribution

This highlights how **Gold and Platinum customers** drive a large share of revenue.

---

### 5️⃣ Additional Analytics

- 📈 **RFM analysis** (Recency, Frequency, Monetary)
- 📊 Monthly revenue trends
- 👥 Monthly active customers
- 🛍️ Category × segment revenue analysis

---

### 6️⃣ Performance Optimization

Indexes are created on frequently queried columns:

- `user_id`
- `order_date`
- `category`

This improves performance for analytical and aggregation queries.

---

## 📤 Deliverables

- ✅ SQL script for database setup and analysis
- ✅ Customer metrics and segmentation views
- ✅ Final customer segmentation table
- ✅ Exportable CSV of customer segments
- ✅ Screenshots demonstrating query outputs and results

---

## 💡 Business Use Cases

- 🎯 Identify high-value and loyal customers
- 📧 Design targeted marketing campaigns
- 🔄 Improve customer retention strategies
- 💰 Analyze revenue concentration across customer tiers

---

## 🚀 How to Run the Project

1. **Create the database** in MySQL:
   ```sql
   CREATE DATABASE customer_seg;
   USE customer_seg;
   ```

2. **Import the dataset** into `ecommerce_orders` table

3. **Execute the SQL scripts** in order:
   - Schema creation
   - Data import
   - Views and analysis queries
   - Segmentation logic

4. **Query analytical views** for insights

5. **Export final segmentation results** if required

---

## 📊 Sample Queries

### Get Customer Metrics
```sql
SELECT * FROM customer_metrics 
ORDER BY total_spend DESC 
LIMIT 10;
```

### View Loyalty Tiers Distribution
```sql
SELECT loyalty_tier, 
       COUNT(*) as customer_count,
       AVG(total_spend) as avg_spend
FROM customer_tiers
GROUP BY loyalty_tier;
```

### Segment Performance Summary
```sql
SELECT segment, 
       COUNT(DISTINCT user_id) as customers,
       SUM(total_spend) as total_revenue,
       AVG(order_count) as avg_orders
FROM final_customer_segments
GROUP BY segment;
```

---

## 📁 Project Structure

```
customer-segmentation-mysql/
│
├── README.md
├── Customer-Segmentation-MySQL/
│   ├── schema.sql              # Database and table creation
│   ├── analysis.sql            # Analytical queries
│   ├── segmentation.sql        # Customer segmentation logic
│   └── screenshots/            # Query output examples
└── data/
    └── ecommerce_orders.csv    # Sample dataset
```

---


