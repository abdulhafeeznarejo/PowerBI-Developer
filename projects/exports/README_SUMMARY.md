SalesDB Cleanup & Upgrade — Summary (2026-06-24)

Overview
- Performed a backup, data-quality checks, schema upgrades, and generated aggregation reports for the `SalesDB` database.

Backups (CSV files created)
- projects/exports/fact_Sales.csv
- projects/exports/dim_Customer.csv
- projects/exports/dim_Product.csv

Aggregation reports (CSV)
- projects/exports/agg_monthly_sales.csv — monthly totals
- projects/exports/agg_top_products.csv — sales by product
- projects/exports/agg_top_customers.csv — sales by customer
- projects/exports/agg_sales_by_channel.csv — sales by channel

Scripts and docs
- projects/tools/json_to_csv.py — helper to convert query JSON to CSV
- projects/exports/README_Cleanup_Upgrade.md — detailed notes

Schema work applied
- Added nonclustered indexes: IX_fact_Sales_DateKey, IX_fact_Sales_CustomerID, IX_fact_Sales_ProductID, IX_fact_Sales_Date_Product, IX_fact_Sales_Customer_SalesPerson, IX_dim_Customer_CustomerName, IX_dim_Product_ProductName
- Added check constraints to `fact_Sales`: CHK_fact_Sales_Quantity_NonNegative (Quantity >= 0), CHK_fact_Sales_DiscountPct_Range (DiscountPct between 0 and 1)

Data quality
- No nulls found in key columns checked
- No duplicate primary keys detected
- No negative quantities or invalid DiscountPct values found

Git
- Commit: ab2e429 (message: "salesdb")
- Tag: v2026-06-24-salesdb

Next steps (suggested)
- Create a GitHub release for the tag (I can do this)
- Build a Power BI report using the exported CSVs
- Apply optional automated cleaning (string trim/casing, default fills)

If you want a different README location or more detail, tell me where and what to include.
