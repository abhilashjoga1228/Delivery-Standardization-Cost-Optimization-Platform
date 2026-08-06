# Deployment Guide

## Prerequisites

- Microsoft Fabric Workspace
- Microsoft Fabric Warehouse
- Python 3.11+
- pandas
- numpy

---

## Step 1 – Clone Repository

```bash
git clone https://github.com/<username>/Delivery-Standardization-Cost-Optimization-Platform.git
```

---

## Step 2 – Generate Synthetic Data

```bash
pip install pandas numpy

python python/generate_data.py
```

Generated datasets:

- Customers
- Materials
- Drivers
- Routes
- Vehicles
- Delivery Orders
- Customer Material Sales
- Driver Hours
- Customer Cost to Serve
- Fuel Purchases
- Frequency Recommendations

---

## Step 3 – Create Warehouse

Run SQL scripts in this order:

01_Create_Schema.sql

02_Create_Dimensions.sql

03_Create_Facts.sql

04_Create_Primary_Keys.sql

05_Create_Unique_Keys.sql

06_Create_Foreign_Keys.sql

---

## Step 4 – Load Data

Load CSV files into Bronze Lakehouse.

Transform to Silver.

Load Gold Warehouse.

---

## Step 5 – Create Semantic Model

Create relationships.

Create DAX Measures.

Publish Semantic Model.

---

## Step 6 – Build Power BI Reports

Executive Dashboard

Delivery Performance

Customer Health

Frequency Optimization

Driver Productivity

Fleet Dashboard

---

## Validation

Execute scripts under:

fabric/warehouse/validation/

Verify:

- Duplicate Keys
- Orphan Keys
- Null Values
- Row Counts

---

## Release

Publish Version 1.0
