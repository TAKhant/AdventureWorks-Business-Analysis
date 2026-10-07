-- ============================================================
-- 08_CUSTOMER_ANALYSIS.SQL
-- Business Question:
-- Who are AdventureWorks' most valuable Internet customers,
-- how concentrated is customer value, and how important are
-- repeat customers to revenue and gross profit?
-- ============================================================


-- ============================================================
-- 01. CUSTOMER OVERVIEW
-- ============================================================

SELECT
    COUNT(DISTINCT fs.customer_key) AS total_customers,
    COUNT(DISTINCT dso.sales_order) AS total_orders,
    SUM(fs.order_quantity) AS units_sold,
    ROUND(SUM(fs.sales_amount), 2) AS total_sales,

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
        / NULLIF(COUNT(DISTINCT fs.customer_key), 0),
        2
    ) AS average_sales_per_customer

FROM fact_sales fs

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

WHERE dso.channel = 'Internet'
  AND fs.customer_key <> -1;


-- ============================================================
-- 02. CUSTOMER SPEND DISTRIBUTION
-- Average vs median helps identify whether customer value
-- is evenly distributed or heavily skewed.
-- ============================================================

WITH customer_summary AS (

    SELECT
        fs.customer_key,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit,

        COUNT(
            DISTINCT dso.sales_order
        ) AS total_orders

    FROM fact_sales fs

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    WHERE dso.channel = 'Internet'
      AND fs.customer_key <> -1

    GROUP BY fs.customer_key
)

SELECT
    ROUND(
        AVG(total_sales),
        2
    ) AS average_customer_sales,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total_sales)::NUMERIC,
        2
    ) AS median_customer_sales,

    ROUND(
        AVG(total_gross_profit),
        2
    ) AS average_customer_gross_profit,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total_gross_profit)::NUMERIC,
        2
    ) AS median_customer_gross_profit,

    ROUND(
        AVG(total_orders),
        2
    ) AS average_orders_per_customer,

    ROUND(
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY total_orders)::NUMERIC,
        2
    ) AS median_orders_per_customer

FROM customer_summary;


-- ============================================================
-- 03. TOP 10 CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    dc.customer_key,
    dc.customer_id,
    dc.customer,

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

    SUM(fs.order_quantity) AS units_sold

FROM fact_sales fs

JOIN dim_customer dc
    ON fs.customer_key = dc.customer_key

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

WHERE dso.channel = 'Internet'
  AND fs.customer_key <> -1

GROUP BY
    dc.customer_key,
    dc.customer_id,
    dc.customer

ORDER BY total_sales DESC

LIMIT 10;


-- ============================================================
-- 04. TOP 10 CUSTOMERS BY GROSS PROFIT
-- ============================================================

SELECT
    dc.customer_key,
    dc.customer_id,
    dc.customer,

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

    SUM(fs.order_quantity) AS units_sold

FROM fact_sales fs

JOIN dim_customer dc
    ON fs.customer_key = dc.customer_key

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

WHERE dso.channel = 'Internet'
  AND fs.customer_key <> -1

GROUP BY
    dc.customer_key,
    dc.customer_id,
    dc.customer

ORDER BY total_gross_profit DESC

LIMIT 10;


-- ============================================================
-- 05. MOST FREQUENT CUSTOMERS
-- Frequency does not necessarily equal high customer value.
-- ============================================================

SELECT
    dc.customer_key,
    dc.customer_id,
    dc.customer,

    COUNT(
        DISTINCT dso.sales_order
    ) AS total_orders,

    ROUND(
        SUM(fs.sales_amount),
        2
    ) AS total_sales,

    ROUND(
        SUM(fs.sales_amount - fs.total_product_cost),
        2
    ) AS total_gross_profit,

    SUM(fs.order_quantity) AS units_sold,

    ROUND(
        SUM(fs.sales_amount)
        / NULLIF(COUNT(DISTINCT dso.sales_order), 0),
        2
    ) AS average_order_value

FROM fact_sales fs

JOIN dim_customer dc
    ON fs.customer_key = dc.customer_key

JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key

WHERE dso.channel = 'Internet'
  AND fs.customer_key <> -1

GROUP BY
    dc.customer_key,
    dc.customer_id,
    dc.customer

ORDER BY
    total_orders DESC,
    total_sales DESC

LIMIT 10;


-- ============================================================
-- 06. ONE-TIME VS REPEAT CUSTOMERS
-- Repeat customer = more than one distinct order.
-- ============================================================

WITH customer_summary AS (

    SELECT
        fs.customer_key,

        COUNT(
            DISTINCT dso.sales_order
        ) AS total_orders,

        SUM(fs.sales_amount) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit

    FROM fact_sales fs

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    WHERE dso.channel = 'Internet'
      AND fs.customer_key <> -1

    GROUP BY fs.customer_key
),

customer_type AS (

    SELECT
        customer_key,

        CASE
            WHEN total_orders = 1
                THEN 'One-Time Customer'
            ELSE 'Repeat Customer'
        END AS customer_type,

        total_orders,
        total_sales,
        total_gross_profit

    FROM customer_summary
),

segment_summary AS (

    SELECT
        customer_type,
        COUNT(*) AS customers,
        SUM(total_orders) AS total_orders,
        SUM(total_sales) AS total_sales,
        SUM(total_gross_profit) AS total_gross_profit

    FROM customer_type

    GROUP BY customer_type
)

SELECT
    customer_type,

    customers,

    ROUND(
        customers::NUMERIC
        / NULLIF(SUM(customers) OVER (), 0) * 100,
        2
    ) AS customer_share_pct,

    total_orders,

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
    ) AS total_gross_profit,

    ROUND(
        total_gross_profit
        / NULLIF(SUM(total_gross_profit) OVER (), 0) * 100,
        2
    ) AS gross_profit_share_pct

FROM segment_summary

ORDER BY total_sales DESC;


-- ============================================================
-- 07. CUSTOMER REVENUE AND PROFIT CONCENTRATION
-- Top 5 and Top 10 contribution.
-- ============================================================

WITH customer_summary AS (

    SELECT
        fs.customer_key,

        SUM(
            fs.sales_amount
        ) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit

    FROM fact_sales fs

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    WHERE dso.channel = 'Internet'
      AND fs.customer_key <> -1

    GROUP BY fs.customer_key
),

ranked_customers AS (

    SELECT
        customer_key,
        total_sales,
        total_gross_profit,

        ROW_NUMBER() OVER (
            ORDER BY total_sales DESC
        ) AS revenue_rank,

        ROW_NUMBER() OVER (
            ORDER BY total_gross_profit DESC
        ) AS profit_rank

    FROM customer_summary
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
    ) AS top_5_customer_sales,

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
    ) AS top_10_customer_sales,

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
    ) AS top_5_customer_gross_profit,

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
    ) AS top_10_customer_gross_profit,

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

FROM ranked_customers;


-- ============================================================
-- 08. CUSTOMER VALUE QUARTILES
-- Q1 = lowest-spending 25%
-- Q4 = highest-spending 25%
-- ============================================================

WITH customer_summary AS (

    SELECT
        fs.customer_key,

        SUM(
            fs.sales_amount
        ) AS total_sales,

        SUM(
            fs.sales_amount - fs.total_product_cost
        ) AS total_gross_profit,

        COUNT(
            DISTINCT dso.sales_order
        ) AS total_orders

    FROM fact_sales fs

    JOIN dim_sales_order dso
        ON fs.sales_order_line_key = dso.sales_order_line_key

    WHERE dso.channel = 'Internet'
      AND fs.customer_key <> -1

    GROUP BY fs.customer_key
),

customer_quartiles AS (

    SELECT
        customer_key,
        total_sales,
        total_gross_profit,
        total_orders,

        NTILE(4) OVER (
            ORDER BY total_sales
        ) AS value_quartile

    FROM customer_summary
)

SELECT
    CASE value_quartile
        WHEN 1 THEN 'Q1 - Lowest Value'
        WHEN 2 THEN 'Q2'
        WHEN 3 THEN 'Q3'
        WHEN 4 THEN 'Q4 - Highest Value'
    END AS customer_value_quartile,

    COUNT(*) AS customers,

    ROUND(
        MIN(total_sales),
        2
    ) AS minimum_customer_sales,

    ROUND(
        MAX(total_sales),
        2
    ) AS maximum_customer_sales,

    ROUND(
        AVG(total_sales),
        2
    ) AS average_customer_sales,

    ROUND(
        SUM(total_sales),
        2
    ) AS total_sales,

    ROUND(
        SUM(total_sales)
        / NULLIF(SUM(SUM(total_sales)) OVER (), 0) * 100,
        2
    ) AS sales_share_pct,

    ROUND(
        SUM(total_gross_profit),
        2
    ) AS total_gross_profit,

    ROUND(
        SUM(total_gross_profit)
        / NULLIF(SUM(SUM(total_gross_profit)) OVER (), 0) * 100,
        2
    ) AS gross_profit_share_pct,

    ROUND(
        AVG(total_orders),
        2
    ) AS average_orders_per_customer

FROM customer_quartiles

GROUP BY value_quartile

ORDER BY value_quartile;