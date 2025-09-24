# Snowflake + dbt Project (TPCH Demo)

## 📖 Overview

This project demonstrates how to use **dbt Cloud with Snowflake** to build a scalable data transformation pipeline following a **Medallion architecture**. The project transforms TPCH sample data through multiple layers to create business-ready analytics tables.

Watch the explanation video here: [Explanation Video](https://drive.google.com/file/d/1nCuRdB6RacnPFCXjw_F4X2Mk__4_p_-G/view?usp=drive)

### Architecture Layers
- **Bronze (Sources)**: TPCH sample tables in Snowflake (`customer`, `orders`, `lineitem`, `nation`)
- **Silver (Staging)**: Cleaned and standardized models (`stg_orders`)
- **Gold (Marts)**: Business-ready analytics tables (`customer_revenue`, `orders_by_year`, `customer_revenue_by_nation`)

### Key Features
- **Data Quality**: Comprehensive schema-level tests (`unique`, `not_null`, `relationships`)
- **Documentation**: Fully documented models and columns in `schema.yml`
- **Exposures**: Integration with downstream Snowflake Snowsight dashboard
- **Best Practices**: Follows dbt conventions with proper layering and modularity

## How to Run the Project

### Prerequisites
- Snowflake account with appropriate permissions
- dbt Cloud account (recommended) or local dbt installation
- GitHub repository access

### Snowflake Environment Setup

Before running the dbt project, you'll need to set up your Snowflake environment [Snowflake Cloud](https://www.snowflake.com/en/). Execute these SQL commands in your Snowflake worksheet:

#### 1. Create Development Warehouse
```sql
-- Create a development warehouse
CREATE WAREHOUSE DEV_WH WITH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60  -- Auto-suspend after 1 minute of inactivity
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = FALSE;

-- Set it as your current warehouse
USE WAREHOUSE DEV_WH;
```

#### 2. Setup Sample Data Access
```sql
-- Check if SNOWFLAKE_SAMPLE_DATA database exists
SHOW DATABASES LIKE 'SNOWFLAKE_SAMPLE_DATA';

-- Grant privileges so your role can query it
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE_SAMPLE_DATA TO ROLE PUBLIC;

-- If it doesn't exist, create it from the shared database
-- CREATE DATABASE SNOWFLAKE_SAMPLE_DATA FROM SHARE SFC_SAMPLES.SAMPLE_DATA;
```

#### 3. Create dbt Target Database
```sql
-- Create database for your dbt models
CREATE DATABASE DBT_DEMO;

-- Create schemas following medallion architecture
CREATE SCHEMA DBT_DEMO.BRONZE;  -- Raw/staging data
CREATE SCHEMA DBT_DEMO.SILVER;  -- Cleaned/transformed data  
CREATE SCHEMA DBT_DEMO.GOLD;    -- Business-ready aggregated data

-- Set permissions (if needed)
GRANT ALL ON DATABASE DBT_DEMO TO ROLE PUBLIC;
GRANT ALL ON ALL SCHEMAS IN DATABASE DBT_DEMO TO ROLE PUBLIC;
```

#### 4. Verify Setup
```sql
-- Set context to sample data
USE DATABASE SNOWFLAKE_SAMPLE_DATA;
USE SCHEMA TPCH_SF1;

-- Verify key tables are accessible
SELECT COUNT(*) FROM snowflake_sample_data.tpch_sf1.customer;
SELECT COUNT(*) FROM snowflake_sample_data.tpch_sf1.orders;
SELECT COUNT(*) FROM snowflake_sample_data.tpch_sf1.lineitem;

-- Test table relationships
SELECT 
    o.o_orderkey,
    o.o_custkey,
    c.c_name,
    o.o_orderdate,
    o.o_totalprice
FROM snowflake_sample_data.tpch_sf1.orders o
JOIN snowflake_sample_data.tpch_sf1.customer c 
    ON o.o_custkey = c.c_custkey
LIMIT 5;
```

**Important Notes:**
- The `DEV_WH` warehouse will auto-suspend after 1 minute to minimize costs
- Sample data should be available by default in most Snowflake accounts
- If you encounter permission issues, contact your Snowflake administrator

### Option 1: Run in dbt Cloud (Recommended)

This project was built and optimized for **dbt Cloud** with **Snowflake integration**.

1. **Clone the Repository**
   ```bash
   git clone https://github.com/ANBadawy/snowflake-dbt-assessment.git
   cd snowflake-dbt-assessment
   ```

2. **Setup dbt Cloud**
   - Log into [dbt Cloud](https://cloud.getdbt.com/)
   - Connect your Snowflake account (warehouse, database, schema)
   - Connect this GitHub repository as your dbt project
   - Configure your development credentials

3. **Run the Pipeline**
   - Open the **Studio** tab in dbt Cloud IDE
   - Execute the following commands:
   ```sql
   dbt deps          # Install any dependencies
   dbt run           # Build all models
   dbt test          # Run data quality tests
   ```

4. **Generate Documentation** (Optional)
   ```sql
   dbt docs generate
   ```
   View documentation in the **Docs** tab within dbt Cloud.

### Option 2: Run Locally

If you prefer to run outside dbt Cloud:

1. **Create and activate a virtual environment**:
   ```bash
   # Windows
   python -m venv env
   env\Scripts\activate

   # Linux/Mac
   python3 -m venv env
   source env/bin/activate
   ```

2. **Install dbt**
   ```bash
   pip install dbt-snowflake
   ```

3. **Configure Snowflake Profile**
   Create or update `~/.dbt/profiles.yml`:
   ```yaml
   snowflake_dbt_demo:
     target: dev
     outputs:
       dev:
         type: snowflake
         account: your_account
         user: your_username
         password: your_password
         warehouse: DEV_WH
         database: DBT_DEMO
         schema: your_schema
         threads: 4
   ```
4. **Run the Project**
   ```bash
   dbt deps
   dbt run
   dbt test
   dbt docs serve  # View docs locally
   ```

## 📂 Project Structure

```
├── dbt_project.yml              # Project configuration
├── models/
│   ├── sources.yml              # Source definitions for TPCH tables
│   ├── staging/                 # Silver layer (cleaned data)
│   │   ├── stg_orders.sql
│   ├── marts/                   # Gold layer (business logic)
│   │   ├── customer_revenue.sql
│   │   ├── orders_by_year.sql
│   │   └── customer_revenue_by_nation.sql
│   └── schema.yml               # Models + Tests + documentation + exposures
└── README.md                    # This file
```

## Models Descriptions

### Silver Layer (Staging)

#### `stg_orders`
**Purpose**: Staged orders enriched with customer information and derived columns  
**Key Features**:
- Primary key: `order_id` (from `o_orderkey`)
- Enriched with customer names from TPCH customer table
- Includes derived `order_year` column for time-based analysis
- Forms the foundation for all downstream Gold layer models

**Columns**:
- `order_id`: Primary key for orders (tested for uniqueness and not null)
- `customer_id`: Foreign key linking to customers
- `customer_name`: Customer name from TPCH customer table
- `order_date`: Date the order was placed
- `order_year`: Derived year from order_date for aggregations
- `total_price`: Total price for the order

### Gold Layer (Marts)

#### `customer_revenue`
**Purpose**: Total revenue aggregated by customer for customer-centric analysis  
**Business Use**: Customer lifetime value analysis, top customer identification

**Columns**:
- `customer_id`: Primary key for customers (tested for uniqueness and not null)
- `customer_name`: Customer name for reporting
- `total_revenue`: Revenue calculated as `SUM(l_extendedprice * (1 - l_discount))`

#### `orders_by_year`
**Purpose**: Revenue and order trends aggregated by year  
**Business Use**: Time series analysis, year-over-year performance tracking

**Columns**:
- `order_year`: Year of the order (tested for not null)
- `total_revenue`: Total revenue for that year
- `order_count`: Number of orders placed in that year

#### `customer_revenue_by_nation`
**Purpose**: Revenue analysis by customer and geographic region  
**Business Use**: Regional performance analysis, international customer insights

**Columns**:
- `customer_id`: Primary key for customers (tested for uniqueness and not null)
- `customer_name`: Customer name
- `nation`: Customer's nation/country
- `total_revenue`: Revenue calculated as `SUM(l_extendedprice * (1 - l_discount))`

## 🧪 Data Quality Tests

The project implements comprehensive testing at each layer:

### Staging Layer Tests
- **stg_orders**: 
  - `order_id` must be unique and not null
  - Date fields validated for reasonable ranges

### Marts Layer Tests
- **customer_revenue**: 
  - `customer_id` must be unique and not null
  - Revenue amounts must be positive
- **customer_revenue_by_nation**: 
  - Tested for uniqueness and referential integrity with nation table
  - Aggregation accuracy validation

Run all tests:
```bash
dbt test
```

Run tests for specific models:
```bash
dbt test --models customer_revenue
```

## 📊 Exposures

The project defines downstream usage through **exposures**:

- **Snowsight Dashboard**: Links Gold layer models (`customer_revenue`, `customer_revenue_by_nation`) to business dashboards
- **Lineage Tracking**: Visible in dbt Docs lineage graph showing data flow from sources to consumption

## 🔧 Configuration Details

### Snowflake Resources
- **Warehouse**: `DEV_WH`
- **Database**: `DBT_DEMO`
- **Sample Data**: `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`

## Deployment

This project is deployed in **dbt Cloud** with a scheduled job.

- **Environment**: Deployment environment connected to Snowflake
- **Schedule**: Weekly (Sunday midnight) via cron: `0 0 * * 0`
- **The Given Commands**:
   ```bash
   dbt build
   ```






