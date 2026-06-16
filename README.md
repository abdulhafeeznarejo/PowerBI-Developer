

<div align="center">
⚡ PowerBI-Developer — Financial Analytics Workspace

  A production-grade Power BI development environment built for financial analytics.

Structured workspace · 60+ DAX measures · Custom CLI tooling · Professional dashboards
</div>

👤 About

Abdul Hafeez — Financial Analyst & Power BI Developer (PL-300 Certified)

Available for freelance · LinkedIn · Upwork


"I don't just build dashboards — I build financial intelligence systems."



📊 Live Dashboard — Finance Analytics

Page 1 · Revenue Overview

KPIValueTotal Revenue$5.28MTotal Gross Profit$3.12MGross Margin %59%YoY Growth %53%

Visuals built:


4 KPI cards — Revenue, Gross Profit, Margin %, YoY Growth
Bar chart — Revenue by Product (10 products ranked)
Line chart — Total Revenue trend 2022 → 2024
Region slicer — Central, East, North, South, West
Year slicer — 2022, 2023, 2024


Key insight: ERP License & Laptop Pro 15 are top revenue drivers at $1.5M+ each.

Trend: Consistent revenue growth from 2022 to 2024 across all regions.


Page 2 · Executive Single Page

MetricValueGross Margin YTD0.60Performance Category🥇 ExcellentYoY Traffic Light🟢 Strong Growth

Visuals built:


Company branding (FINTECH logo)
Dynamic KPI cards with DAX SWITCH logic
Product Revenue Ranking table (RANKX — 1 to 10)
Performance category using emoji traffic lights


Key insight: ERP License ranks #1, Wireless Mouse ranks #10.

Status: Business performing at Excellent tier — 60%+ gross margin sustained.


🗂️ Workspace Structure

PowerBI-Developer/
├── projects/
│   └── _template/
│       ├── reports/          → .pbix Power BI files
│       ├── datasets/         → Source data files
│       ├── dax/              → DAX measure files
│       ├── dataflows/        → Dataflow JSON exports
│       ├── exports/          → PDF / PNG outputs
│       ├── docs/             → Documentation
│       └── data/
│           ├── raw/          → Original CSV files
│           └── processed/    → Cleaned data
├── shared/
│   ├── dax-library/          → 60+ reusable DAX measures
│   ├── themes/               → financial_theme.json
│   └── custom-visuals/       → .pbiviz files
├── tools/
│   └── pbi-cli.bat           → Custom CLI tool
└── archive/                  → Old versions


📐 Data Model — Star Schema

                    ┌─────────────┐
                    │  Date_Table │
                    │  (1,096 rows)│
                    └──────┬──────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
   ┌──────┴──────┐  ┌──────┴──────┐  ┌─────┴──────┐
   │  Products   │  │    FACT     │  │  Customers │
   │  (10 rows)  │──│  Sales_Txn  │──│  (12 rows) │
   └─────────────┘  │ (4,337 rows)│  └────────────┘
                    └──────┬──────┘
                    │              │
             ┌──────┴─────┐ ┌─────┴──────┐
             │ Salespeople│ │   Budget   │
             │  (6 rows)  │ │(1,800 rows)│
             └────────────┘ └────────────┘

6 tables · 7,261 total rows · 3 years of data (2022–2024)


🧮 DAX Measures Library (60+)

Organized across 9 chapters from Power BI for Advanced Finance by Hayden Van Der Post:

ChapterMeasuresExamples1 · Aggregations9Total Revenue, Transaction Count, Distinct Customers2 · Margins & Ratios8Gross Margin %, Revenue per Customer, Profit per Unit3 · Time Intelligence14Revenue YTD, YoY Growth %, Revenue 12M Rolling4 · Budget vs Actual11Revenue Variance $, Budget Attainment %, Budget RAG Status5 · CALCULATE & Filters11Revenue % of Total, Revenue North, Revenue Enterprise6 · Ranking5Product Revenue Rank, Salesperson Rank, Customer Rank7 · Advanced DAX6Revenue Running Total, Pareto Flag, Cumulative Revenue %8 · Financial KPIs3Gross Margin YTD, Performance Category, YoY Traffic Light9 · Variables & Labels5Dynamic KPI Card, Revenue Label, Selected Period

Key DAX patterns used:

dax-- Time Intelligence
Revenue YTD = TOTALYTD([Total Revenue], 'Date_Table'[Date])

-- Dynamic Performance Category
Performance Category =
SWITCH(
    TRUE(),
    [Gross Margin %] >= 0.50, "🥇 Excellent",
    [Gross Margin %] >= 0.40, "🥈 Good",
    [Gross Margin %] >= 0.30, "🥉 Average",
    "⚠️ Poor"
)

-- RANKX Product Ranking
Product Revenue Rank =
RANKX(ALL(Sales_Transactions[Product_Name]), [Total Revenue], , DESC, Dense)


🔧 CLI Tool — pbi-cli

Custom command-line tool for daily Power BI development workflow:

cmdpbi-cli new-project FinanceDashboard   → Scaffold new project
pbi-cli list                           → List all projects
pbi-cli dax revenue                    → Search DAX library
pbi-cli csv-to-json Sales_Data.csv     → Convert data format
pbi-cli status                         → Check all tools
pbi-cli serve ProjectName              → Local HTTP server


🎨 Theme

Custom financial_theme.json applied — professional navy/blue color system:

ElementColorPrimary#1F3864 — Dark NavySecondary#2E75B6 — Professional BlueAccent#70AD47 — Growth GreenWarning#FFC000 — AmberDanger#FF0000 — Red


🛠️ Tech Stack

ToolPurposePower BI DesktopReport developmentDAXBusiness calculationsPower Query (M)Data transformationNode.js + npmCLI toolingpbivizCustom visual developmentGit + GitHubVersion controlPython (planned)Advanced visuals & MLR (planned)Statistical charts


🗺️ Roadmap


 Workspace setup & CLI tooling
 6 CSV data sources (4,337 transaction rows)
 Star schema data model
 60+ DAX measures (9 chapters)
 Financial theme (JSON)
 Page 1 — Revenue Overview
 Page 2 — Executive Single Page
 Page 3 — P&L Statement
 Page 4 — Budget vs Actual
 Page 5 — Sales Performance
 Row Level Security (RLS)
 Publish to Power BI Service
 Python & R visuals
 Power Automate alerts
 Paginated reports



📁 Data Sources

FileRowsDescriptionSales_Transactions.csv4,337Main fact table — 3 years transactionsBudget.csv1,800Monthly budget by product & regionDate_Table.csv1,096Full date dimension with FY supportProducts.csv10Product catalog with COGS %Customers.csv12Customer master with segmentSalespeople.csv6Sales team with annual targets


📬 Contact

Abdul Hafeez

Financial Analyst & Power BI Developer · PL-300 Certified


<div align="center">
<i>Built with Power BI · DAX · Financial Domain Expertise</i>
</div>
