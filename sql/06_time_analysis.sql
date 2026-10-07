-- ============================================================
-- 06_TIME_ANALYSIS.SQL
-- Business Question:
-- How did AdventureWorks sales and profitability change over time?
-- ============================================================


-- ============================================================
-- 01. CHECK DATA COVERAGE
-- Important before comparing years
-- ============================================================

SELECT
    EXTRACT(YEAR FROM d.date) AS year,
    MIN(d.date) AS first_order_date,
    MAX(d.date) AS last_order_date,
    COUNT(DISTINCT DATE_TRUNC('month', d.date)) AS months_available
FROM fact_sales fs
JOIN dim_date d
    ON fs.order_date_key = d.date_key
GROUP BY EXTRACT(YEAR FROM d.date)
ORDER BY year;



-- ============================================================
-- 02. YEARLY PERFORMANCE
-- Sales, Cost, Profit, Margin and Units
-- ============================================================

SELECT
    EXTRACT(YEAR FROM d.date) AS year,

    SUM(fs.sales_amount) AS total_sales,

    SUM(fs.total_product_cost) AS total_cost,

    SUM(
        fs.sales_amount - fs.total_product_cost
    ) AS total_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct,

    SUM(fs.order_quantity) AS units_sold

FROM fact_sales fs

JOIN dim_date d
    ON fs.order_date_key = d.date_key

GROUP BY EXTRACT(YEAR FROM d.date)

ORDER BY year;



-- ============================================================
-- 03. MONTHLY PERFORMANCE
-- Includes Sales, Profit, Margin, Units and Orders
-- ============================================================

SELECT
    DATE_TRUNC('month', d.date) AS month,

    SUM(fs.sales_amount) AS total_sales,

    SUM(fs.total_product_cost) AS total_cost,

    SUM(
        fs.sales_amount - fs.total_product_cost
    ) AS total_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct,

    SUM(fs.order_quantity) AS units_sold,

    COUNT(DISTINCT dso.sales_order) AS total_orders

FROM fact_sales fs

JOIN dim_date d
    ON fs.order_date_key = d.date_key

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

GROUP BY DATE_TRUNC('month', d.date)

ORDER BY month;



-- ============================================================
-- 04. MONTH-OVER-MONTH SALES GROWTH
-- Compare each month against the previous month
-- ============================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', d.date) AS month,
        SUM(fs.sales_amount) AS total_sales

    FROM fact_sales fs

    JOIN dim_date d
        ON fs.order_date_key = d.date_key

    GROUP BY DATE_TRUNC('month', d.date)
),

monthly_growth AS (

    SELECT
        month,
        total_sales,

        LAG(total_sales)
        OVER (ORDER BY month) AS previous_month_sales

    FROM monthly_sales
)

SELECT
    month,
    total_sales,
    previous_month_sales,

    ROUND(
        (
            total_sales - previous_month_sales
        )
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS mom_growth_pct

FROM monthly_growth

ORDER BY month;



-- ============================================================
-- 05. LARGEST MONTH-OVER-MONTH INCREASE
-- ============================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', d.date) AS month,
        SUM(fs.sales_amount) AS total_sales

    FROM fact_sales fs

    JOIN dim_date d
        ON fs.order_date_key = d.date_key

    GROUP BY DATE_TRUNC('month', d.date)
),

monthly_growth AS (

    SELECT
        month,
        total_sales,

        LAG(total_sales)
        OVER (ORDER BY month) AS previous_month_sales

    FROM monthly_sales
)

SELECT
    month,
    total_sales,
    previous_month_sales,

    ROUND(
        (
            total_sales - previous_month_sales
        )
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS mom_growth_pct

FROM monthly_growth

WHERE previous_month_sales IS NOT NULL

ORDER BY mom_growth_pct DESC

LIMIT 1;



-- ============================================================
-- 06. LARGEST MONTH-OVER-MONTH DECLINE
-- ============================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', d.date) AS month,
        SUM(fs.sales_amount) AS total_sales

    FROM fact_sales fs

    JOIN dim_date d
        ON fs.order_date_key = d.date_key

    GROUP BY DATE_TRUNC('month', d.date)
),

monthly_growth AS (

    SELECT
        month,
        total_sales,

        LAG(total_sales)
        OVER (ORDER BY month) AS previous_month_sales

    FROM monthly_sales
)

SELECT
    month,
    total_sales,
    previous_month_sales,

    ROUND(
        (
            total_sales - previous_month_sales
        )
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS mom_growth_pct

FROM monthly_growth

WHERE previous_month_sales IS NOT NULL

ORDER BY mom_growth_pct ASC

LIMIT 1;



-- ============================================================
-- 07. YEAR-OVER-YEAR MONTHLY SALES GROWTH
-- Compare a month with the same month one year earlier
-- ============================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', d.date) AS month,
        SUM(fs.sales_amount) AS total_sales

    FROM fact_sales fs

    JOIN dim_date d
        ON fs.order_date_key = d.date_key

    GROUP BY DATE_TRUNC('month', d.date)
),

yoy_sales AS (

    SELECT
        month,
        total_sales,

        LAG(total_sales, 12)
        OVER (ORDER BY month) AS previous_year_sales

    FROM monthly_sales
)

SELECT
    month,
    total_sales,
    previous_year_sales,

    ROUND(
        (
            total_sales - previous_year_sales
        )
        / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS yoy_growth_pct

FROM yoy_sales

ORDER BY month;



-- ============================================================
-- 08. FULL-YEAR COMPARISON
-- Only compare 2018 and 2019 because both contain 12 months
-- ============================================================

WITH yearly_performance AS (

    SELECT
        EXTRACT(YEAR FROM d.date) AS year,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_profit

    FROM fact_sales fs

    JOIN dim_date d
        ON fs.order_date_key = d.date_key

    WHERE EXTRACT(YEAR FROM d.date) IN (2018, 2019)

    GROUP BY EXTRACT(YEAR FROM d.date)
),

yearly_growth AS (

    SELECT
        year,
        total_sales,
        total_profit,

        LAG(total_sales)
        OVER (ORDER BY year) AS previous_year_sales,

        LAG(total_profit)
        OVER (ORDER BY year) AS previous_year_profit

    FROM yearly_performance
)

SELECT
    year,
    total_sales,
    total_profit,

    ROUND(
        (
            total_sales - previous_year_sales
        )
        / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS sales_growth_pct,

    ROUND(
        (
            total_profit - previous_year_profit
        )
        / NULLIF(previous_year_profit, 0) * 100,
        2
    ) AS profit_growth_pct

FROM yearly_growth

ORDER BY year;



-- ============================================================
-- 09. LIKE-FOR-LIKE JANUARY TO MAY COMPARISON
-- Useful for comparing 2020 fairly because these are complete
-- months in 2018, 2019 and 2020.
-- ============================================================

SELECT
    EXTRACT(YEAR FROM d.date) AS year,

    SUM(fs.sales_amount) AS total_sales,

    SUM(
        fs.sales_amount - fs.total_product_cost
    ) AS total_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct

FROM fact_sales fs

JOIN dim_date d
    ON fs.order_date_key = d.date_key

WHERE EXTRACT(MONTH FROM d.date) BETWEEN 1 AND 5

GROUP BY EXTRACT(YEAR FROM d.date)

ORDER BY year;



-- ============================================================
-- 10. LIKE-FOR-LIKE JULY TO DECEMBER COMPARISON
-- Allows 2017, 2018 and 2019 to be compared using the same
-- six-month period.
-- ============================================================

SELECT
    EXTRACT(YEAR FROM d.date) AS year,

    SUM(fs.sales_amount) AS total_sales,

    SUM(
        fs.sales_amount - fs.total_product_cost
    ) AS total_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct

FROM fact_sales fs

JOIN dim_date d
    ON fs.order_date_key = d.date_key

WHERE EXTRACT(MONTH FROM d.date) BETWEEN 7 AND 12

GROUP BY EXTRACT(YEAR FROM d.date)

ORDER BY year;