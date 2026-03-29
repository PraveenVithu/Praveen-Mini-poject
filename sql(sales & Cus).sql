create database prj;
use prj;
CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_city VARCHAR(50),
    customer_state VARCHAR(10)
);

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_purchase_timestamp TIMESTAMP
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    price DECIMAL(10,2)
);
drop table customers;
CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(50),
    customer_state VARCHAR(10)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cus.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
select * from customers;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp VARCHAR(50),
    order_approval_at VARCHAR(50),
    order_delivered_carrier_date VARCHAR(50),
    order_delivered_customer_date VARCHAR(50),
    order_estimated_delivery_date VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@order_id, @customer_id, @status, @purchase, @approval, @carrier, @delivered, @estimated)
SET
order_id = @order_id,
customer_id = @customer_id,
order_status = @status,
order_purchase_timestamp = @purchase,
order_approval_at = @approval,
order_delivered_carrier_date = @carrier,
order_delivered_customer_date = @delivered,
order_estimated_delivery_date = @estimated;
select * from orders;

DROP TABLE IF EXISTS order_items;
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date VARCHAR(50),
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/oritem.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from order_items;
SELECT 
    o.order_id,
    SUM(oi.price + oi.freight_value) AS total_order_value
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.order_id;



#REVENUE
SELECT SUM(price + freight_value) AS total_revenue
FROM order_items;
#Revenue Per Order
SELECT 
    order_id,
    SUM(price + freight_value) AS order_value
FROM order_items
GROUP BY order_id
ORDER BY order_value DESC;
#order+items
SELECT 
    o.order_id,
    o.customer_id,
    SUM(oi.price + oi.freight_value) AS total_order_value
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.order_id, o.customer_id;
#Monthly Revenue
SELECT 
    DATE_FORMAT(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m') AS month,
    SUM(oi.price + oi.freight_value) AS revenue
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;
#Top customer
SELECT 
    o.customer_id,
    SUM(oi.price + oi.freight_value) AS total_spent
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC
LIMIT 10;
#Top 5 order
SELECT 
    o.order_id,
    SUM(oi.price + oi.freight_value) AS total_value
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY total_value DESC
LIMIT 5;
#Customers by Spending
SELECT 
    o.customer_id,
    SUM(oi.price + oi.freight_value) AS total_spent,
    RANK() OVER (ORDER BY SUM(oi.price + oi.freight_value) DESC) AS rank_no
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.customer_id;
#top 5 customer
SELECT *
FROM (
    SELECT 
        o.customer_id,
        SUM(oi.price + oi.freight_value) AS total_spent,
        RANK() OVER (ORDER BY SUM(oi.price + oi.freight_value) DESC) AS rank_no
    FROM orders o
    JOIN order_items oi 
    ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) t
WHERE rank_no <= 5;
#Cumulative Revenue
SELECT 
    DATE_FORMAT(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m') AS month,
    SUM(oi.price + oi.freight_value) AS revenue,
    SUM(SUM(oi.price + oi.freight_value)) 
    OVER (ORDER BY DATE_FORMAT(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m')) 
    AS cumulative_revenue
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY month;
#Row no unique rank
SELECT 
    o.customer_id,
    SUM(oi.price + oi.freight_value) AS total_spent,
    ROW_NUMBER() OVER (ORDER BY SUM(oi.price + oi.freight_value) DESC) AS row_num
FROM orders o
JOIN order_items oi 
ON o.order_id = oi.order_id
GROUP BY o.customer_id;