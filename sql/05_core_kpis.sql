-- 01. Total Sales
SELECT
    SUM(sales_amount) AS total_sales
FROM fact_sales;


-- 02. Total Product Cost
SELECT
    SUM(total_product_cost) AS total_cost
FROM fact_sales;


-- 03. Total Profit
SELECT
    SUM(sales_amount - total_product_cost) AS total_profit
FROM fact_sales;


-- 04. Profit Margin
SELECT
    ROUND(
        (SUM(sales_amount - total_product_cost)
        / SUM(sales_amount)) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales;


-- 05. Total Orders
SELECT
    COUNT(DISTINCT dso.sales_order) AS total_orders
FROM fact_sales fs
JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key;


-- 06. Units Sold
SELECT
    SUM(order_quantity) AS units_sold
FROM fact_sales;


-- 07. Number of Internet Customers
SELECT
    COUNT(DISTINCT fs.customer_key) AS internet_customers
FROM fact_sales fs
JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key
WHERE dso.channel = 'Internet';


-- 08. Number of Active Resellers
SELECT
    COUNT(DISTINCT fs.reseller_key) AS active_resellers
FROM fact_sales fs
JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key
WHERE dso.channel = 'Reseller';


-- 09. Average Order Value
WITH order_totals AS (
    SELECT
        dso.sales_order,
        SUM(fs.sales_amount) AS order_value
    FROM fact_sales fs
    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key
    GROUP BY dso.sales_order
)
SELECT
    ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;