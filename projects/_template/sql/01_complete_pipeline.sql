-- ============================================================
-- FULL STACK FINANCIAL INTELLIGENCE PLATFORM
-- SQL Pipeline: Staging → Transform → Warehouse → Views
-- Analyst: Abdul Hafeez | abdulhafeeznarejo/PowerBI-Developer
-- ============================================================

-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================
CREATE DATABASE FinanceDB;
GO
USE FinanceDB;
GO

-- Schemas
CREATE SCHEMA stg;  -- Staging (raw)
CREATE SCHEMA dw;   -- Data Warehouse (clean)
CREATE SCHEMA rpt;  -- Reporting Views
CREATE SCHEMA cfg;  -- Config & Metadata
GO

-- ============================================================
-- 2. STAGING LAYER — Raw Data (exact copy of CSV)
-- ============================================================
CREATE TABLE stg.Sales_Transactions (
    TransactionID       VARCHAR(20),
    Date                DATE,
    Year                INT,
    Month_Num           INT,
    Month_Name          VARCHAR(20),
    Quarter             VARCHAR(5),
    Product_ID          VARCHAR(10),
    Product_Name        VARCHAR(100),
    Category            VARCHAR(50),
    Customer_ID         VARCHAR(10),
    Customer_Name       VARCHAR(100),
    Region              VARCHAR(20),
    Segment             VARCHAR(20),
    Salesperson_ID      VARCHAR(10),
    Salesperson_Name    VARCHAR(100),
    Units_Sold          INT,
    Unit_Price          DECIMAL(18,2),
    Gross_Revenue       DECIMAL(18,2),
    Discount            DECIMAL(18,2),
    Net_Revenue         DECIMAL(18,2),
    COGS                DECIMAL(18,2),
    Gross_Profit        DECIMAL(18,2),
    GP_Margin_Pct       DECIMAL(10,4),
    Load_DateTime       DATETIME DEFAULT GETDATE()
);

CREATE TABLE stg.Budget (
    Year                INT,
    Month_Num           INT,
    Month_Name          VARCHAR(20),
    Quarter             VARCHAR(5),
    Region              VARCHAR(20),
    Product_ID          VARCHAR(10),
    Product_Name        VARCHAR(100),
    Category            VARCHAR(50),
    Budgeted_Revenue    DECIMAL(18,2),
    Budgeted_COGS       DECIMAL(18,2),
    Budgeted_GP         DECIMAL(18,2),
    Budgeted_Units      INT,
    Load_DateTime       DATETIME DEFAULT GETDATE()
);

CREATE TABLE stg.Products (
    Product_ID          VARCHAR(10),
    Product_Name        VARCHAR(100),
    Category            VARCHAR(50),
    Standard_Price      DECIMAL(18,2),
    COGS_Pct            DECIMAL(10,4),
    Launch_Year         INT,
    Load_DateTime       DATETIME DEFAULT GETDATE()
);

CREATE TABLE stg.Customers (
    Customer_ID         VARCHAR(10),
    Customer_Name       VARCHAR(100),
    Region              VARCHAR(20),
    Segment             VARCHAR(20),
    Credit_Limit_USD    DECIMAL(18,2),
    Since_Year          INT,
    Load_DateTime       DATETIME DEFAULT GETDATE()
);

CREATE TABLE stg.Salespeople (
    Salesperson_ID      VARCHAR(10),
    Salesperson_Name    VARCHAR(100),
    Region              VARCHAR(20),
    Annual_Target_USD   DECIMAL(18,2),
    Join_Year           INT,
    Load_DateTime       DATETIME DEFAULT GETDATE()
);
GO

-- ============================================================
-- 3. DATA WAREHOUSE — Dimension Tables
-- ============================================================

-- DimDate — full date dimension
CREATE TABLE dw.DimDate (
    DateKey             INT PRIMARY KEY,  -- YYYYMMDD
    Date                DATE,
    Year                INT,
    Month_Num           INT,
    Month_Name          VARCHAR(20),
    Quarter             VARCHAR(5),
    Day                 INT,
    Day_Name            VARCHAR(20),
    Day_Type            VARCHAR(10),  -- Weekday/Weekend
    Week_Num            INT,
    FY_Year             VARCHAR(10),
    FQ_Quarter          VARCHAR(10),
    Is_Year_End         BIT
);

-- DimProduct
CREATE TABLE dw.DimProduct (
    ProductKey          INT IDENTITY(1,1) PRIMARY KEY,
    Product_ID          VARCHAR(10),
    Product_Name        VARCHAR(100),
    Category            VARCHAR(50),
    Standard_Price      DECIMAL(18,2),
    COGS_Pct            DECIMAL(10,4),
    Launch_Year         INT,
    Is_Current          BIT DEFAULT 1,
    Created_Date        DATETIME DEFAULT GETDATE()
);

-- DimCustomer
CREATE TABLE dw.DimCustomer (
    CustomerKey         INT IDENTITY(1,1) PRIMARY KEY,
    Customer_ID         VARCHAR(10),
    Customer_Name       VARCHAR(100),
    Region              VARCHAR(20),
    Segment             VARCHAR(20),
    Credit_Limit_USD    DECIMAL(18,2),
    Since_Year          INT,
    Is_Current          BIT DEFAULT 1,
    Created_Date        DATETIME DEFAULT GETDATE()
);

-- DimSalesperson
CREATE TABLE dw.DimSalesperson (
    SalespersonKey      INT IDENTITY(1,1) PRIMARY KEY,
    Salesperson_ID      VARCHAR(10),
    Salesperson_Name    VARCHAR(100),
    Region              VARCHAR(20),
    Annual_Target_USD   DECIMAL(18,2),
    Join_Year           INT,
    Is_Current          BIT DEFAULT 1,
    Created_Date        DATETIME DEFAULT GETDATE()
);

-- ============================================================
-- 4. FACT TABLES
-- ============================================================

-- FactSales — main transaction fact
CREATE TABLE dw.FactSales (
    SalesKey            INT IDENTITY(1,1) PRIMARY KEY,
    Transaction_ID      VARCHAR(20),
    DateKey             INT FOREIGN KEY REFERENCES dw.DimDate(DateKey),
    ProductKey          INT FOREIGN KEY REFERENCES dw.DimProduct(ProductKey),
    CustomerKey         INT FOREIGN KEY REFERENCES dw.DimCustomer(CustomerKey),
    SalespersonKey      INT FOREIGN KEY REFERENCES dw.DimSalesperson(SalespersonKey),
    Units_Sold          INT,
    Unit_Price          DECIMAL(18,2),
    Gross_Revenue       DECIMAL(18,2),
    Discount_Amount     DECIMAL(18,2),
    Net_Revenue         DECIMAL(18,2),
    COGS                DECIMAL(18,2),
    Gross_Profit        DECIMAL(18,2),
    GP_Margin_Pct       DECIMAL(10,4),
    Load_DateTime       DATETIME DEFAULT GETDATE()
);

-- FactBudget
CREATE TABLE dw.FactBudget (
    BudgetKey           INT IDENTITY(1,1) PRIMARY KEY,
    DateKey             INT FOREIGN KEY REFERENCES dw.DimDate(DateKey),
    ProductKey          INT FOREIGN KEY REFERENCES dw.DimProduct(ProductKey),
    Region              VARCHAR(20),
    Budgeted_Revenue    DECIMAL(18,2),
    Budgeted_COGS       DECIMAL(18,2),
    Budgeted_GP         DECIMAL(18,2),
    Budgeted_Units      INT,
    Load_DateTime       DATETIME DEFAULT GETDATE()
);
GO

-- ============================================================
-- 5. INDEXES — Performance for Power BI DirectQuery
-- ============================================================
CREATE INDEX IX_FactSales_DateKey        ON dw.FactSales(DateKey);
CREATE INDEX IX_FactSales_ProductKey     ON dw.FactSales(ProductKey);
CREATE INDEX IX_FactSales_CustomerKey    ON dw.FactSales(CustomerKey);
CREATE INDEX IX_FactSales_SalespersonKey ON dw.FactSales(SalespersonKey);
CREATE INDEX IX_FactSales_Date_Revenue   ON dw.FactSales(DateKey) INCLUDE (Net_Revenue, Gross_Profit, COGS);
CREATE INDEX IX_FactBudget_DateKey       ON dw.FactBudget(DateKey);
GO

-- ============================================================
-- 6. ETL — STORED PROCEDURES
-- ============================================================

-- Load DimDate
CREATE OR ALTER PROCEDURE dw.sp_Load_DimDate
AS BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE dw.DimDate;
    
    DECLARE @date DATE = '2022-01-01';
    DECLARE @end  DATE = '2024-12-31';
    
    WHILE @date <= @end BEGIN
        INSERT INTO dw.DimDate
        SELECT
            CAST(FORMAT(@date,'yyyyMMdd') AS INT) AS DateKey,
            @date,
            YEAR(@date),
            MONTH(@date),
            DATENAME(MONTH,@date),
            'Q' + CAST(DATEPART(QUARTER,@date) AS VARCHAR),
            DAY(@date),
            DATENAME(WEEKDAY,@date),
            CASE WHEN DATEPART(WEEKDAY,@date) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END,
            DATEPART(ISO_WEEK,@date),
            CASE WHEN MONTH(@date)>=7 THEN 'FY'+CAST(YEAR(@date)+1 AS VARCHAR)
                 ELSE 'FY'+CAST(YEAR(@date) AS VARCHAR) END,
            'FQ' + CAST(((MONTH(@date)-7+12)%12)/3+1 AS VARCHAR),
            CASE WHEN MONTH(@date)=12 AND DAY(@date)=31 THEN 1 ELSE 0 END;
        SET @date = DATEADD(DAY,1,@date);
    END
    PRINT 'DimDate loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- Load Dimensions from Staging
CREATE OR ALTER PROCEDURE dw.sp_Load_Dimensions
AS BEGIN
    SET NOCOUNT ON;
    
    -- DimProduct
    MERGE dw.DimProduct AS tgt
    USING stg.Products AS src ON tgt.Product_ID = src.Product_ID
    WHEN MATCHED THEN UPDATE SET
        tgt.Product_Name  = src.Product_Name,
        tgt.Category      = src.Category,
        tgt.Standard_Price= src.Standard_Price,
        tgt.COGS_Pct      = src.COGS_Pct
    WHEN NOT MATCHED THEN INSERT
        (Product_ID,Product_Name,Category,Standard_Price,COGS_Pct,Launch_Year)
    VALUES
        (src.Product_ID,src.Product_Name,src.Category,src.Standard_Price,src.COGS_Pct,src.Launch_Year);

    -- DimCustomer
    MERGE dw.DimCustomer AS tgt
    USING stg.Customers AS src ON tgt.Customer_ID = src.Customer_ID
    WHEN MATCHED THEN UPDATE SET
        tgt.Customer_Name    = src.Customer_Name,
        tgt.Region           = src.Region,
        tgt.Segment          = src.Segment,
        tgt.Credit_Limit_USD = src.Credit_Limit_USD
    WHEN NOT MATCHED THEN INSERT
        (Customer_ID,Customer_Name,Region,Segment,Credit_Limit_USD,Since_Year)
    VALUES
        (src.Customer_ID,src.Customer_Name,src.Region,src.Segment,src.Credit_Limit_USD,src.Since_Year);

    -- DimSalesperson
    MERGE dw.DimSalesperson AS tgt
    USING stg.Salespeople AS src ON tgt.Salesperson_ID = src.Salesperson_ID
    WHEN MATCHED THEN UPDATE SET
        tgt.Salesperson_Name  = src.Salesperson_Name,
        tgt.Annual_Target_USD = src.Annual_Target_USD
    WHEN NOT MATCHED THEN INSERT
        (Salesperson_ID,Salesperson_Name,Region,Annual_Target_USD,Join_Year)
    VALUES
        (src.Salesperson_ID,src.Salesperson_Name,src.Region,src.Annual_Target_USD,src.Join_Year);

    PRINT 'Dimensions loaded successfully';
END;
GO

-- Load FactSales
CREATE OR ALTER PROCEDURE dw.sp_Load_FactSales
AS BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE dw.FactSales;

    INSERT INTO dw.FactSales (
        Transaction_ID, DateKey, ProductKey, CustomerKey, SalespersonKey,
        Units_Sold, Unit_Price, Gross_Revenue, Discount_Amount,
        Net_Revenue, COGS, Gross_Profit, GP_Margin_Pct)
    SELECT
        s.TransactionID,
        CAST(FORMAT(s.Date,'yyyyMMdd') AS INT),
        p.ProductKey,
        c.CustomerKey,
        sp.SalespersonKey,
        s.Units_Sold,
        s.Unit_Price,
        s.Gross_Revenue,
        s.Discount,
        s.Net_Revenue,
        s.COGS,
        s.Gross_Profit,
        s.GP_Margin_Pct
    FROM stg.Sales_Transactions s
    JOIN dw.DimProduct    p  ON s.Product_ID     = p.Product_ID
    JOIN dw.DimCustomer   c  ON s.Customer_ID    = c.Customer_ID
    JOIN dw.DimSalesperson sp ON s.Salesperson_ID = sp.Salesperson_ID;

    PRINT 'FactSales loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- Load FactBudget
CREATE OR ALTER PROCEDURE dw.sp_Load_FactBudget
AS BEGIN
    SET NOCOUNT ON;
    TRUNCATE TABLE dw.FactBudget;

    INSERT INTO dw.FactBudget (
        DateKey, ProductKey, Region,
        Budgeted_Revenue, Budgeted_COGS, Budgeted_GP, Budgeted_Units)
    SELECT
        CAST(FORMAT(DATEFROMPARTS(b.Year,b.Month_Num,1),'yyyyMMdd') AS INT),
        p.ProductKey,
        b.Region,
        b.Budgeted_Revenue,
        b.Budgeted_COGS,
        b.Budgeted_GP,
        b.Budgeted_Units
    FROM stg.Budget b
    JOIN dw.DimProduct p ON b.Product_ID = p.Product_ID;

    PRINT 'FactBudget loaded: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows';
END;
GO

-- MASTER REFRESH — run this one proc to refresh everything
CREATE OR ALTER PROCEDURE dw.sp_Master_Refresh
AS BEGIN
    SET NOCOUNT ON;
    PRINT 'Starting master refresh: ' + CAST(GETDATE() AS VARCHAR);

    EXEC dw.sp_Load_DimDate;
    EXEC dw.sp_Load_Dimensions;
    EXEC dw.sp_Load_FactSales;
    EXEC dw.sp_Load_FactBudget;

    PRINT 'Master refresh complete: ' + CAST(GETDATE() AS VARCHAR);
END;
GO

-- ============================================================
-- 7. REPORTING VIEWS — Power BI connects to these
-- ============================================================

-- Revenue Performance View
CREATE OR ALTER VIEW rpt.vw_Revenue_Performance AS
SELECT
    d.Date,
    d.Year,
    d.Month_Name,
    d.Quarter,
    d.FY_Year,
    p.Product_Name,
    p.Category,
    c.Customer_Name,
    c.Region,
    c.Segment,
    sp.Salesperson_Name,
    f.Units_Sold,
    f.Unit_Price,
    f.Gross_Revenue,
    f.Discount_Amount,
    f.Net_Revenue,
    f.COGS,
    f.Gross_Profit,
    f.GP_Margin_Pct
FROM dw.FactSales f
JOIN dw.DimDate        d  ON f.DateKey        = d.DateKey
JOIN dw.DimProduct     p  ON f.ProductKey     = p.ProductKey
JOIN dw.DimCustomer    c  ON f.CustomerKey    = c.CustomerKey
JOIN dw.DimSalesperson sp ON f.SalespersonKey = sp.SalespersonKey;
GO

-- Budget vs Actual View
CREATE OR ALTER VIEW rpt.vw_Budget_vs_Actual AS
SELECT
    d.Year,
    d.Month_Num,
    d.Month_Name,
    d.Quarter,
    p.Product_Name,
    p.Category,
    b.Region,
    b.Budgeted_Revenue,
    b.Budgeted_GP,
    b.Budgeted_Units,
    ISNULL(SUM(f.Net_Revenue),0)    AS Actual_Revenue,
    ISNULL(SUM(f.Gross_Profit),0)   AS Actual_GP,
    ISNULL(SUM(f.Units_Sold),0)     AS Actual_Units,
    ISNULL(SUM(f.Net_Revenue),0) - b.Budgeted_Revenue AS Revenue_Variance,
    CASE WHEN b.Budgeted_Revenue > 0
         THEN ROUND((ISNULL(SUM(f.Net_Revenue),0) - b.Budgeted_Revenue) / b.Budgeted_Revenue * 100, 2)
         ELSE 0 END                 AS Revenue_Variance_Pct,
    CASE WHEN b.Budgeted_Revenue > 0
         THEN ROUND(ISNULL(SUM(f.Net_Revenue),0) / b.Budgeted_Revenue * 100, 2)
         ELSE 0 END                 AS Budget_Attainment_Pct
FROM dw.FactBudget b
JOIN dw.DimDate    d ON b.DateKey    = d.DateKey
JOIN dw.DimProduct p ON b.ProductKey = p.ProductKey
LEFT JOIN dw.FactSales f
    ON  f.DateKey    = b.DateKey
    AND f.ProductKey = b.ProductKey
GROUP BY
    d.Year, d.Month_Num, d.Month_Name, d.Quarter,
    p.Product_Name, p.Category, b.Region,
    b.Budgeted_Revenue, b.Budgeted_GP, b.Budgeted_Units;
GO

-- Executive KPI View
CREATE OR ALTER VIEW rpt.vw_Executive_KPIs AS
SELECT
    d.Year,
    d.Quarter,
    SUM(f.Net_Revenue)      AS Total_Revenue,
    SUM(f.Gross_Profit)     AS Total_GP,
    SUM(f.COGS)             AS Total_COGS,
    SUM(f.Units_Sold)       AS Total_Units,
    COUNT(*)                AS Transaction_Count,
    ROUND(SUM(f.Gross_Profit)/NULLIF(SUM(f.Net_Revenue),0)*100,2) AS GM_Pct,
    COUNT(DISTINCT f.CustomerKey) AS Active_Customers
FROM dw.FactSales f
JOIN dw.DimDate d ON f.DateKey = d.DateKey
GROUP BY d.Year, d.Quarter;
GO

-- Window Functions View — for advanced analytics
CREATE OR ALTER VIEW rpt.vw_Advanced_Analytics AS
SELECT
    d.Date,
    d.Year,
    d.Month_Name,
    p.Product_Name,
    c.Region,
    f.Net_Revenue,
    f.Gross_Profit,
    -- Running total
    SUM(f.Net_Revenue) OVER (
        PARTITION BY d.Year
        ORDER BY d.Date
        ROWS UNBOUNDED PRECEDING)           AS Running_Total_Revenue,
    -- YoY comparison
    LAG(f.Net_Revenue, 365) OVER (
        ORDER BY d.Date)                    AS Revenue_Same_Day_LY,
    -- Moving average 30 days
    AVG(f.Net_Revenue) OVER (
        ORDER BY d.Date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS Revenue_30D_MA,
    -- Rank by product
    RANK() OVER (
        PARTITION BY d.Year
        ORDER BY f.Net_Revenue DESC)        AS Revenue_Rank,
    -- % of total
    ROUND(f.Net_Revenue /
        SUM(f.Net_Revenue) OVER () * 100, 4) AS Revenue_Pct_Total
FROM dw.FactSales f
JOIN dw.DimDate        d  ON f.DateKey    = d.DateKey
JOIN dw.DimProduct     p  ON f.ProductKey = p.ProductKey
JOIN dw.DimCustomer    c  ON f.CustomerKey= c.CustomerKey;
GO

-- ============================================================
-- 8. RUN EVERYTHING
-- ============================================================
EXEC dw.sp_Master_Refresh;
GO

SELECT 'Pipeline complete!' AS Status,
       GETDATE() AS Timestamp,
       (SELECT COUNT(*) FROM dw.FactSales)  AS FactSales_Rows,
       (SELECT COUNT(*) FROM dw.FactBudget) AS FactBudget_Rows,
       (SELECT COUNT(*) FROM dw.DimDate)    AS DimDate_Rows;
GO
