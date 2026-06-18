# 📚 Gravity Books — Data Warehouse & Analytics Project

A full end-to-end Data Warehousing project built on the **Gravity Books** bookstore database, covering OLTP source design, Star Schema DWH, SSIS ETL pipelines, and an SSAS multidimensional cube for analytics.

> **Solo Project** | Built at ITI Egypt — Data Engineering Track

---

## 📋 Project Overview

This project transforms a normalized OLTP bookstore database into an analytics-ready Data Warehouse using the Microsoft BI stack. It demonstrates the complete data engineering lifecycle from source system design to OLAP cube deployment.

### What this project covers

- **OLTP Source Database** — Full bookstore transactional database (customers, orders, books, authors, shipping)
- **Star Schema DWH** — Dimensional model with SCD Type 2 slowly changing dimensions
- **SSIS ETL Pipelines** — 11 automated packages loading all dimensions and facts
- **SSAS Cube** — Multidimensional OLAP cube over `fact_order_process` with 10+ dimensions
- **SQL Analytics** — Source exploration, DWH validation, and process tracking queries

---

## 🏗️ Architecture

```
OLTP Source (gravity_books)
        │
        ▼  [SSIS ETL Packages]
 ┌─────────────────────────────────────────┐
 │         gravity_books_DWH               │
 │                                         │
 │  Dimensions:                            │
 │  • dim_customer      (SCD Type 2)       │
 │  • dim_address       (SCD Type 2)       │
 │  • dim_book          (SCD Type 2)       │
 │  • dim_author                           │
 │  • dim_book_author   (bridge)           │
 │  • dim_shipping_method (SCD Type 2)     │
 │  • dim_customer_address (bridge)        │
 │  • Dim_Date                             │
 │  • Dim_Time                             │
 │                                         │
 │  Facts:                                 │
 │  • fact_order                           │
 │  • fact_order_process                   │
 └─────────────────────────────────────────┘
        │
        ▼  [SSAS Multidimensional Cube]
 Gravity Books DWH Cube
 (Dim Address, Book, Customer, Date x5,
  Shipping Method → Fact Order Process)
```

---

## 📁 Repository Structure

```
gravity-books-dwh/
│
├── 01_OLTP_Database/
│   └── gravity_books_OLTP_create_script.sql   # Full OLTP schema + seed data
│
├── 02_DWH_Schema/
│   └── 01_create_dwh_schema.sql               # DWH tables, SCD columns, FK constraints
│
├── 03_SSIS_ETL/
│   ├── gravity_books.dtproj                   # SSIS Visual Studio project file
│   ├── gravity_books.slnx                     # Solution file
│   ├── gravity_books.database                 # Catalog config
│   ├── LocalHost.gravity_books.conmgr         # OLTP connection manager
│   ├── LocalHost.gravity_books_DWH.conmgr     # DWH connection manager
│   ├── Project.params                         # Project parameters
│   │
│   ├── Customer_dim_v001.dtsx                 # Dim Customer (SCD2)
│   ├── Address_dim_v001.dtsx                  # Dim Address (SCD2)
│   ├── Customer_address_dim_v001.dtsx         # Bridge: Customer ↔ Address
│   ├── Book_dim_v001.dtsx                     # Dim Book (SCD2)
│   ├── Author_dim_v001.dtsx                   # Dim Author
│   ├── Book_author_dim_v001.dtsx              # Bridge: Book ↔ Author
│   ├── Shipping_method_dim.dtsx               # Dim Shipping Method (SCD2)
│   ├── Order_fact_v001.dtsx                   # Fact Order
│   ├── Order_process_fact_v001.dtsx           # Fact Order Process (v1)
│   ├── Order_process_fact_v002.dtsx           # Fact Order Process (v2 - revised)
│   └── Order_process_fact_v003.dtsx           # Fact Order Process (v3 - final)
│
├── 04_SSAS_Cube/
│   ├── gravity_books_cube.dwproj              # SSAS project file
│   ├── gravity_books_cube.slnx                # Solution file
│   ├── Gravity Books DWH_src.ds               # Data source definition
│   ├── Gravity Books DWH.dsv                  # Data source view
│   ├── Gravity Books DWH.cube                 # Cube definition
│   ├── Gravity Books DWH.partitions           # Partition config
│   ├── Dim Address.dim                        # Address dimension
│   ├── Dim Book.dim                           # Book dimension
│   ├── Dim Customer.dim                       # Customer dimension
│   ├── Dim Date .dim                          # Order date dimension
│   ├── Dim Date cancelled.dim                 # Cancelled date role
│   ├── Dim Date inprogress.dim                # In-progress date role
│   ├── Dim Date pending.dim                   # Pending date role
│   ├── Dim Date recevied.dim                  # Received date role
│   ├── Dim Date returned.dim                  # Returned date role
│   ├── Dim Shipping Method.dim                # Shipping method dimension
│   └── Fact Order Process.dim                 # Fact table definition
│
├── 05_SQL_Queries/
│   ├── 01_dwh_select_queries.sql              # DWH validation & RESEED scripts
│   ├── 02_source_oltp_select_queries.sql      # OLTP source exploration queries
│   ├── 03_fact_order_process_source_query.sql # Pivoted staging query for fact_order_process
│   └── 04_utility_delete_truncate.sql         # Cleanup / maintenance scripts
│
└── docs/
    └── DATA_MODEL.md                          # Detailed data model documentation
```

---

## 🗄️ Data Model

### OLTP Source — `gravity_books`

The source system is a normalized bookstore database with the following core entities:

| Table | Description |
|---|---|
| `customer` | Customer master data |
| `address` | Physical addresses |
| `customer_address` | Customer ↔ Address mapping with status |
| `book` | Book catalog with language & publisher |
| `author` | Author master |
| `book_author` | Many-to-many book ↔ author |
| `shipping_method` | Shipping options and costs |
| `cust_order` | Customer order headers |
| `order_line` | Order line items with price |
| `order_history` | Order lifecycle status history |
| `order_status` | Status lookup (Received → Pending → In-Progress → Delivered / Cancelled / Returned) |

### DWH — `gravity_books_DWH`

**Dimensions** (with SCD Type 2 columns: `start_date`, `end_date`, `is_current`):

| Dimension | Surrogate Key | Key Attributes |
|---|---|---|
| `dim_customer` | `customer_SK` | name, email |
| `dim_address` | `address_SK` | street, city, country |
| `dim_customer_address` | composite PK | customer↔address bridge with status |
| `dim_book` | `book_SK` | title, ISBN13, language, publisher, pages, pub date |
| `dim_author` | `author_SK` | author name |
| `dim_book_author` | composite PK | book↔author bridge |
| `dim_shipping_method` | `shipping_method_SK` | method name, cost |
| `Dim_Date` | `Date_SK` | full date hierarchy (day → week → month → quarter → year) |
| `Dim_Time` | `Time_SK` | hour, minute, second hierarchy |

**Facts**:

| Fact | Grain | Key Measures |
|---|---|---|
| `fact_order` | One row per order line | price, linked to customer/book/shipping/address/date |
| `fact_order_process` | One row per order | milestone dates (received, pending, in-progress, delivered, cancelled, returned), current_status, days_to_ship, days_to_deliver |

---

## ⚙️ SSIS ETL Packages

All 11 packages run from the **`gravity_books`** SSIS project targeting SQL Server Integration Services. Each package follows the same pattern: truncate/reseed the target, load from OLTP via lookup/merge, and handle SCD logic.

| Package | Target | SCD |
|---|---|---|
| `Customer_dim_v001.dtsx` | `dim_customer` | Type 2 |
| `Address_dim_v001.dtsx` | `dim_address` | Type 2 |
| `Customer_address_dim_v001.dtsx` | `dim_customer_address` | — |
| `Book_dim_v001.dtsx` | `dim_book` | Type 2 |
| `Author_dim_v001.dtsx` | `dim_author` | — |
| `Book_author_dim_v001.dtsx` | `dim_book_author` | — |
| `Shipping_method_dim.dtsx` | `dim_shipping_method` | Type 2 |
| `Order_fact_v001.dtsx` | `fact_order` | — |
| `Order_process_fact_v001/v002/v003.dtsx` | `fact_order_process` | — (versioned iterations) |

### Connection Managers

Two connection managers are included:
- `LocalHost.gravity_books.conmgr` — OLTP source connection
- `LocalHost.gravity_books_DWH.conmgr` — DWH destination connection

> **Note:** Update the server name in connection managers before deploying to a different environment.

---

## 🧊 SSAS Multidimensional Cube

The **Gravity Books DWH** cube is built over `fact_order_process` and provides OLAP-style analysis of order fulfillment performance.

### Cube Dimensions

- **Dim Address** — Customer delivery location
- **Dim Book** — Book attributes
- **Dim Customer** — Customer demographics
- **Dim Date** (5 role-playing instances):
  - Date Received
  - Date Pending
  - Date In-Progress
  - Date Delivered / Cancelled / Returned
- **Dim Shipping Method** — Shipping cost and method

### Key Measures
- `days_to_ship` — Days from order received to shipped
- `days_to_deliver` — Days from received to delivered
- `current_status` — Latest status per order

---

## 🚀 How to Run This Project

### Prerequisites

- SQL Server 2019+ (or SQL Server Express)
- SQL Server Integration Services (SSIS)
- SQL Server Analysis Services (SSAS) — Multidimensional mode
- Visual Studio 2022 with **SQL Server Data Tools (SSDT)**

### Step 1 — Set up the OLTP Database

```sql
-- Run in SQL Server Management Studio
-- File: 01_OLTP_Database/gravity_books_OLTP_create_script.sql
```

This creates the `gravity_books` database and populates all source tables.

### Step 2 — Build the DWH Schema

```sql
-- Run in SSMS
-- File: 02_DWH_Schema/01_create_dwh_schema.sql
```

Creates `gravity_books_DWH` with all dimension and fact tables, SCD columns, and foreign key constraints.

You also need to populate `Dim_Date` and `Dim_Time` tables (date spine scripts available separately or via SSMS date generation scripts).

### Step 3 — Deploy & Run SSIS ETL

1. Open `03_SSIS_ETL/gravity_books.slnx` in Visual Studio
2. Update both connection managers to point to your SQL Server instance
3. Run packages in this order:
   1. Dimension packages (all `*_dim*.dtsx`)
   2. `Order_fact_v001.dtsx`
   3. `Order_process_fact_v003.dtsx` (final version)

### Step 4 — Deploy the SSAS Cube

1. Open `04_SSAS_Cube/gravity_books_cube.slnx` in Visual Studio
2. Update `Gravity Books DWH_src.ds` with your server connection string
3. Deploy → Process the cube
4. Browse in SSMS or Excel (Connect to Analysis Services)

### Step 5 — Validate the Load

Use the queries in `05_SQL_Queries/01_dwh_select_queries.sql` to check row counts and data integrity across all tables.

---

## 📊 Key Design Decisions

### SCD Type 2 on 4 Dimensions
Customer, Address, Book, and Shipping Method all use Slowly Changing Dimension Type 2 with `start_date`, `end_date`, and `is_current` columns to preserve historical snapshots when data changes.

### fact_order_process — Pivoted Milestone Design
Instead of storing one row per status event, `fact_order_process` uses a pivoted design with one row per order and separate date columns for each lifecycle milestone. This makes time-to-deliver and order funnel analysis simple and efficient.

The source query (`05_SQL_Queries/03_fact_order_process_source_query.sql`) uses conditional aggregation (`MAX(CASE WHEN status_id = N THEN status_date END)`) to flatten the `order_history` event log into this structure.

### Role-Playing Date Dimensions in SSAS
The single `Dim_Date` table is reused 5 times in the SSAS cube as role-playing dimensions (Received, Pending, In-Progress, Delivered, Cancelled, Returned), allowing analysis across the full order timeline.

### Versioned SSIS Packages
`Order_process_fact` went through 3 versions (`v001` → `v003`) as the fact table design evolved. All versions are retained to show the iteration history. Production deployments should use `v003`.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Source DB | SQL Server (OLTP — gravity_books) |
| DWH | SQL Server (Star Schema — gravity_books_DWH) |
| ETL | SSIS (SQL Server Integration Services) |
| OLAP | SSAS (SQL Server Analysis Services — Multidimensional) |
| IDE | Visual Studio 2022 + SSDT |
| Query Tool | SQL Server Management Studio (SSMS) |

---

## 👤 Author

**Abdelrahman ElEzmazy**  
Data Engineering Trainee — ITI Egypt  
Information Technology Institute · Data Engineering Track

---

## 📝 Notes

- Connection managers reference `localhost` — update to your server before deployment
- The `~$rew.docx` temp file is excluded from this repo (Word lock file)
- `obj/` and `.vs/` build/IDE directories are excluded via `.gitignore`
- SSAS deployment targets are in `gravity_books_cube.deploymenttargets` — update server name before deploying
