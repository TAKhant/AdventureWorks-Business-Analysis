-- 01. Product Relationship Check
SELECT COUNT(*) AS orphan_product_rows
FROM fact_sales fs
LEFT JOIN dim_product dp
    ON fs.product_key = dp.product_key
WHERE dp.product_key IS NULL;


-- 02. Customer Relationship Check
SELECT COUNT(*) AS orphan_customer_rows
FROM fact_sales fs
LEFT JOIN dim_customer dc
    ON fs.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;


-- 03. Reseller Relationship Check
SELECT COUNT(*) AS orphan_reseller_rows
FROM fact_sales fs
LEFT JOIN dim_reseller dr
    ON fs.reseller_key = dr.reseller_key
WHERE dr.reseller_key IS NULL;


-- 04. Sales Territory Relationship Check
SELECT COUNT(*) AS orphan_territory_rows
FROM fact_sales fs
LEFT JOIN dim_sales_territory dst
    ON fs.sales_territory_key = dst.sales_territory_key
WHERE dst.sales_territory_key IS NULL;


-- 05. Order Date Relationship Check
SELECT COUNT(*) AS orphan_order_date_rows
FROM fact_sales fs
LEFT JOIN dim_date dd
    ON fs.order_date_key = dd.date_key
WHERE dd.date_key IS NULL;


-- 06. Due Date Relationship Check
SELECT COUNT(*) AS orphan_due_date_rows
FROM fact_sales fs
LEFT JOIN dim_date dd
    ON fs.due_date_key = dd.date_key
WHERE dd.date_key IS NULL;


-- 07. Ship Date Relationship Check
SELECT COUNT(*) AS orphan_ship_date_rows
FROM fact_sales fs
LEFT JOIN dim_date dd
    ON fs.ship_date_key = dd.date_key
WHERE fs.ship_date_key IS NOT NULL
  AND dd.date_key IS NULL;


-- 08. Sales Order Relationship Check
SELECT COUNT(*) AS orphan_sales_order_rows
FROM fact_sales fs
LEFT JOIN dim_sales_order dso
    ON fs.sales_order_line_key = dso.sales_order_line_key
WHERE dso.sales_order_line_key IS NULL;