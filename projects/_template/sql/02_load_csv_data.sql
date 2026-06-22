-- ============================================================
-- 02_LOAD_CSV_DATA.sql
-- Loads all 6 CSV files into staging tables, then runs pipeline
-- Analyst: Abdul Hafeez
-- ============================================================

USE FinanceDB;
GO

-- ============================================================
-- 1. CLEAR STAGING TABLES (in case of re-run)
-- ============================================================
TRUNCATE TABLE stg.Sales_Transactions;
TRUNCATE TABLE stg.Budget;
TRUNCATE TABLE stg.Products;
TRUNCATE TABLE stg.Customers;
TRUNCATE TABLE stg.Salespeople;
GO

-- ============================================================
-- 2. BULK INSERT — Sales_Transactions.csv
-- ============================================================
BULK INSERT stg.Sales_Transactions
FROM 'C:\Users\Abdul Hafeez\PowerBI-Developer\projects\_template\data\raw\Sales_Transactions.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,              -- skip header row
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',        -- UTF-8
    TABLOCK
);
PRINT 'Sales_Transactions loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- 3. BULK INSERT — Budget.csv
-- ============================================================
BULK INSERT stg.Budget
FROM 'C:\Users\Abdul Hafeez\PowerBI-Developer\projects\_template\data\raw\Budget.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
PRINT 'Budget loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- 4. BULK INSERT — Products.csv
-- ============================================================
BULK INSERT stg.Products
FROM 'C:\Users\Abdul Hafeez\PowerBI-Developer\projects\_template\data\raw\Products.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
PRINT 'Products loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- 5. BULK INSERT — Customers.csv
-- ============================================================
BULK INSERT stg.Customers
FROM 'C:\Users\Abdul Hafeez\PowerBI-Developer\projects\_template\data\raw\Customers.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
PRINT 'Customers loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- 6. BULK INSERT — Salespeople.csv
-- ============================================================
BULK INSERT stg.Salespeople
FROM 'C:\Users\Abdul Hafeez\PowerBI-Developer\projects\_template\data\raw\Salespeople.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
PRINT 'Salespeople loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
GO

-- ============================================================
-- 7. VERIFY STAGING DATA LOADED
-- ============================================================
SELECT 'stg.Sales_Transactions' AS TableName, COUNT(*) AS RowCount FROM stg.Sales_Transactions
UNION ALL
SELECT 'stg.Budget', COUNT(*) FROM stg.Budget
UNION ALL
SELECT 'stg.Products', COUNT(*) FROM stg.Products
UNION ALL
SELECT 'stg.Customers', COUNT(*) FROM stg.Customers
UNION ALL
SELECT 'stg.Salespeople', COUNT(*) FROM stg.Salespeople;
GO

-- ============================================================
-- 8. RUN MASTER REFRESH — moves staging data into star schema
-- ============================================================
EXEC dw.sp_Master_Refresh;
GO

-- ============================================================
-- 9. FINAL VERIFICATION — should show real row counts now
-- ============================================================
SELECT 
    'Pipeline complete with data!' AS Status,
    GETDATE() AS Timestamp,
    (SELECT COUNT(*) FROM dw.FactSales)  AS FactSales_Rows,
    (SELECT COUNT(*) FROM dw.FactBudget) AS FactBudget_Rows,
    (SELECT COUNT(*) FROM dw.DimDate)    AS DimDate_Rows,
    (SELECT COUNT(*) FROM dw.DimProduct) AS DimProduct_Rows,
    (SELECT COUNT(*) FROM dw.DimCustomer) AS DimCustomer_Rows,
    (SELECT COUNT(*) FROM dw.DimSalesperson) AS DimSalesperson_Rows;
GO

-- ============================================================
-- 10. SAMPLE QUERY — test a reporting view
-- ============================================================
SELECT TOP 10 *
FROM rpt.vw_Executive_KPIs
ORDER BY Year, Quarter;
GO
