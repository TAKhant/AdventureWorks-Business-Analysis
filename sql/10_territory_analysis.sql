-- ============================================================
-- 10_TERRITORY_ANALYSIS.SQL
-- Business Question:
-- Which geographic markets drive AdventureWorks revenue and
-- gross profit, where are margins strongest or weakest, and
-- how does channel performance vary by territory?
-- ============================================================


-- ============================================================
-- 01. TERRITORY GROUP PERFORMANCE
-- North America vs Europe vs Pacific
-- ============================================================

WITH group_summary AS (

    SELECT
        dst.territory_group,

        SUM(fs.sales_amount) AS total_sales,

        SUM(fs.total_product_cost) AS total_cost,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit,

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
)

SELECT
    territory_group,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(total_cost, 2) AS total_cost,

    ROUND(total_gross_profit, 2) AS total_gross_profit,

    ROUND(
        total_gross_profit
        / NULLIF(total_sales, 0) * 100,
        2
    ) AS gross_margin_pct,

    total_orders,
    units_sold,

    ROUND(
        total_sales
        / NULLIF(SUM(total_sales) OVER (), 0) * 100,
        2
    ) AS sales_share_pct,

    ROUND(
        total_gross_profit
        / NULLIF(SUM(total_gross_profit) OVER (), 0) * 100,
        2
    ) AS gross_profit_share_pct

FROM group_summary

ORDER BY total_sales DESC;


-- ============================================================
-- 02. COUNTRY PERFORMANCE
-- ============================================================

WITH country_summary AS (

    SELECT
        dst.country,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit,

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

    GROUP BY dst.country
)

SELECT
    country,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(total_gross_profit, 2) AS total_gross_profit,

    ROUND(
        total_gross_profit
        / NULLIF(total_sales, 0) * 100,
        2
    ) AS gross_margin_pct,

    total_orders,
    units_sold,

    ROUND(
        total_sales
        / NULLIF(SUM(total_sales) OVER (), 0) * 100,
        2
    ) AS sales_share_pct,

    ROUND(
        total_gross_profit
        / NULLIF(SUM(total_gross_profit) OVER (), 0) * 100,
        2
    ) AS gross_profit_share_pct

FROM country_summary

ORDER BY total_sales DESC;


-- ============================================================
-- 03. REGION PERFORMANCE
-- ============================================================

WITH region_summary AS (

    SELECT
        dst.territory_group,
        dst.country,
        dst.region,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit,

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

    GROUP BY
        dst.territory_group,
        dst.country,
        dst.region
)

SELECT
    territory_group,
    country,
    region,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(total_gross_profit, 2) AS total_gross_profit,

    ROUND(
        total_gross_profit
        / NULLIF(total_sales, 0) * 100,
        2
    ) AS gross_margin_pct,

    total_orders,
    units_sold,

    ROUND(
        total_sales
        / NULLIF(SUM(total_sales) OVER (), 0) * 100,
        2
    ) AS sales_share_pct,

    ROUND(
        total_gross_profit
        / NULLIF(SUM(total_gross_profit) OVER (), 0) * 100,
        2
    ) AS gross_profit_share_pct

FROM region_summary

ORDER BY total_sales DESC;


-- ============================================================
-- 04. TERRITORY GROUP PERFORMANCE BY CHANNEL
-- ============================================================

SELECT
    dst.territory_group,
    dso.channel,

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

GROUP BY
    dst.territory_group,
    dso.channel

ORDER BY
    dst.territory_group,
    total_sales DESC;


-- ============================================================
-- 05. REGION PERFORMANCE BY CHANNEL
-- ============================================================

SELECT
    dst.territory_group,
    dst.country,
    dst.region,
    dso.channel,

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

GROUP BY
    dst.territory_group,
    dst.country,
    dst.region,
    dso.channel

ORDER BY
    dst.region,
    total_sales DESC;


-- ============================================================
-- 06. REGION PERFORMANCE OVER TIME
-- Compare complete years only: 2018 vs 2019
-- ============================================================

WITH yearly_region AS (

    SELECT
        EXTRACT(YEAR FROM d.date) AS year,
        dst.region,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit,

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

    JOIN dim_date d
        ON fs.order_date_key = d.date_key

    WHERE EXTRACT(YEAR FROM d.date) IN (2018, 2019)

    GROUP BY
        EXTRACT(YEAR FROM d.date),
        dst.region
),

region_growth AS (

    SELECT
        year,
        region,
        total_sales,
        total_gross_profit,
        total_orders,
        units_sold,

        total_gross_profit
        / NULLIF(total_sales, 0) * 100
            AS gross_margin_pct,

        LAG(total_sales)
        OVER (
            PARTITION BY region
            ORDER BY year
        ) AS previous_year_sales,

        LAG(total_gross_profit)
        OVER (
            PARTITION BY region
            ORDER BY year
        ) AS previous_year_gross_profit,

        LAG(units_sold)
        OVER (
            PARTITION BY region
            ORDER BY year
        ) AS previous_year_units

    FROM yearly_region
)

SELECT
    year,
    region,

    ROUND(
        total_sales,
        2
    ) AS total_sales,

    ROUND(
        total_gross_profit,
        2
    ) AS total_gross_profit,

    ROUND(
        gross_margin_pct,
        2
    ) AS gross_margin_pct,

    total_orders,
    units_sold,

    ROUND(
        (total_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS sales_growth_pct,

    ROUND(
        (total_gross_profit - previous_year_gross_profit)
        / NULLIF(previous_year_gross_profit, 0) * 100,
        2
    ) AS gross_profit_growth_pct,

    ROUND(
        (units_sold - previous_year_units)::NUMERIC
        / NULLIF(previous_year_units, 0) * 100,
        2
    ) AS units_growth_pct

FROM region_growth

ORDER BY
    region,
    year;


-- ============================================================
-- 07. LOWEST-MARGIN REGIONS
-- ============================================================

SELECT
    dst.territory_group,
    dst.country,
    dst.region,

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

JOIN dim_sales_territory dst
    ON fs.sales_territory_key = dst.sales_territory_key

GROUP BY
    dst.territory_group,
    dst.country,
    dst.region

ORDER BY gross_margin_pct ASC;


-- ============================================================
-- 08. LOSS-MAKING RESELLER TERRITORIES
-- ============================================================

SELECT
    dst.territory_group,
    dst.country,
    dst.region,

    ROUND(
        SUM(fs.sales_amount),
        2
    ) AS reseller_sales,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost),
        2
    ) AS reseller_gross_profit,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost)
        / NULLIF(SUM(fs.sales_amount), 0) * 100,
        2
    ) AS reseller_gross_margin_pct,

    COUNT(
        DISTINCT dso.sales_order
    ) AS reseller_orders,

    SUM(
        fs.order_quantity
    ) AS reseller_units_sold

FROM fact_sales fs

JOIN dim_sales_territory dst
    ON fs.sales_territory_key = dst.sales_territory_key

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

WHERE dso.channel = 'Reseller'

GROUP BY
    dst.territory_group,
    dst.country,
    dst.region

HAVING
    SUM(fs.sales_amount - fs.total_product_cost) < 0

ORDER BY reseller_gross_profit ASC;