-- ============================================================
-- 11_POWERBI_VALIDATION.SQL
-- Purpose:
-- Create trusted SQL benchmark totals that can be compared
-- against Power BI after the data model and DAX measures
-- have been created.
--
-- Important:
-- Gross Profit = Sales Amount - Total Product Cost
-- Gross Margin % = Gross Profit / Sales Amount
-- ============================================================


-- ============================================================
-- 01. OVERALL KPI BENCHMARKS
-- Use these values to validate Power BI KPI cards.
-- ============================================================

SELECT
    ROUND(
        SUM(fs.sales_amount),
        2
    ) AS total_sales,

    ROUND(
        SUM(fs.total_product_cost),
        2
    ) AS total_product_cost,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost),
        2
    ) AS total_gross_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(
        DISTINCT dso.sales_order
    ) AS total_orders,

    SUM(
        fs.order_quantity
    ) AS units_sold,

    ROUND(
        SUM(fs.sales_amount)
        / NULLIF(COUNT(DISTINCT dso.sales_order), 0),
        2
    ) AS average_order_value

FROM fact_sales fs

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key;


-- ============================================================
-- 02. CHANNEL BENCHMARKS
-- Validate Internet vs Reseller visuals and slicers.
-- ============================================================

SELECT
    dso.channel,

    ROUND(
        SUM(fs.sales_amount),
        2
    ) AS total_sales,

    ROUND(
        SUM(fs.total_product_cost),
        2
    ) AS total_product_cost,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost),
        2
    ) AS total_gross_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(
        DISTINCT dso.sales_order
    ) AS total_orders,

    SUM(
        fs.order_quantity
    ) AS units_sold,

    ROUND(
        SUM(fs.sales_amount)
        / NULLIF(COUNT(DISTINCT dso.sales_order), 0),
        2
    ) AS average_order_value

FROM fact_sales fs

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

GROUP BY dso.channel

ORDER BY total_sales DESC;


-- ============================================================
-- 03. YEAR BENCHMARKS
-- Validate date relationships and annual trend totals.
-- 2017 and 2020 are partial years.
-- ============================================================

SELECT
    EXTRACT(YEAR FROM d.date) AS year,

    ROUND(
        SUM(fs.sales_amount),
        2
    ) AS total_sales,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost),
        2
    ) AS total_gross_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(
        DISTINCT dso.sales_order
    ) AS total_orders,

    SUM(
        fs.order_quantity
    ) AS units_sold

FROM fact_sales fs

JOIN dim_date d
    ON fs.order_date_key = d.date_key

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

GROUP BY
    EXTRACT(YEAR FROM d.date)

ORDER BY year;


-- ============================================================
-- 04. PRODUCT CATEGORY BENCHMARKS
-- ============================================================

SELECT
    dp.category,

    ROUND(
        SUM(fs.sales_amount),
        2
    ) AS total_sales,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost),
        2
    ) AS total_gross_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS gross_margin_pct,

    SUM(
        fs.order_quantity
    ) AS units_sold

FROM fact_sales fs

JOIN dim_product dp
    ON fs.product_key = dp.product_key

GROUP BY dp.category

ORDER BY total_sales DESC;


-- ============================================================
-- 05. TERRITORY GROUP BENCHMARKS
-- ============================================================

SELECT
    dst.territory_group,

    ROUND(
        SUM(fs.sales_amount),
        2
    ) AS total_sales,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost),
        2
    ) AS total_gross_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(
        DISTINCT dso.sales_order
    ) AS total_orders,

    SUM(
        fs.order_quantity
    ) AS units_sold

FROM fact_sales fs

JOIN dim_sales_territory dst
    ON fs.sales_territory_key = dst.sales_territory_key

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

GROUP BY dst.territory_group

ORDER BY total_sales DESC;


-- ============================================================
-- 06. CUSTOMER / RESELLER COUNT BENCHMARKS
-- ============================================================

SELECT
    COUNT(
        DISTINCT CASE
            WHEN dso.channel = 'Internet'
             AND fs.customer_key <> -1
            THEN fs.customer_key
        END
    ) AS internet_customers,

    COUNT(
        DISTINCT CASE
            WHEN dso.channel = 'Reseller'
             AND fs.reseller_key <> -1
            THEN fs.reseller_key
        END
    ) AS active_resellers

FROM fact_sales fs

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key;


-- ============================================================
-- 07. FACT ROW / ORDER BENCHMARKS BY CHANNEL
-- Helps detect accidental duplication in Power BI.
-- ============================================================

SELECT
    dso.channel,

    COUNT(*) AS sales_line_rows,

    COUNT(
        DISTINCT fs.sales_order_line_key
    ) AS distinct_sales_lines,

    COUNT(
        DISTINCT dso.sales_order
    ) AS distinct_orders

FROM fact_sales fs

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

GROUP BY dso.channel

ORDER BY dso.channel;


-- ============================================================
-- 08. GRAND TOTAL RECONCILIATION
-- Category and territory totals should reconcile back
-- to the same company totals.
-- ============================================================

WITH company_total AS (

    SELECT
        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit

    FROM fact_sales fs
),

category_total AS (

    SELECT
        SUM(category_sales) AS total_sales,
        SUM(category_profit) AS total_gross_profit

    FROM (
        SELECT
            dp.category,

            SUM(
                fs.sales_amount
            ) AS category_sales,

            SUM(
                fs.sales_amount - fs.total_product_cost
            ) AS category_profit

        FROM fact_sales fs

        JOIN dim_product dp
            ON fs.product_key = dp.product_key

        GROUP BY dp.category
    ) c
),

territory_total AS (

    SELECT
        SUM(territory_sales) AS total_sales,
        SUM(territory_profit) AS total_gross_profit

    FROM (
        SELECT
            dst.territory_group,

            SUM(
                fs.sales_amount
            ) AS territory_sales,

            SUM(
                fs.sales_amount - fs.total_product_cost
            ) AS territory_profit

        FROM fact_sales fs

        JOIN dim_sales_territory dst
            ON fs.sales_territory_key = dst.sales_territory_key

        GROUP BY dst.territory_group
    ) t
)

SELECT
    ROUND(
        c.total_sales,
        2
    ) AS company_sales,

    ROUND(
        ct.total_sales,
        2
    ) AS category_sales_total,

    ROUND(
        tt.total_sales,
        2
    ) AS territory_sales_total,

    ROUND(
        c.total_gross_profit,
        2
    ) AS company_gross_profit,

    ROUND(
        ct.total_gross_profit,
        2
    ) AS category_gross_profit_total,

    ROUND(
        tt.total_gross_profit,
        2
    ) AS territory_gross_profit_total

FROM company_total c

CROSS JOIN category_total ct

CROSS JOIN territory_total tt;