"""
================================================================
CSV TO SQL SERVER LOADER
Loads all 6 CSV files into FinanceDB staging tables
Analyst: Abdul Hafeez
================================================================

SETUP (run once in Command Prompt):
    pip install pyodbc pandas

USAGE:
    python load_csv_to_sql.py
"""

import pyodbc
import pandas as pd
import os
import sys

# ── CONFIG ───────────────────────────────────────────────────
SERVER   = r"(localdb)\MSSQLLocalDB"
DATABASE = "FinanceDB"
CSV_PATH = r"C:\Users\Abdul Hafeez\PowerBI-Developer\projects\_template\data\raw"

CONN_STRING = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    f"Trusted_Connection=yes;"
)

# Table -> CSV file -> expected columns (in order)
TABLES = {
    "stg.Sales_Transactions": {
        "file": "Sales_Transactions.csv",
        "columns": ["TransactionID","Date","Year","Month_Num","Month_Name","Quarter",
                    "Product_ID","Product_Name","Category","Customer_ID","Customer_Name",
                    "Region","Segment","Salesperson_ID","Salesperson_Name","Units_Sold",
                    "Unit_Price","Gross_Revenue","Discount","Net_Revenue","COGS",
                    "Gross_Profit","GP_Margin_Pct"]
    },
    "stg.Budget": {
        "file": "Budget.csv",
        "columns": ["Year","Month_Num","Month_Name","Quarter","Region","Product_ID",
                    "Product_Name","Category","Budgeted_Revenue","Budgeted_COGS",
                    "Budgeted_GP","Budgeted_Units"]
    },
    "stg.Products": {
        "file": "Products.csv",
        "columns": ["Product_ID","Product_Name","Category","Standard_Price",
                    "COGS_Pct","Launch_Year"]
    },
    "stg.Customers": {
        "file": "Customers.csv",
        "columns": ["Customer_ID","Customer_Name","Region","Segment",
                    "Credit_Limit_USD","Since_Year"]
    },
    "stg.Salespeople": {
        "file": "Salespeople.csv",
        "columns": ["Salesperson_ID","Salesperson_Name","Region",
                    "Annual_Target_USD","Join_Year"]
    },
}


def connect():
    print(f"Connecting to {SERVER} / {DATABASE} ...")
    try:
        conn = pyodbc.connect(CONN_STRING)
        print("✅ Connected successfully\n")
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        print("\nTip: Make sure 'ODBC Driver 17 for SQL Server' is installed.")
        print("Download: https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server")
        sys.exit(1)


def load_table(conn, table_name, csv_file, expected_cols):
    full_path = os.path.join(CSV_PATH, csv_file)

    if not os.path.exists(full_path):
        print(f"  ❌ File not found: {full_path}")
        return 0

    df = pd.read_csv(full_path)
    df = df.where(pd.notnull(df), None)  # NaN -> None for SQL NULL

    cursor = conn.cursor()

    # Clear table first
    cursor.execute(f"TRUNCATE TABLE {table_name}")
    conn.commit()

    # Build insert statement
    placeholders = ", ".join(["?"] * len(expected_cols))
    col_list = ", ".join(expected_cols)
    insert_sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

    # Insert row by row (fast_executemany for speed)
    cursor.fast_executemany = True
    rows = df[expected_cols].values.tolist()

    # Convert pandas Timestamps to python date strings for Date columns
    for row in rows:
        for i, val in enumerate(row):
            if pd.isna(val):
                row[i] = None

    cursor.executemany(insert_sql, rows)
    conn.commit()

    print(f"  ✅ {table_name}: {len(rows)} rows loaded")
    return len(rows)


def run_master_refresh(conn):
    print("\n🔄 Running dw.sp_Master_Refresh ...")
    cursor = conn.cursor()
    cursor.execute("EXEC dw.sp_Master_Refresh")
    conn.commit()
    print("✅ Master refresh complete\n")


def verify(conn):
    print("📊 Final verification:")
    cursor = conn.cursor()
    checks = [
        ("dw.FactSales", "FactSales"),
        ("dw.FactBudget", "FactBudget"),
        ("dw.DimDate", "DimDate"),
        ("dw.DimProduct", "DimProduct"),
        ("dw.DimCustomer", "DimCustomer"),
        ("dw.DimSalesperson", "DimSalesperson"),
    ]
    for table, label in checks:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {label:20s}: {count:,} rows")


if __name__ == "__main__":
    print("=" * 60)
    print("  CSV TO SQL SERVER LOADER — FinanceDB")
    print("=" * 60)
    print()

    conn = connect()

    print("📥 Loading CSV files into staging tables...\n")
    total = 0
    for table_name, info in TABLES.items():
        total += load_table(conn, table_name, info["file"], info["columns"])

    print(f"\n✅ Total rows loaded into staging: {total:,}")

    run_master_refresh(conn)
    verify(conn)

    conn.close()
    print("\n" + "=" * 60)
    print("  ALL DONE! Your SQL database is ready.")
    print("=" * 60)
