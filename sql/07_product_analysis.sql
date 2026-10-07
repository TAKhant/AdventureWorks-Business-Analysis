-- 01. Category Performance
SELECT 
    dp.category,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.total_product_cost) AS total_cost,
    SUM(fs.sales_amount - fs.total_product_cost) AS total_profit,
    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct,
    SUM(fs.order_quantity) AS units_sold
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_key = dp.product_key
GROUP BY dp.category
ORDER BY total_sales DESC;

-- 02 Subcategory Performance
SELECT 
    dp.subcategory,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.total_product_cost) AS total_cost,
    SUM(fs.sales_amount - fs.total_product_cost) AS total_profit,
    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct,
    SUM(fs.order_quantity) AS units_sold
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_key = dp.product_key
GROUP BY dp.subcategory
ORDER BY total_sales DESC;

-- 03 Lowest Profit By Product
SELECT 
    pd.product AS product_name,
    pd.category AS category,
    pd.subcategory AS subcategory,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.sales_amount - fs.total_product_cost) AS total_profit,
    SUM(fs.order_quantity) AS units_sold
FROM fact_sales fs
JOIN dim_product pd
    ON fs.product_key = pd.product_key
GROUP BY product_name, category, subcategory
ORDER BY total_profit
LIMIT 10;

-- 04. Highest Profit By Product
SELECT 
    pd.product AS product_name,
    pd.category AS category,
    pd.subcategory AS subcategory,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.sales_amount - fs.total_product_cost) AS total_profit,
    SUM(fs.order_quantity) AS units_sold
FROM fact_sales fs
JOIN dim_product pd
    ON fs.product_key = pd.product_key
GROUP BY product_name, category, subcategory
ORDER BY total_profit DESC
LIMIT 10;

-- 03 and 04 Findings : The highest-revenue product is not the highest-profit product, 
-- although both belong to the Bikes category

-- 05. Product Profit Margin Analysis
-- 5.1 Highest profit margin percentage
SELECT
    dp.product AS product_name,
    dp.category AS category,
    dp.subcategory AS subcategory,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.sales_amount - fs.total_product_cost) AS total_profit,
    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales fs
JOIN dim_product dp 
    ON fs.product_key = dp.product_key
GROUP BY product_name, category, subcategory
ORDER BY profit_margin_pct DESC
LIMIT 10;


-- 5.2 Lowest profit margin percentage
SELECT
    dp.product AS product_name,
    dp.category AS category,
    dp.subcategory AS subcategory,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.sales_amount - fs.total_product_cost) AS total_profit,
    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct
FROM fact_sales fs
JOIN dim_product dp 
    ON fs.product_key = dp.product_key
GROUP BY product_name, category, subcategory
ORDER BY profit_margin_pct ASC
LIMIT 10;

/*
AWC Logo Cap sold 8,311 units, making it a high-volume product, 
but it generated a profit margin of -2.35%. 
This means the product is loss-making despite strong demand, 
suggesting that its pricing, product cost, or discounting should be investigated.
*/

-- 06 Revenue Concentration Top 5 Product
WITH product_sales AS (
    SELECT
        dp.product AS product_name,
        SUM(fs.sales_amount) AS total_sales
    FROM fact_sales fs
    JOIN dim_product dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.product
),

top_5_products AS (
    SELECT
        product_name,
        total_sales
    FROM product_sales
    ORDER BY total_sales DESC
    LIMIT 5
),

company_sales AS (
    SELECT
        SUM(sales_amount) AS total_company_sales
    FROM fact_sales
)

SELECT
    ROUND(SUM(t.total_sales), 2) AS top_5_revenue,
    ROUND(c.total_company_sales, 2) AS total_company_revenue,
    ROUND(
        SUM(t.total_sales)
        / NULLIF(c.total_company_sales, 0) * 100,
        2
    ) AS top_5_revenue_pct
FROM top_5_products t
CROSS JOIN company_sales c
GROUP BY c.total_company_sales;

-- 07. Profit Concentration - Top 5 Products

WITH product_profit AS (
    SELECT
        dp.product AS product_name,
        SUM(fs.sales_amount - fs.total_product_cost) AS total_profit
    FROM fact_sales fs
    JOIN dim_product dp
        ON fs.product_key = dp.product_key
    GROUP BY dp.product
),

top_5_products AS (
    SELECT
        product_name,
        total_profit
    FROM product_profit
    ORDER BY total_profit DESC
    LIMIT 5
),

company_profit AS (
    SELECT
        SUM(sales_amount - total_product_cost) AS total_company_profit
    FROM fact_sales
)

SELECT
    ROUND(SUM(t.total_profit), 2) AS top_5_profit,
    ROUND(c.total_company_profit, 2) AS total_company_profit,
    ROUND(
        SUM(t.total_profit)
        / NULLIF(c.total_company_profit, 0) * 100,
        2
    ) AS top_5_profit_pct
FROM top_5_products t
CROSS JOIN company_profit c
GROUP BY c.total_company_profit;

-- 08. Product Performance Over Time
-- Compare full years only: 2018 vs 2019

SELECT
    EXTRACT(YEAR FROM d.date) AS year,
    dp.category,
    dp.subcategory,
    SUM(fs.sales_amount) AS total_sales,
    SUM(fs.sales_amount - fs.total_product_cost) AS total_profit,
    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct,
    SUM(fs.order_quantity) AS units_sold

FROM fact_sales fs

JOIN dim_product dp
    ON fs.product_key = dp.product_key

JOIN dim_date d
    ON fs.order_date_key = d.date_key

WHERE EXTRACT(YEAR FROM d.date) IN (2018, 2019)

GROUP BY
    EXTRACT(YEAR FROM d.date),
    dp.category,
    dp.subcategory

ORDER BY
    year,
    total_sales DESC;