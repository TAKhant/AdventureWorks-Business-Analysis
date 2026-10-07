# AdventureWorks Business Analysis

## Overview

This project is an end-to-end business analysis of AdventureWorks sales data using **PostgreSQL, SQL, and Power BI**.

The aim was not only to measure sales performance, but to understand whether revenue is translating into **profitable growth** and to identify the products, customers, sales channels, resellers, and territories that are strengthening or weakening business performance.

The project covers data validation, data-quality checks, relationship validation, KPI development, time analysis, product analysis, customer analysis, reseller/channel analysis, territory analysis, Power BI modelling, DAX, dashboard development, and final business recommendations.

> **Financial note:** In this project, `Sales Amount - Total Product Cost` is treated as **Gross Profit**. Therefore, the related profitability percentage is referred to as **Gross Margin %**, not net profit margin.

---
## Dashboard Preview

### Page 1 — Executive Overview

![Executive Overview](images/overview.png)

### Page 2 — Product & Profitability

![Product & Profitability](images/Product_Profitability.png)

### Page 3 — Customer, Channel & Territory

![Customer, Channel & Territory](images/_customer_territory.png)

## Business Problem

AdventureWorks generates strong sales, but management needs greater visibility into the **quality of that revenue**.

The main business question is:

> **Where is AdventureWorks generating profitable growth, and where is revenue failing to translate into gross profit?**

The analysis focuses on several supporting questions:

- Is sales growth also producing gross profit growth?
- Which products and product groups generate the strongest and weakest profitability?
- How does the Internet channel compare with the Reseller channel?
- Which customers create the most value?
- Which resellers are profitable or loss-making?
- Which territories generate profitable growth?
- Is weak geographic performance caused by geography itself or by channel mix?

---

## Project Objectives

The project was designed to:

1. Validate the imported data and analytical relationships.
2. Establish reliable business KPIs.
3. Measure sales, gross profit, gross margin, order volume, and customer activity.
4. Identify the main drivers of profitable and unprofitable growth.
5. Build an interactive Power BI dashboard for management reporting.
6. Translate the analysis into clear business recommendations.

---

## Tools Used

- **PostgreSQL** — database creation, storage, validation, and analysis
- **SQL** — KPI calculation and business analysis
- **VS Code** — SQL development and project organisation
- **Power BI** — data modelling, DAX, dashboard development, and interactive reporting
- **Git / GitHub** — version control and portfolio presentation

---

## Data Model

The analytical model follows a star-style structure with one sales fact table and supporting dimensions.

### Fact Table

- `fact_sales`

### Dimension Tables

- `dim_product`
- `dim_customer`
- `dim_reseller`
- `dim_sales_territory`
- `dim_date`
- `dim_sales_order`

The fact table is stored at **sales-order-line level** and contains quantities, sales values, product costs, discounts, and foreign keys to the dimension tables.

Power BI uses the same analytical structure so that dimensions filter the sales fact table consistently.

---

## Analysis Workflow

### 00 — Connection Test

Confirmed the PostgreSQL connection and active database.

### 01 — Create Tables

Created the fact and dimension tables required for the analytical model.

### 02 — Import Validation

Validated row counts after importing the source CSV files.

### 03 — Data Quality

Checked for:

- missing values,
- duplicate primary keys,
- invalid numeric values,
- customer/reseller `-1` logic,
- date coverage,
- missing ship dates.

### 04 — Relationship Validation

Checked for orphan records between the sales fact table and each dimension.

### 05 — Core KPIs

Calculated the main business measures:

- Total Sales
- Total Product Cost
- Gross Profit
- Gross Margin %
- Total Orders
- Units Sold
- Internet Customers
- Active Resellers
- Average Order Value

### 06 — Time Analysis

Analysed:

- yearly performance,
- monthly performance,
- month-over-month change,
- year-over-year change,
- full-year comparisons,
- like-for-like comparisons for partial years.

### 07 — Product Analysis

Analysed category, subcategory, and individual product performance using sales, gross profit, gross margin, units sold, and concentration measures.

### 08 — Customer Analysis

Analysed Internet customer value, repeat versus one-time customers, top customers, order frequency, customer concentration, and value quartiles.

### 09 — Reseller / Channel Analysis

Compared Internet and Reseller performance and investigated reseller profitability, loss-making resellers, reseller business types, and concentration.

### 10 — Territory Analysis

Analysed performance by territory group, country, region, channel, and sales-channel mix.

### 11 — Power BI Validation

Created SQL benchmarks to confirm that Power BI measures and dashboard totals matched the validated database results.

---

## Core KPI Results

| KPI | Result |
|---|---:|
| Total Sales | £109.81M |
| Gross Profit | £12.55M |
| Gross Margin | 11.43% |
| Total Orders | 31,455 |
| Units Sold | 274,776 |
| Internet Customers | 18,484 |
| Active Resellers | 635 |
| Average Order Value | £3,491 |

---

## Power BI Dashboard

The Power BI dashboard was designed to move from **high-level performance** into the main drivers of profitability.

### Executive Overview

Provides management with a high-level view of:

- Total Sales
- Gross Profit
- Gross Margin %
- Total Orders
- Units Sold
- Average Order Value
- Sales growth
- Gross profit growth
- performance over time
- channel performance
- territory performance
- product-category performance

### Product & Profitability

Focuses on:

- category and subcategory performance,
- top products by sales and gross profit,
- weak or loss-making products,
- sales volume versus profitability,
- gross-margin differences.

### Customer, Channel & Territory

Focuses on:

- Internet versus Reseller performance,
- repeat and high-value customers,
- reseller profitability,
- profitable and loss-making reseller relationships,
- territory performance,
- the effect of channel mix on geographic profitability.

---

## Key Findings

The detailed analysis and supporting figures are documented in [`key_findings.md`](key_findings.md).

The main findings are:

1. **AdventureWorks generates strong revenue, but overall profitability is relatively thin.**
2. **Revenue growth does not always translate into profitable growth.**
3. **The Reseller channel is the largest profitability problem.**
4. **Product profitability varies significantly even when sales or unit volume is high.**
5. **Repeat and high-value Internet customers contribute disproportionately to sales and gross profit.**
6. **Geographic profitability is strongly influenced by sales-channel mix.**

The central conclusion is that AdventureWorks should focus on **profitable growth rather than sales growth alone**.

---

## Business Recommendations

Based on the analysis, AdventureWorks should:

- investigate the Reseller channel as the highest-priority profitability issue,
- review and renegotiate loss-making reseller relationships,
- protect and expand the highly profitable Internet channel,
- prioritise retention of repeat and high-value Internet customers,
- review high-volume products with weak or negative margins,
- evaluate performance using **Sales + Gross Profit + Gross Margin** together,
- investigate territory performance together with channel mix,
- continue using the Power BI dashboard to monitor profitable growth.

Full recommendations are included in [`key_findings.md`](key_findings.md).

---

## Data Quality and Limitations

Several limitations were considered when interpreting the results:

- **2017 and 2020 are partial sales years**, so direct annual comparisons can be misleading. Like-for-like periods were used where appropriate.
- The profitability analysis measures **gross profit**, not net profit. Operating expenses, salaries, marketing costs, tax, and other overheads are not included.
- Missing ship dates are concentrated near the end of the available sales period and appear to be related to the dataset cutoff rather than random missing data.
- Very low Reseller profitability identifies an area for investigation, but additional commercial and operational cost data would be required to determine the exact cause.
- The analysis is based on the available AdventureWorks dataset and should not be interpreted as a full financial statement analysis.

---

## Project Structure

```text
AdventureWorks-Business-Analysis/
│
├── 00_connection_test.sql
├── 01_create_tables.sql
├── 02_import_validation.sql
├── 03_data_quality.sql
├── 04_relationship_validation.sql
├── 05_core_kpis.sql
├── 06_time_analysis.sql
├── 07_product_analysis.sql
├── 08_customer_analysis.sql
├── 09_reseller_channel_analysis.sql
├── 10_territory_analysis.sql
├── 11_powerbi_validation.sql
│
├── key_findings.md
├── README.md
│
├── data/
│   └── source CSV files
│
└── powerbi/
    └── AdventureWorks dashboard (.pbix)
```

---

## Validation Approach

SQL was used as the validation layer before finalising Power BI.

The Power BI model and DAX measures were checked against SQL benchmarks for:

- overall KPIs,
- sales channel,
- year,
- product category,
- territory group,
- customer counts,
- reseller counts,
- order counts,
- grand-total reconciliation.

This reduces the risk of presenting incorrect results caused by relationship, filter-context, or DAX issues.

---

## Skills Demonstrated

This project demonstrates practical experience with:

- relational data modelling,
- PostgreSQL,
- analytical SQL,
- joins and CTEs,
- aggregate functions,
- window functions,
- time-series analysis,
- data-quality validation,
- KPI design,
- business analysis,
- Power BI star-schema modelling,
- DAX measures,
- time intelligence,
- dashboard design,
- translating analysis into business recommendations.

---

## Final Conclusion

AdventureWorks has strong revenue, but the analysis shows that **revenue alone is not a sufficient measure of business success**.

The largest opportunity is to improve the profitability of existing revenue — particularly within the **Reseller channel and weak product segments** — while protecting the highly profitable **Internet channel, repeat customers, stronger products, and healthier market segments**.

The project therefore recommends making **profitable growth** the central management priority.
