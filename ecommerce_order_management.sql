/*
PROJECT TITLE:
E-Commerce Order Management System

PROJECT DESCRIPTION:
This project simulates a real-world e-commerce 
database system serving customers.
It manages customers, products, categories,
orders, order items, and payments.

OBJECTIVE:
- Design relational database schema
- Implement Primary & Foreign Keys
- Perform JOIN operations
- Apply GROUP BY and Aggregations
- Generate business-focused insights

SKILLS USED:
- SQL
- Relational Database Design
- Data Analysis using SQL
- Business Intelligence Queries
*/

-- DATABASE CREATION

CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- TABLE CREATION

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    city VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    amount DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- DATA INSERTION

INSERT INTO Categories (category_name) VALUES
('Electronics'),
('Clothing'),
('Home & Kitchen'),
('Books'),
('Sports'),
('Groceries');

INSERT INTO Customers (name, email, city) VALUES
('Raghavendra Rao', 'raghu@gmail.com', 'Bangalore'),
('Shreya Gowda', 'shreya@gmail.com', 'Mysuru'),
('Manjunath Hegde', 'manju@gmail.com', 'Hubballi'),
('Nithya Shetty', 'nithya@gmail.com', 'Mangaluru'),
('Prakash Kumar', 'prakash@gmail.com', 'Belagavi'),
('Kavitha Rao', 'kavitha@gmail.com', 'Shivamogga'),
('Darshan Naik', 'darshan@gmail.com', 'Udupi'),
('Sneha Patil', 'sneha@gmail.com', 'Davanagere'),
('Vikram Reddy', 'vikram@gmail.com', 'Kalaburagi'),
('Ananya Iyer', 'ananya@gmail.com', 'Bangalore');

INSERT INTO Products (product_name, price, category_id) VALUES
('OnePlus 12', 64999, 1),
('Realme Smart TV', 38999, 1),
('Mysore Silk Saree', 7999, 2),
('Cotton Kurti', 1299, 2),
('Mixer Grinder', 3499, 3),
('Cookware Set', 4599, 3),
('Data Science with Python Book', 699, 4),
('Cricket Bat', 1499, 5),
('Yoga Mat', 799, 5),
('Coorg Filter Coffee Powder', 599, 6);

INSERT INTO Orders (customer_id, status) VALUES
(1, 'Delivered'),
(2, 'Delivered'),
(3, 'Pending'),
(4, 'Delivered'),
(5, 'Cancelled'),
(1, 'Delivered'),
(6, 'Pending'),
(7, 'Delivered'),
(8, 'Delivered'),
(9, 'Pending');

INSERT INTO Order_Items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 64999),
(1, 3, 1, 7999),
(2, 2, 1, 38999),
(3, 7, 1, 699),
(4, 4, 2, 1299),
(6, 5, 1, 3499),
(7, 8, 1, 1499),
(8, 9, 2, 799),
(9, 10, 3, 599),
(10, 6, 1, 4599);

INSERT INTO Payments (order_id, payment_method, payment_status, amount) VALUES
(1, 'Credit Card', 'Success', 72998),
(2, 'UPI', 'Success', 38999),
(3, 'Credit Card', 'Pending', 699),
(4, 'Debit Card', 'Success', 2598),
(6, 'UPI', 'Success', 3499),
(7, 'Credit Card', 'Pending', 1499),
(8, 'UPI', 'Success', 1598),
(9, 'Debit Card', 'Success', 1797),
(10, 'Credit Card', 'Success', 4599);

-- BUSINESS ANALYSIS QUERIES

-- Show Orders with Customer Names

SELECT 
    o.order_id,
    c.name,
    o.order_date,
    o.status
FROM Orders o
INNER JOIN Customers c 
ON o.customer_id = c.customer_id;



-- Full Order Details (4-Table JOIN)

SELECT 
    o.order_id,
    c.name AS customer_name,
    p.product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total_price
FROM Order_Items oi
INNER JOIN Orders o ON oi.order_id = o.order_id
INNER JOIN Customers c ON o.customer_id = c.customer_id
INNER JOIN Products p ON oi.product_id = p.product_id;



-- Total Revenue Per Order

SELECT 
    order_id,
    SUM(quantity * price) AS total_order_value
FROM Order_Items
GROUP BY order_id;



-- Total Business Revenue

SELECT 
    SUM(quantity * price) AS total_revenue
FROM Order_Items;

-- Top 3 Customers by Total Spending

SELECT 
    c.name,
    SUM(oi.quantity * oi.price) AS total_spent
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 3;

-- Top Selling Products (By Quantity)

SELECT 
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM Products p
INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC;

-- Most Used Payment Method

SELECT 
    payment_method,
    COUNT(*) AS usage_count
FROM Payments
WHERE payment_status = 'Success'
GROUP BY payment_method
ORDER BY usage_count DESC;

-- Customers With No Orders

SELECT 
    c.name
FROM Customers c
LEFT JOIN Orders o 
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;


-- Customers Spending Above Average

SELECT name, total_spent
FROM (
    SELECT 
        c.name,
        SUM(oi.quantity * oi.price) AS total_spent
    FROM Customers c
    INNER JOIN Orders o ON c.customer_id = o.customer_id
    INNER JOIN Order_Items oi ON o.order_id = oi.order_id
    GROUP BY c.name
) AS customer_totals
WHERE total_spent > (
    SELECT AVG(total_spent)
    FROM (
        SELECT SUM(oi.quantity * oi.price) AS total_spent
        FROM Orders o
        INNER JOIN Order_Items oi ON o.order_id = oi.order_id
        GROUP BY o.customer_id
    ) AS avg_table
);


-- Products Never Ordered

SELECT product_name
FROM Products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id
    FROM Order_Items
);

-- Highest Single Order Value

SELECT order_id, total_order_value
FROM (
    SELECT 
        order_id,
        SUM(quantity * price) AS total_order_value
    FROM Order_Items
    GROUP BY order_id
) AS order_totals
WHERE total_order_value = (
    SELECT MAX(total_value)
    FROM (
        SELECT SUM(quantity * price) AS total_value
        FROM Order_Items
        GROUP BY order_id
    ) AS max_table
);


-- Customers With More Than One Order

SELECT c.name, COUNT(o.order_id) AS order_count
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name
HAVING COUNT(o.order_id) > 1;

-- Monthly Revenue

SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS month,
    SUM(oi.quantity * oi.price) AS monthly_revenue
FROM Orders o
INNER JOIN Order_Items oi 
ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- Revenue by Category

SELECT 
    c.category_name,
    SUM(oi.quantity * oi.price) AS category_revenue
FROM Categories c
INNER JOIN Products p ON c.category_id = p.category_id
INNER JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY c.category_name
ORDER BY category_revenue DESC;


/*
====================================================
BUSINESS INSIGHT SUMMARY
====================================================

1. Total Revenue:
   The platform generates revenue from multiple product categories,
   with Electronics contributing significantly to overall sales.

2. Customer Insights:
   A small group of customers contribute the highest revenue,
   indicating potential for loyalty programs or targeted marketing.

3. Product Performance:
   Certain products show higher sales volume,
   helping identify top-performing inventory.

4. Monthly Revenue Trend:
   Revenue analysis by month enables tracking of business growth
   and seasonal demand patterns.

5. Payment Analysis:
   Successful payment methods can be analyzed to optimize
   payment options and improve transaction success rate.

CONCLUSION:
This project demonstrates relational database design,
multi-table joins, aggregations, subqueries, and
business-focused SQL analytics suitable for
real-world e-commerce systems.
====================================================
*/