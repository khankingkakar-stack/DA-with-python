/*
    ASSIGNMENT 10 — Group By & Subqueries
    Database: BikeStores
    Student Name: Waleed Khan
    SQL Server (T-SQL)

    Run each query separately in SQL Server Management Studio (SSMS).
*/

USE BikeStores;
GO

-- ============================================================
-- Question 1 — Aggregate Functions
-- ============================================================

SELECT
    COUNT(*) AS total_order_lines,
    SUM(quantity) AS total_units_sold,
    AVG(list_price) AS average_list_price,
    MIN(list_price) AS minimum_list_price,
    MAX(list_price) AS maximum_list_price
FROM sales.order_items;
GO


-- ============================================================
-- Question 2 — COUNT(*) vs COUNT(column)
-- ============================================================

-- Part a: Total number of customer rows
SELECT
    COUNT(*) AS total_customers
FROM sales.customers;
GO

-- Part b: Customers with an email and phone number on record
SELECT
    COUNT(email) AS customers_with_email,
    COUNT(phone) AS customers_with_phone
FROM sales.customers;
GO

-- Part c: Calculate customers with no phone using the counts above.
-- Also confirm the result directly with IS NULL.
-- After running Part (a) and Part (b), add the actual results
-- to the comments below; values depend on the database contents.
-- Total customers: ______
-- Customers with phone: ______
-- Customers with NO phone: ______

SELECT
    COUNT(*) AS customers_without_phone
FROM sales.customers
WHERE phone IS NULL;
GO


-- ============================================================
-- Question 3 — GROUP BY
-- ============================================================

-- Part a: Total units sold for each product
SELECT
    product_id,
    SUM(quantity) AS total_units_sold
FROM sales.order_items
GROUP BY product_id
ORDER BY total_units_sold DESC;
GO

-- Part b: Number of customers in each state
SELECT
    state,
    COUNT(*) AS customer_count
FROM sales.customers
GROUP BY state
ORDER BY customer_count DESC;
GO

-- Part c: Orders handled by each staff member and order status
SELECT
    staff_id,
    order_status,
    COUNT(*) AS order_count
FROM sales.orders
GROUP BY
    staff_id,
    order_status
ORDER BY
    staff_id,
    order_status;
GO


-- ============================================================
-- Question 4 — GROUP BY with Joins
-- ============================================================

-- Part a: Average product price in each category
SELECT
    c.category_name,
    ROUND(AVG(p.list_price), 2) AS average_list_price
FROM production.categories AS c
INNER JOIN production.products AS p
    ON c.category_id = p.category_id
GROUP BY
    c.category_id,
    c.category_name
ORDER BY c.category_name;
GO

-- Part b: Number of products in each brand
SELECT
    b.brand_name,
    COUNT(p.product_id) AS product_count
FROM production.brands AS b
LEFT JOIN production.products AS p
    ON b.brand_id = p.brand_id
GROUP BY
    b.brand_id,
    b.brand_name
ORDER BY product_count DESC;
GO

-- Part c: Every customer, including customers with no orders
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    COALESCE(
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)),
        0
    ) AS total_spent
FROM sales.customers AS c
LEFT JOIN sales.orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY c.customer_id;
GO


-- ============================================================
-- Question 5 — HAVING
-- ============================================================

-- Part a: Model years with more than 50 products
SELECT
    model_year,
    COUNT(*) AS product_count
FROM production.products
GROUP BY model_year
HAVING COUNT(*) > 50
ORDER BY model_year;
GO

-- Part b: Customers who placed 2 or more orders
SELECT
    customer_id,
    COUNT(*) AS order_count
FROM sales.orders
GROUP BY customer_id
HAVING COUNT(*) >= 2
ORDER BY order_count DESC;
GO

-- Part c: Products with more than 100 units sold
SELECT
    product_id,
    SUM(quantity) AS total_units_sold
FROM sales.order_items
GROUP BY product_id
HAVING SUM(quantity) > 100
ORDER BY total_units_sold DESC;
GO

-- Part d:
-- WHERE filters individual rows before GROUP BY is performed.
-- Part (a) depends on COUNT(*) for each model_year group.
-- Aggregate results are calculated after grouping, so the
-- condition COUNT(*) > 50 must be written with HAVING, not WHERE.
GO


-- ============================================================
-- Question 6 — WHERE + GROUP BY + HAVING Together
-- ============================================================

SELECT
    o.store_id,
    SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM sales.orders AS o
INNER JOIN sales.order_items AS oi
    ON o.order_id = oi.order_id
WHERE YEAR(o.order_date) = 2017
GROUP BY o.store_id
HAVING SUM(oi.quantity * oi.list_price * (1 - oi.discount)) > 100000
ORDER BY total_revenue DESC;
GO


-- ============================================================
-- Question 7 — Subquery in WHERE (IN)
-- ============================================================

-- Part a: Orders placed by customers living in New York
SELECT
    *
FROM sales.orders
WHERE customer_id IN (
    SELECT customer_id
    FROM sales.customers
    WHERE city = 'New York'
);
GO

-- Part b: Products in Electric Bikes or Cruisers Bicycles
SELECT
    product_id,
    product_name
FROM production.products
WHERE category_id IN (
    SELECT category_id
    FROM production.categories
    WHERE category_name IN ('Electric Bikes', 'Cruisers Bicycles')
);
GO

-- Part c: Customers who have placed at least one order
SELECT
    first_name,
    last_name,
    city
FROM sales.customers
WHERE customer_id IN (
    SELECT customer_id
    FROM sales.orders
);
GO


-- ============================================================
-- Question 8 — Subquery in WHERE (Scalar & NOT IN)
-- ============================================================

-- Part a: Products priced above the overall average
SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE list_price > (
    SELECT AVG(list_price)
    FROM production.products
)
ORDER BY list_price DESC;
GO

-- Part b: Products priced below the overall average
SELECT
    product_id,
    product_name,
    list_price
FROM production.products
WHERE list_price < (
    SELECT AVG(list_price)
    FROM production.products
)
ORDER BY list_price ASC;
GO

-- Part b: Count of products priced below the overall average
SELECT
    COUNT(*) AS products_below_average
FROM production.products
WHERE list_price < (
    SELECT AVG(list_price)
    FROM production.products
);
GO

-- Part c: Customers who have never placed an order
SELECT
    customer_id,
    first_name,
    last_name
FROM sales.customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM sales.orders
    WHERE customer_id IS NOT NULL
);
GO

-- Part d: Products that have never been ordered
SELECT
    product_id,
    product_name
FROM production.products
WHERE product_id NOT IN (
    SELECT product_id
    FROM sales.order_items
    WHERE product_id IS NOT NULL
);
GO


-- ============================================================
-- Question 9 — Subquery in FROM (Derived Table)
-- ============================================================

-- Part a: Average, minimum and maximum order count per staff member.
-- The LEFT JOIN includes staff members who have handled zero orders.
SELECT
    AVG(CAST(staff_order_counts.order_count AS DECIMAL(10, 2)))
        AS average_order_count,
    MIN(staff_order_counts.order_count) AS minimum_order_count,
    MAX(staff_order_counts.order_count) AS maximum_order_count
FROM (
    SELECT
        s.staff_id,
        COUNT(o.order_id) AS order_count
    FROM sales.staffs AS s
    LEFT JOIN sales.orders AS o
        ON s.staff_id = o.staff_id
    GROUP BY s.staff_id
) AS staff_order_counts;
GO

-- Part b: Average total spending across all customers,
-- including customers who have spent zero.
SELECT
    AVG(customer_spending.total_spent) AS average_total_spent
FROM (
    SELECT
        c.customer_id,
        COALESCE(
            SUM(oi.quantity * oi.list_price * (1 - oi.discount)),
            0
        ) AS total_spent
    FROM sales.customers AS c
    LEFT JOIN sales.orders AS o
        ON c.customer_id = o.customer_id
    LEFT JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) AS customer_spending;
GO


-- ============================================================
-- Question 10 — Subquery in SELECT
-- ============================================================

-- Part a: Total quantity sold for each product (correlated subquery)
SELECT
    p.product_id,
    p.product_name,
    p.list_price,
    (
        SELECT COALESCE(SUM(oi.quantity), 0)
        FROM sales.order_items AS oi
        WHERE oi.product_id = p.product_id
    ) AS units_sold
FROM production.products AS p
ORDER BY p.product_id;
GO

-- Part b: Item count and highest item price for each order
SELECT
    o.order_id,
    o.order_date,
    (
        SELECT COUNT(*)
        FROM sales.order_items AS oi
        WHERE oi.order_id = o.order_id
    ) AS item_count,
    (
        SELECT MAX(oi.list_price)
        FROM sales.order_items AS oi
        WHERE oi.order_id = o.order_id
    ) AS max_item_price
FROM sales.orders AS o
ORDER BY o.order_id;
GO

-- Part c: Difference between each product price and overall average
SELECT
    product_id,
    product_name,
    list_price,
    list_price - (
        SELECT AVG(list_price)
        FROM production.products
    ) AS price_difference
FROM production.products
ORDER BY product_id;
GO


-- ============================================================
-- Question 11 — Challenge
-- Customers whose total spending is above the average spending
-- across all customers, including customers with zero spending.
-- ============================================================

SELECT
    customer_spending.customer_id,
    customer_spending.first_name,
    customer_spending.last_name,
    customer_spending.total_spent
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(
            SUM(oi.quantity * oi.list_price * (1 - oi.discount)),
            0
        ) AS total_spent
    FROM sales.customers AS c
    LEFT JOIN sales.orders AS o
        ON c.customer_id = o.customer_id
    LEFT JOIN sales.order_items AS oi
        ON o.order_id = oi.order_id
    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
) AS customer_spending
WHERE customer_spending.total_spent > (
    SELECT AVG(all_customer_spending.total_spent)
    FROM (
        SELECT
            c.customer_id,
            COALESCE(
                SUM(oi.quantity * oi.list_price * (1 - oi.discount)),
                0
            ) AS total_spent
        FROM sales.customers AS c
        LEFT JOIN sales.orders AS o
            ON c.customer_id = o.customer_id
        LEFT JOIN sales.order_items AS oi
            ON o.order_id = oi.order_id
        GROUP BY c.customer_id
    ) AS all_customer_spending
)
ORDER BY customer_spending.total_spent DESC;
GO
