CREATE TABLE dim_product (
    product_key INTEGER PRIMARY KEY,
    sku TEXT NOT NULL,
    product TEXT NOT NULL,
    standard_cost NUMERIC(18,4) NOT NULL,
    color TEXT,
    list_price NUMERIC(18,4) NOT NULL,
    model TEXT NOT NULL,
    subcategory TEXT NOT NULL,
    category TEXT NOT NULL
);

CREATE TABLE dim_customer (
    customer_key INTEGER PRIMARY KEY,
    customer_id TEXT NOT NULL,
    customer TEXT NOT NULL,
    city TEXT NOT NULL,
    state_province TEXT NOT NULL,
    country_region TEXT NOT NULL,
    postal_code TEXT NOT NULL
);

CREATE TABLE dim_reseller (
    reseller_key INTEGER PRIMARY KEY,
    reseller_id TEXT NOT NULL,
    business_type TEXT NOT NULL,
    reseller TEXT NOT NULL,
    city TEXT NOT NULL,
    state_province TEXT NOT NULL,
    country_region TEXT NOT NULL,
    postal_code TEXT NOT NULL
);

CREATE TABLE dim_sales_territory (
    sales_territory_key INTEGER PRIMARY KEY,
    region TEXT NOT NULL,
    country TEXT NOT NULL,
    territory_group TEXT NOT NULL
);

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    date DATE NOT NULL,
    fiscal_year TEXT NOT NULL,
    fiscal_quarter TEXT NOT NULL,
    month TEXT NOT NULL,
    full_date TEXT NOT NULL,
    month_key INTEGER NOT NULL
);

CREATE TABLE dim_sales_order (
    channel TEXT NOT NULL,
    sales_order_line_key INTEGER PRIMARY KEY,
    sales_order TEXT NOT NULL,
    sales_order_line TEXT NOT NULL
);

CREATE TABLE fact_sales (
    sales_order_line_key INTEGER PRIMARY KEY,
    reseller_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    order_date_key INTEGER NOT NULL,
    due_date_key INTEGER NOT NULL,
    ship_date_key INTEGER,
    sales_territory_key INTEGER NOT NULL,
    order_quantity INTEGER NOT NULL,
    unit_price NUMERIC(18,4) NOT NULL,
    extended_amount NUMERIC(18,4) NOT NULL,
    unit_price_discount_pct NUMERIC(10,4) NOT NULL,
    product_standard_cost NUMERIC(18,4) NOT NULL,
    total_product_cost NUMERIC(18,4) NOT NULL,
    sales_amount NUMERIC(18,4) NOT NULL
);

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

