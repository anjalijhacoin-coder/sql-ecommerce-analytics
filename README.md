# sql-ecommerce-analytics
Advanced SQL project analyzing an e-commerce datamart. Covers customer LTV, cohort retention, inventory valuation, and supply chain metrics using CTEs and window functions.
# E-Commerce Data Warehouse & Analytics Pipeline (T-SQL)

An end-to-end data warehousing and analytics project built from scratch in **Microsoft SQL Server (SSMS)**. This project implements a modern multi-layer architecture—transitioning raw operational data into a clean, audited analytics datamart—and answers 22 complex business intelligence questions using advanced T-SQL.

---

## 🏗️ Architecture & Data Flow

The data pipeline is split into distinct logical layers to ensure scalability, data integrity, and clean separation of concerns:

1. **Raw Layer (`ec_core`):** 
   - Lands raw transactional source data using defensive data types (`NVARCHAR`) to prevent ingestion failures caused by dirty source records, missing formatting, or trailing text.
2. **Datamart Layer (`ec_datamart`):** 
   - Populated via a robust, idempotent stored procedure (`sp_clean_datamart`) that standardizes text casing, handles whitespace, parses JSON metadata, converts unit measures (e.g., weights/dimensions), and enforces primary keys and strict schema constraints.
3. **Data Quality & Audit Layer:** 
   - Automated testing scripts that validate uniqueness, check for mandatory nulls, catch negative values or invalid dates, and ensure cross-column financial math integrity.
4. **Analytics Layer:** 
   - 22 high-impact analytical queries leveraging advanced window functions and CTEs to extract deep business insights.

---

## 📂 Repository Structure

```text
sql-ecommerce-analytics/
├── datasets/                     -- Raw source data files
├── docs/                         -- Architecture notes & data dictionaries
└── scripts/
    ├── raw/
    │   └── create_tables.sql     -- Bronze layer DDL setup script
    ├── clean/
    │   ├── sp_clean_datamart.sql -- Silver/Gold ETL transformation procedure
    │   └── audit_datamart.sql    -- Post-load data quality validation suite
    └── analytics/
        └── analytics_insights.sql-- 22 Advanced BI & analytical queries
