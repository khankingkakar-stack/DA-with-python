/*
===============================================================================
ASSIGNMENT 09 | JOINS & GROUP BY
Author: Waleed Khan
Database: BikeStores
Platform: Microsoft SQL Server (T-SQL)

Topics:
  INNER JOIN | LEFT JOIN | RIGHT JOIN | FULL OUTER JOIN
  Multi-table joins | Aggregate functions | GROUP BY | HAVING

How to run:
  1. Open SQL Server Management Studio (SSMS).
  2. Connect to your SQL Server instance.
  3. Open the BikeStores database.
  4. Execute this script, or run one question at a time.
===============================================================================
*/

USE BikeStores;
GO

/*=============================================================================
  QUESTION 1 - INNER JOIN
  Return product name, brand name, and list price.
  Sort by brand ascending and price descending.
=============================================================================*/
SELECT
    p.product_name,
    b.brand_name,
    p.list_price
FROM production.products AS p
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
ORDER BY
    b.brand_name ASC,
    p.list_price DESC;
GO

/*=============================================================================
  QUESTION 2 - JOINING THREE TABLES
  Return product, brand, category, and model year for products priced above
  1000.
=============================================================================*/
SELECT
    p.product_name,
    b.brand_name,
    c.category_name,
    p.model_year
FROM production.products AS p
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id
WHERE p.list_price > 1000;
GO

/*=============================================================================
  QUESTION 3A - LEFT JOIN
  Show every customer, including customers who have never placed an order.
=============================================================================*/
SELECT
    c.first_name,
    c.last_name,
    c.city,
    o.order_id,
    o.order_date
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
ORDER BY
    c.last_name,
    c.first_name,
    o.order_date;
GO

/*-----------------------------------------------------------------------------
  QUESTION 3B - CUSTOMERS WITHOUT ORDERS
  A NULL order_id identifies customers with no matching order.
-----------------------------------------------------------------------------*/
SELECT
    c.first_name,
    c.last_name,
    c.city
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY
    c.last_name,
    c.first_name;
GO

/*=============================================================================
  QUESTION 4A - RIGHT JOIN
  Show every store, even if no staff member is assigned to it.
=============================================================================*/
SELECT
    s.store_name,
    st.first_name,
    st.last_name
FROM sales.staffs AS st
RIGHT JOIN sales.stores AS s
    ON st.store_id = s.store_id
ORDER BY
    s.store_name,
    st.last_name,
    st.first_name;
GO

/*=============================================================================
  QUESTION 4B - FULL OUTER JOIN
  Find products with no matching stock record.
  The FULL OUTER JOIN is used as requested; filtering on the stock-side key
  isolates products without a stock row.
=============================================================================*/
SELECT
    p.product_name,
    stk.quantity
FROM production.products AS p
FULL OUTER JOIN production.stocks AS stk
    ON p.product_id = stk.product_id
WHERE stk.product_id IS NULL
ORDER BY
    p.product_name;
GO

/*=============================================================================
  QUESTION 5 - MULTI-TABLE ORDER DETAIL REPORT
  Calculate each line total after discount.
=============================================================================*/
SELECT
    o.order_id,
    o.order_date,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_full_name,
    p.product_name,
    oi.quantity,
    CAST(
        oi.quantity * oi.list_price * (1.0 - oi.discount)
        AS DECIMAL(12, 2)
    ) AS line_total
FROM sales.orders AS o
INNER JOIN sales.customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
ORDER BY
    o.order_id,
    p.product_name;
GO

/*=============================================================================
  QUESTION 6 - AGGREGATE FUNCTIONS
  Return product count, minimum, maximum, and average list price.
=============================================================================*/
SELECT
    COUNT(*) AS total_products,
    MIN(list_price) AS lowest_list_price,
    MAX(list_price) AS highest_list_price,
    CAST(ROUND(AVG(list_price), 2) AS DECIMAL(12, 2)) AS average_list_price
FROM production.products;
GO

/*=============================================================================
  QUESTION 7A - GROUP BY CATEGORY
  LEFT JOIN also keeps categories that currently have zero products.
=============================================================================*/
SELECT
    c.category_name,
    COUNT(p.product_id) AS product_count
FROM production.categories AS c
LEFT JOIN production.products AS p
    ON c.category_id = p.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY
    product_count DESC,
    c.category_name ASC;
GO

/*=============================================================================
  QUESTION 7B - AVERAGE PRICE BY BRAND AND MODEL YEAR
=============================================================================*/
SELECT
    b.brand_name,
    p.model_year,
    CAST(ROUND(AVG(p.list_price), 2) AS DECIMAL(12, 2)) AS average_list_price
FROM production.products AS p
INNER JOIN production.brands AS b
    ON p.brand_id = b.brand_id
GROUP BY
    b.brand_id,
    b.brand_name,
    p.model_year
ORDER BY
    b.brand_name ASC,
    p.model_year ASC;
GO

/*=============================================================================
  QUESTION 8A - ORDER COUNT PER CUSTOMER
  LEFT JOIN includes customers with zero orders.
=============================================================================*/
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.order_id) AS total_orders
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    total_orders DESC,
    c.customer_id ASC;
GO

/*=============================================================================
  QUESTION 8B - TOTAL REVENUE PER STORE
  LEFT JOIN includes stores with no orders; COALESCE displays zero revenue.
=============================================================================*/
SELECT
    s.store_name,
    CAST(
        COALESCE(
            SUM(oi.quantity * oi.list_price * (1.0 - oi.discount)),
            0
        )
        AS DECIMAL(14, 2)
    ) AS total_revenue
FROM sales.stores AS s
LEFT JOIN sales.orders AS o
    ON s.store_id = o.store_id
LEFT JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    s.store_id,
    s.store_name
ORDER BY
    total_revenue DESC,
    s.store_name ASC;
GO

/*=============================================================================
  QUESTION 9A - HAVING
  Find brands with more than 20 products.
=============================================================================*/
SELECT
    b.brand_name,
    COUNT(p.product_id) AS total_products
FROM production.brands AS b
INNER JOIN production.products AS p
    ON b.brand_id = p.brand_id
GROUP BY
    b.brand_id,
    b.brand_name
HAVING COUNT(p.product_id) > 20
ORDER BY
    total_products DESC,
    b.brand_name ASC;
GO

/*=============================================================================
  QUESTION 9B - CUSTOMERS WITH THREE OR MORE ORDERS
=============================================================================*/
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    COUNT(o.order_id) AS total_orders
FROM sales.customers AS c
INNER JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING COUNT(o.order_id) >= 3
ORDER BY
    total_orders DESC,
    full_name ASC;
GO

/*=============================================================================
  QUESTION 9C - WHERE VS HAVING
=============================================================================*/
-- WHERE filters individual rows BEFORE GROUP BY and aggregation.
-- HAVING filters grouped results AFTER GROUP BY and is commonly used
-- with aggregate expressions such as COUNT(), SUM(), and AVG().

 /*=============================================================================
  QUESTION 10 - COMBINED CHALLENGE
  Top five products by quantity sold, considering completed orders only.
=============================================================================*/
SELECT TOP (5)
    p.product_name,
    c.category_name,
    SUM(oi.quantity) AS total_quantity_sold,
    CAST(
        SUM(oi.quantity * oi.list_price * (1.0 - oi.discount))
        AS DECIMAL(14, 2)
    ) AS total_revenue
FROM sales.order_items AS oi
INNER JOIN sales.orders AS o
    ON oi.order_id = o.order_id
INNER JOIN production.products AS p
    ON oi.product_id = p.product_id
INNER JOIN production.categories AS c
    ON p.category_id = c.category_id
WHERE o.order_status = 4
GROUP BY
    p.product_id,
    p.product_name,
    c.category_id,
    c.category_name
ORDER BY
    total_quantity_sold DESC,
    total_revenue DESC,
    p.product_name ASC;
GO

/*
===============================================================================
END OF ASSIGNMENT 09
===============================================================================
*/
