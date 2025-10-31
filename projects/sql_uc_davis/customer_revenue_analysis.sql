/*
==========================================
PROJECT: Customer Revenue & Retention Analysis
AUTHOR: Muazu Siaka
TOOLS: MySQL / SQLite
DESCRIPTION:
    This project analyzes customer spending, sales performance, and retention trends.
    It demonstrates SQL joins, aggregations, subqueries, and window functions.
==========================================
*/

-- =========================
-- 1. Create tables
-- =========================

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    customer_name TEXT,
    region TEXT,
    signup_date DATE
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    total_amount REAL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    category TEXT,
    price REAL
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =========================
-- 2. Insert sample data
-- =========================

INSERT INTO customers VALUES
(1, 'Ama Mensah', 'Greater Accra', '2022-01-15'),
(2, 'Kwame Boateng', 'Ashanti', '2022-03-10'),
(3, 'Efua Osei', 'Central', '2022-05-05'),
(4, 'Kojo Adjei', 'Northern', '2022-07-12'),
(5, 'Akosua Owusu', 'Eastern', '2022-09-20');

INSERT INTO products VALUES
(1, 'Electronics', 350.00),
(2, 'Home Appliances', 120.00),
(3, 'Fashion', 60.00),
(4, 'Groceries', 20.00),
(5, 'Sports', 180.00);

INSERT INTO orders VALUES
(101, 1, '2022-02-10', 470.00),
(102, 2, '2022-03-25', 240.00),
(103, 3, '2022-05-18', 80.00),
(104, 1, '2022-06-01', 320.00),
(105, 4, '2022-07-15', 150.00),
(106, 2, '2022-09-10', 400.00),
(107, 5, '2022-10-02', 200.00),
(108, 1, '2022-11-25', 150.00),
(109, 3, '2022-12-18', 110.00),
(110, 5, '2023-01-20', 360.00);

INSERT INTO order_details VALUES
(1, 101, 1, 1),
(2, 101, 2, 1),
(3, 102, 4, 3),
(4, 103, 3, 1),
(5, 104, 1, 1),
(6, 105, 5, 1),
(7, 106, 2, 2),
(8, 107, 3, 2),
(9, 108, 4, 5),
(10, 109, 1, 1),
(11, 110, 5, 2);

-- =========================
-- 3. Business Insights Queries
-- =========================

-- A. Top 5 customers by lifetime value (LTV)
SELECT 
    c.customer_name,
    c.region,
    SUM(o.total_amount) AS lifetime_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_name, c.region
ORDER BY lifetime_value DESC
LIMIT 5;

-- B. Total revenue per region
SELECT 
    c.region,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY total_revenue DESC;

-- C. Monthly revenue trend
SELECT 
    STRFTIME('%Y-%m', order_date) AS month,
    ROUND(SUM(total_amount), 2) AS monthly_revenue
FROM orders
GROUP BY STRFTIME('%Y-%m', order_date)
ORDER BY month;

-- D. Returning customers (made >1 purchase)
SELECT 
    c.customer_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- E. Customers inactive for >90 days since last order
SELECT 
    c.customer_name,
    MAX(o.order_date) AS last_order_date,
    JULIANDAY('2023-04-01') - JULIANDAY(MAX(o.order_date)) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name
HAVING days_since_last_order > 90;

-- F. Revenue share by product category
SELECT 
    p.category,
    ROUND(SUM(p.price * od.quantity), 2) AS category_revenue,
    ROUND(100.0 * SUM(p.price * od.quantity) / (SELECT SUM(total_amount) FROM orders), 1) AS percent_share
FROM order_details od
JOIN products p ON od.product_id = p.product_id
JOIN orders o ON o.order_id = od.order_id
GROUP BY p.category
ORDER BY category_revenue DESC;

-- =========================
-- 4. Extra Challenge (Window Function)
-- =========================
-- Rank customers by total spend
SELECT 
    c.customer_name,
    ROUND(SUM(o.total_amount), 2) AS total_spent,
    RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS spend_rank
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name;
