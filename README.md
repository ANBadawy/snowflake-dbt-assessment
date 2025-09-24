# Snowflake + dbt Project (TPCH Demo)

## 📖 Overview

This project demonstrates how to use **dbt Cloud with Snowflake** to build a scalable data transformation pipeline following a **Medallion architecture**. The project transforms TPCH sample data through multiple layers to create business-ready analytics tables.

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
- Snowflake account with TPCH sample data access
- dbt Cloud account (recommended) or local dbt installation
- GitHub repository access

### Option 1: Run in dbt Cloud (Recommended)

This project was built and optimized for **dbt Cloud** with **Snowflake integration**.

1. **Clone the Repository**
   ```bash
   git clone https://github.com/ANBadawy/snowflake-dbt-assessment.git
   cd <your-repo>
   ```

2. **Setup dbt Cloud**
   - Log into [dbt Cloud](https://cloud.getdbt.com/)
   - Connect your Snowflake account (warehouse, database, schema)
   - Connect this GitHub repository as your dbt project
   - Configure your development credentials

3. **Run the Pipeline**
   - Open the **Develop** tab in dbt Cloud IDE
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
│   └── source.yml               # source definitions
│   └── schema.yml               # Models + Tests + documentation + exposures
└── README.md                    # This file
```

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
