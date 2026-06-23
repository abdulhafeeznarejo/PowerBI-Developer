Summary of cleanup and upgrade actions

Backups (CSV files created):
- projects/exports/fact_Sales.csv
- projects/exports/dim_Customer.csv
- projects/exports/dim_Product.csv
- projects/exports/agg_monthly_sales.csv
- projects/exports/agg_top_products.csv
- projects/exports/agg_top_customers.csv
- projects/exports/agg_sales_by_channel.csv

Data quality checks performed:
- Checked nulls for key columns in `fact_Sales`, `dim_Customer`, `dim_Product` — no nulls found in checked columns.
- Checked duplicate primary keys — none found.
- Checked for negative `Quantity` or invalid `DiscountPct` — zero violations.

Schema changes applied:
- Created nonclustered indexes: IX_fact_Sales_DateKey, IX_fact_Sales_CustomerID, IX_fact_Sales_ProductID
- Added nonclustered indexes: IX_fact_Sales_Date_Product (DateKey, ProductID), IX_fact_Sales_Customer_SalesPerson (CustomerID, SalesPersonID)
- Created nonclustered indexes on dimensions: IX_dim_Customer_CustomerName, IX_dim_Product_ProductName
- Added check constraints on `fact_Sales`:
  - CHK_fact_Sales_Quantity_NonNegative (Quantity >= 0)
  - CHK_fact_Sales_DiscountPct_Range (DiscountPct >= 0 AND DiscountPct <= 1)

Files and helper scripts:
- projects/tools/json_to_csv.py — helper to convert query JSON to CSV

Validation steps executed:
- Confirmed indexes and constraints exist via system catalog queries.
- Generated aggregation reports for quick sanity checks.

Notes:
- If you'd like these CSVs committed to git, tell me and I'll create a commit.
- I avoided changing data values; if you want me to apply automated cleaning transformations (trim strings, normalize casing, fill nulls), specify rules.
