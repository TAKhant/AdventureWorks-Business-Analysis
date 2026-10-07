SELECT 'fact_sales' AS table_name, COUNT(*) AS row_count
FROM fact_sales

UNION ALL

SELECT 'dim_sales_order', COUNT(*)
FROM dim_sales_order

UNION ALL

SELECT 'dim_sales_territory', COUNT(*)
FROM dim_sales_territory

UNION ALL

SELECT 'dim_reseller', COUNT(*)
FROM dim_reseller

UNION ALL

SELECT 'dim_date', COUNT(*)
FROM dim_date

UNION ALL

SELECT 'dim_product', COUNT(*)
FROM dim_product

UNION ALL

SELECT 'dim_customer', COUNT(*)
FROM dim_customer

ORDER BY row_count DESC;