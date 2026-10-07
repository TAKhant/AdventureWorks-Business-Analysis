# AdventureWorks Business Analysis — Data Dictionary

## 1. Sales_data

**Table Type:** Fact table

**Purpose:**  
Main sales fact table containing transaction-level measures and the keys needed to connect sales records to product, customer, reseller, date, and sales territory dimensions.

**Grain:**  
One row represents one sales order line.

**Primary Key:**  
`SalesOrderLineKey`

**Foreign Keys:**  
- `ResellerKey`
- `CustomerKey`
- `ProductKey`
- `OrderDateKey`
- `DueDateKey`
- `ShipDateKey`
- `SalesTerritoryKey`

**Important Columns:**  
- `Order Quantity`
- `Unit Price`
- `Extended Amount`
- `Unit Price Discount Pct`
- `Product Standard Cost`
- `Total Product Cost`
- `Sales Amount`

**Main Relationships:**  
- `ProductKey` → `Product_data`
- `CustomerKey` → `Customer_data`
- `ResellerKey` → `Reseller_data`
- `SalesTerritoryKey` → `Sales Territory_data`
- `OrderDateKey`, `DueDateKey`, `ShipDateKey` → `Date_data`
- `SalesOrderLineKey` → `Sales Order_data`

---

## 2. Product_data

**Table Type:** Dimension table

**Purpose:**  
Stores descriptive information about each product, including product name, SKU, cost, list price, colour, model, subcategory, and category.

**Grain:**  
One row represents one product.

**Primary Key:**  
`ProductKey`

**Foreign Keys:**  
None in this table.

**Important Columns:**  
- `Product`
- `SKU`
- `Standard Cost`
- `List Price`
- `Color`
- `Model`
- `Subcategory`
- `Category`

**Main Relationship:**  
- `ProductKey` → `Sales_data`

---

## 3. Customer_data

**Table Type:** Dimension table

**Purpose:**  
Stores descriptive information about direct customers who purchase through the Internet sales channel.

**Grain:**  
One row represents one customer.

**Primary Key:**  
`CustomerKey`

**Foreign Keys:**  
None in this table.

**Important Columns:**  
- `Customer`
- `Customer ID`
- `City`
- `State-Province`
- `Country-Region`
- `Postal Code`

**Main Relationship:**  
- `CustomerKey` → `Sales_data`

**Modelling Note:**  
`CustomerKey = -1` represents `[Not Applicable]`. This is intentional for reseller-channel sales, where there is no direct Internet customer attached to the sales row.

---

## 4. Reseller_data

**Table Type:** Dimension table

**Purpose:**  
Stores descriptive information about reseller businesses that sell AdventureWorks products through the reseller sales channel.

**Grain:**  
One row represents one reseller.

**Primary Key:**  
`ResellerKey`

**Foreign Keys:**  
None in this table.

**Important Columns:**  
- `Reseller`
- `Reseller ID`
- `Business Type`
- `City`
- `State-Province`
- `Country-Region`
- `Postal Code`

**Main Relationship:**  
- `ResellerKey` → `Sales_data`

**Modelling Note:**  
`ResellerKey = -1` represents `[Not Applicable]`. This is intentional for Internet sales, where no reseller is involved.

---

## 5. Sales Territory_data

**Table Type:** Dimension table

**Purpose:**  
Stores descriptive information about the geographic sales territory associated with each transaction.

**Grain:**  
One row represents one sales territory.

**Primary Key:**  
`SalesTerritoryKey`

**Foreign Keys:**  
None in this table.

**Important Columns:**  
- `Region`
- `Country`
- `Group`

**Main Relationship:**  
- `SalesTerritoryKey` → `Sales_data`

---

## 6. Date_data

**Table Type:** Dimension table

**Purpose:**  
Stores calendar and fiscal date information used to analyse sales over time.

**Grain:**  
One row represents one calendar date.

**Primary Key:**  
`DateKey`

**Foreign Keys:**  
None in this table.

**Important Columns:**  
- `Date`
- `Full Date`
- `Fiscal Year`
- `Fiscal Quarter`
- `Month`
- `MonthKey`

**Main Relationships:**  
- `DateKey` → `Sales_data.OrderDateKey`
- `DateKey` → `Sales_data.DueDateKey`
- `DateKey` → `Sales_data.ShipDateKey`

**Modelling Note:**  
The sales fact table has three different date keys. In Power BI, `OrderDateKey` will normally be the main active relationship for sales analysis, while the other date relationships may be inactive unless specifically needed.

---

## 7. Sales Order_data

**Table Type:** Dimension / lookup table at sales-order-line level

**Purpose:**  
Stores sales order identifiers and identifies whether each sales order line belongs to the Internet or Reseller channel. It does not contain the main financial sales measures; those are stored in `Sales_data`.

**Grain:**  
One row represents one sales order line.

**Primary Key:**  
`SalesOrderLineKey`

**Foreign Keys:**  
None in this table.

**Important Columns:**  
- `Channel`
- `Sales Order`
- `Sales Order Line`

**Main Relationship:**  
- `SalesOrderLineKey` → `Sales_data`

**Modelling Note:**  
`Sales Order` can repeat because one sales order can contain multiple order lines. `SalesOrderLineKey` uniquely identifies each individual line.

---

# Key Data Model Notes

- `Sales_data` is the central fact table.
- Product, customer, reseller, territory, and date tables are descriptive dimensions.
- `Sales Order_data` supplies order-level identifiers and the `Channel` classification.
- Internet sales use a real `CustomerKey` and `ResellerKey = -1`.
- Reseller sales use a real `ResellerKey` and `CustomerKey = -1`.
- The value `-1` means **Not Applicable**, not missing or corrupted data.
- The dataset supports analysis across product, customer, reseller, territory, channel, and time.
