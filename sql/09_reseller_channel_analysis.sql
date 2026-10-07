-- ============================================================
-- 09_RESELLER_CHANNEL_ANALYSIS.SQL
-- Business Question:
-- How do the Internet and Reseller channels compare, and which
-- reseller relationships drive or weaken profitability?
-- ============================================================


-- ============================================================
-- 01. CHANNEL PERFORMANCE OVERVIEW
-- ============================================================

WITH channel_summary AS (

    SELECT
        dso.channel,

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

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    GROUP BY dso.channel
)

SELECT
    channel,

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
        / NULLIF(total_orders, 0),
        2
    ) AS average_order_value,

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

FROM channel_summary

ORDER BY total_sales DESC;


-- ============================================================
-- 02. CHANNEL PERFORMANCE OVER TIME
-- Compare complete years only: 2018 vs 2019
-- ============================================================

WITH yearly_channel AS (

    SELECT
        EXTRACT(YEAR FROM d.date) AS year,

        dso.channel,

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

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    JOIN dim_date d
        ON fs.order_date_key = d.date_key

    WHERE EXTRACT(YEAR FROM d.date) IN (2018, 2019)

    GROUP BY
        EXTRACT(YEAR FROM d.date),
        dso.channel
),

channel_growth AS (

    SELECT
        year,
        channel,
        total_sales,
        total_gross_profit,
        total_orders,
        units_sold,

        total_gross_profit
        / NULLIF(total_sales, 0) * 100
            AS gross_margin_pct,

        LAG(total_sales)
        OVER (
            PARTITION BY channel
            ORDER BY year
        ) AS previous_year_sales,

        LAG(total_gross_profit)
        OVER (
            PARTITION BY channel
            ORDER BY year
        ) AS previous_year_gross_profit

    FROM yearly_channel
)

SELECT
    year,
    channel,

    ROUND(total_sales, 2) AS total_sales,

    ROUND(total_gross_profit, 2) AS total_gross_profit,

    ROUND(gross_margin_pct, 2) AS gross_margin_pct,

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
    ) AS gross_profit_growth_pct

FROM channel_growth

ORDER BY
    channel,
    year;


-- ============================================================
-- 03. RESELLER OVERVIEW
-- ============================================================

SELECT
    COUNT(
        DISTINCT fs.reseller_key
    ) AS active_resellers,

    COUNT(
        DISTINCT dso.sales_order
    ) AS total_orders,

    SUM(
        fs.order_quantity
    ) AS units_sold,

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

    ROUND(
        SUM(fs.sales_amount)
        / NULLIF(COUNT(DISTINCT dso.sales_order), 0),
        2
    ) AS average_order_value,

    ROUND(
        SUM(fs.sales_amount)
        / NULLIF(COUNT(DISTINCT fs.reseller_key), 0),
        2
    ) AS average_sales_per_reseller

FROM fact_sales fs

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

WHERE dso.channel = 'Reseller'
  AND fs.reseller_key <> -1;


-- ============================================================
-- 04. TOP 10 RESELLERS BY REVENUE
-- ============================================================

SELECT
    dr.reseller_key,
    dr.reseller_id,
    dr.reseller,
    dr.business_type,

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

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

JOIN dim_reseller dr
    ON fs.reseller_key = dr.reseller_key

WHERE dso.channel = 'Reseller'
  AND fs.reseller_key <> -1

GROUP BY
    dr.reseller_key,
    dr.reseller_id,
    dr.reseller,
    dr.business_type

ORDER BY total_sales DESC

LIMIT 10;


-- ============================================================
-- 05. TOP 10 RESELLERS BY GROSS PROFIT
-- ============================================================

SELECT
    dr.reseller_key,
    dr.reseller_id,
    dr.reseller,
    dr.business_type,

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

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

JOIN dim_reseller dr
    ON fs.reseller_key = dr.reseller_key

WHERE dso.channel = 'Reseller'
  AND fs.reseller_key <> -1

GROUP BY
    dr.reseller_key,
    dr.reseller_id,
    dr.reseller,
    dr.business_type

ORDER BY total_gross_profit DESC

LIMIT 10;


-- ============================================================
-- 06. HIGH-REVENUE LOSS-MAKING RESELLERS
-- ============================================================

WITH reseller_summary AS (

    SELECT
        dr.reseller_key,
        dr.reseller_id,
        dr.reseller,
        dr.business_type,

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

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    JOIN dim_reseller dr
        ON fs.reseller_key = dr.reseller_key

    WHERE dso.channel = 'Reseller'
      AND fs.reseller_key <> -1

    GROUP BY
        dr.reseller_key,
        dr.reseller_id,
        dr.reseller,
        dr.business_type
)

SELECT
    reseller_key,
    reseller_id,
    reseller,
    business_type,

    ROUND(
        total_sales,
        2
    ) AS total_sales,

    ROUND(
        total_gross_profit,
        2
    ) AS total_gross_profit,

    ROUND(
        total_gross_profit
        / NULLIF(total_sales, 0) * 100,
        2
    ) AS gross_margin_pct,

    total_orders,
    units_sold

FROM reseller_summary

WHERE total_gross_profit < 0

ORDER BY total_sales DESC

LIMIT 10;


-- ============================================================
-- 07. PROFITABLE VS LOSS-MAKING RESELLERS
-- ============================================================

WITH reseller_summary AS (

    SELECT
        fs.reseller_key,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit

    FROM fact_sales fs

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    WHERE dso.channel = 'Reseller'
      AND fs.reseller_key <> -1

    GROUP BY fs.reseller_key
),

profitability_group AS (

    SELECT
        CASE
            WHEN total_gross_profit >= 0
                THEN 'Profitable Reseller'
            ELSE 'Loss-Making Reseller'
        END AS reseller_profitability,

        COUNT(*) AS reseller_count,

        SUM(total_sales) AS total_sales,

        SUM(total_gross_profit) AS total_gross_profit

    FROM reseller_summary

    GROUP BY
        CASE
            WHEN total_gross_profit >= 0
                THEN 'Profitable Reseller'
            ELSE 'Loss-Making Reseller'
        END
)

SELECT
    reseller_profitability,

    reseller_count,

    ROUND(
        reseller_count::NUMERIC
        / NULLIF(SUM(reseller_count) OVER (), 0) * 100,
        2
    ) AS reseller_share_pct,

    ROUND(
        total_sales,
        2
    ) AS total_sales,

    ROUND(
        total_sales
        / NULLIF(SUM(total_sales) OVER (), 0) * 100,
        2
    ) AS sales_share_pct,

    ROUND(
        total_gross_profit,
        2
    ) AS total_gross_profit

FROM profitability_group

ORDER BY total_sales DESC;


-- ============================================================
-- 08. RESELLER BUSINESS TYPE PERFORMANCE
-- ============================================================

SELECT
    dr.business_type,

    COUNT(
        DISTINCT fs.reseller_key
    ) AS active_resellers,

    COUNT(
        DISTINCT dso.sales_order
    ) AS total_orders,

    SUM(
        fs.order_quantity
    ) AS units_sold,

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

    ROUND(
        SUM(fs.sales_amount)
        / NULLIF(
            SUM(SUM(fs.sales_amount)) OVER (),
            0
        ) * 100,
        2
    ) AS sales_share_pct,

    ROUND(
        SUM(fs.sales_amount)
        / NULLIF(COUNT(DISTINCT fs.reseller_key), 0),
        2
    ) AS average_sales_per_reseller

FROM fact_sales fs

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

JOIN dim_reseller dr
    ON fs.reseller_key = dr.reseller_key

WHERE dso.channel = 'Reseller'
  AND fs.reseller_key <> -1

GROUP BY dr.business_type

ORDER BY total_sales DESC;


-- ============================================================
-- 09. RESELLER REVENUE AND GROSS-PROFIT CONCENTRATION
-- ============================================================

WITH reseller_summary AS (

    SELECT
        fs.reseller_key,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit

    FROM fact_sales fs

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    WHERE dso.channel = 'Reseller'
      AND fs.reseller_key <> -1

    GROUP BY fs.reseller_key
),

ranked_resellers AS (

    SELECT
        reseller_key,
        total_sales,
        total_gross_profit,

        ROW_NUMBER() OVER (
            ORDER BY total_sales DESC
        ) AS revenue_rank,

        ROW_NUMBER() OVER (
            ORDER BY total_gross_profit DESC
        ) AS profit_rank

    FROM reseller_summary
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN revenue_rank <= 5
                    THEN total_sales
                ELSE 0
            END
        ),
        2
    ) AS top_5_reseller_sales,

    ROUND(
        SUM(
            CASE
                WHEN revenue_rank <= 5
                    THEN total_sales
                ELSE 0
            END
        )
        / NULLIF(SUM(total_sales), 0) * 100,
        2
    ) AS top_5_revenue_pct,

    ROUND(
        SUM(
            CASE
                WHEN revenue_rank <= 10
                    THEN total_sales
                ELSE 0
            END
        ),
        2
    ) AS top_10_reseller_sales,

    ROUND(
        SUM(
            CASE
                WHEN revenue_rank <= 10
                    THEN total_sales
                ELSE 0
            END
        )
        / NULLIF(SUM(total_sales), 0) * 100,
        2
    ) AS top_10_revenue_pct,

    ROUND(
        SUM(
            CASE
                WHEN profit_rank <= 5
                    THEN total_gross_profit
                ELSE 0
            END
        ),
        2
    ) AS top_5_reseller_gross_profit,

    ROUND(
        SUM(
            CASE
                WHEN profit_rank <= 5
                    THEN total_gross_profit
                ELSE 0
            END
        )
        / NULLIF(SUM(total_gross_profit), 0) * 100,
        2
    ) AS top_5_gross_profit_pct,

    ROUND(
        SUM(
            CASE
                WHEN profit_rank <= 10
                    THEN total_gross_profit
                ELSE 0
            END
        ),
        2
    ) AS top_10_reseller_gross_profit,

    ROUND(
        SUM(
            CASE
                WHEN profit_rank <= 10
                    THEN total_gross_profit
                ELSE 0
            END
        )
        / NULLIF(SUM(total_gross_profit), 0) * 100,
        2
    ) AS top_10_gross_profit_pct

FROM ranked_resellers;