-- 1. Check missing values
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) - COUNT(sales_order_line_key) AS missing_sales_order_line_key,
    COUNT(*) - COUNT(reseller_key) AS missing_reseller_key,
    COUNT(*) - COUNT(customer_key) AS missing_customer_key,
    COUNT(*) - COUNT(product_key) AS missing_product_key,
    COUNT(*) - COUNT(order_date_key) AS missing_order_date_key,
    COUNT(*) - COUNT(due_date_key) AS missing_due_date_key,
    COUNT(*) - COUNT(ship_date_key) AS missing_ship_date_key,
    COUNT(*) - COUNT(sales_territory_key) AS missing_sales_territory_key,
    COUNT(*) - COUNT(order_quantity) AS missing_order_quantity,
    COUNT(*) - COUNT(unit_price) AS missing_unit_price,
    COUNT(*) - COUNT(extended_amount) AS missing_extended_amount,
    COUNT(*) - COUNT(unit_price_discount_pct) AS missing_discount_pct,
    COUNT(*) - COUNT(product_standard_cost) AS missing_product_standard_cost,
    COUNT(*) - COUNT(total_product_cost) AS missing_total_product_cost,
    COUNT(*) - COUNT(sales_amount) AS missing_sales_amount
FROM fact_sales;

-- 2. Check duplicate primary_keys 
    -- 2.1 fact_sales
    SELECT
        sales_order_line_key,
        COUNT(*) as duplicate_count
    FROM fact_sales
    GROUP BY sales_order_line_key
    HAVING COUNT(*) > 1;

    -- 2.2 dim_product
    SELECT
        product_key,
        COUNT(*) as duplicate_count
    FROM dim_product
    GROUP BY product_key
    HAVING COUNT(*) > 1;

    -- 2.3 dim_customer
    SELECT
        customer_key,
        COUNT(*) AS duplicate_count
    FROM dim_customer
    GROUP BY customer_key
    HAVING COUNT(*) > 1;

    -- 2.4 dim_reseller
    SELECT
        reseller_key,
        COUNT(*) AS duplicate_count
    FROM dim_reseller
    GROUP BY reseller_key
    HAVING COUNT(*) > 1;

    -- 2.5 dim_sales_territory
    SELECT
        sales_territory_key,
        COUNT(*) AS duplicate_count
    FROM dim_sales_territory
    GROUP BY sales_territory_key
    HAVING COUNT(*) > 1;

    -- 2.6 dim_date
    SELECT
        date_key,
        COUNT(*) AS duplicate_count
    FROM dim_date
    GROUP BY date_key
    HAVING COUNT(*) > 1;

    -- 2.7 dim_sales_order
    SELECT
        sales_order_line_key,
        COUNT(*) AS duplicate_count
    FROM dim_sales_order
    GROUP BY sales_order_line_key
    HAVING COUNT(*) > 1;
    
 
-- 3. Check invalid numeric values
    -- 3.1 fact_sales
    SELECT *
    FROM fact_sales
    WHERE
        order_quantity <= 0
        OR unit_price < 0
        OR product_standard_cost < 0
        OR total_product_cost < 0
        OR sales_amount < 0
        OR unit_price_discount_pct < 0
        OR unit_price_discount_pct > 1;

    -- 3.2 dim_product
    SELECT *
    FROM dim_product
    WHERE
        standard_cost < 0
        OR list_price < 0;

-- 4. Verify Customer/Reseller -1 logic

-- 4.1 Count rows with CustomerKey = -1
SELECT
    COUNT(*) AS customer_not_applicable_rows
FROM fact_sales
WHERE customer_key = -1;

-- 4.2 Count rows with ResellerKey = -1
SELECT
    COUNT(*) AS reseller_not_applicable_rows
FROM fact_sales
WHERE reseller_key = -1;

SELECT
    so.channel,
    COUNT(*) AS row_count,
    SUM(CASE WHEN fs.customer_key = -1 THEN 1 ELSE 0 END) AS customer_key_minus_1,
    SUM(CASE WHEN fs.reseller_key = -1 THEN 1 ELSE 0 END) AS reseller_key_minus_1
FROM fact_sales fs
JOIN dim_sales_order so
    ON fs.sales_order_line_key = so.sales_order_line_key
GROUP BY so.channel;

-- 5. Date range and missing ship dates

-- 5.1 Earliest and latest order dates
SELECT
    MIN(d.date) AS earliest_order_date,
    MAX(d.date) AS latest_order_date
FROM dim_date d;


-- 5.2 Count missing ship dates
SELECT
    COUNT(*) AS missing_ship_date_rows
FROM fact_sales
WHERE ship_date_key IS NULL;


-- 5.3 Check which channels contain missing ship dates
SELECT
    so.channel,
    COUNT(*) AS missing_ship_date_rows
FROM fact_sales fs
JOIN dim_sales_order so
    ON fs.sales_order_line_key = so.sales_order_line_key
WHERE fs.ship_date_key IS NULL
GROUP BY so.channel
ORDER BY missing_ship_date_rows DESC;


-- 5.4 Check when missing ship dates occur
SELECT
    d.date AS order_date,
    COUNT(*) AS missing_ship_date_rows
FROM fact_sales fs
JOIN dim_date d
    ON fs.order_date_key = d.date_key
WHERE fs.ship_date_key IS NULL
GROUP BY d.date
ORDER BY d.date;

