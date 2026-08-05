
# Solution Architecture

## 1. Overview

The Delivery Standardization & Cost Optimization Platform is an enterprise analytics solution built on Microsoft Fabric.

The platform integrates delivery operations, customer sales, route activity, driver hours, vehicle telemetry, fuel purchases, customer cost-to-serve data, and reference data into a centralized analytical model.

The solution supports:

- Delivery standardization
- OTIF and service-performance analysis
- Driver productivity and overtime analysis
- Customer cost-to-serve analysis
- Delivery-frequency recommendations
- Customer churn and reactivation tracking
- Fuel-efficiency and sustainability reporting
- Optional road-level enrichment

The public portfolio implementation uses synthetic data and generic branding. The architecture reflects a Microsoft Fabric-based enterprise solution.

---

## 2. High-Level Architecture

```text
                              Source Systems
──────────────────────────────────────────────────────────────────────

ERP System (SAP-like)
• Delivery Orders
• Sales Orders
• Customer Master
• Material Master
• Customer Cost to Serve
• Fuel Purchase Orders

Fleet Telematics Platform (Samsara-like)
• GPS Activity
• Vehicle Odometer
• Miles Driven
• Vehicle Telemetry
• Driver and Route Activity

Reference Data
• Delivery Frequency Matrix
• Customer Categories
• Sales Organization Hierarchy
• Missed Delivery Reasons
• Vehicle Master
• Route Master

Road Intelligence (Portfolio Enhancement)
• Traffic Events
• Weather Conditions
• School Zones
• No-Left-Turn Restrictions
• Road Closures
• Construction Events

                              │
                              ▼

                    Microsoft Fabric Platform
──────────────────────────────────────────────────────────────────────

                 Fabric Data Factory Pipelines
                              │
                              ▼
                        OneLake Storage
                              │
                              ▼
                     Bronze Lakehouse Layer
                         Raw Source Data
                              │
                              ▼
                     Silver Lakehouse Layer
                   Cleaned and Standardized Data
                              │
                              ▼
                       Gold Warehouse Layer
                     Business-Ready Star Schema
                              │
                              ▼
                    Power BI Semantic Model
                              │
                              ▼
                  Executive and Operational Reports
```

---

## 3. Source-System Architecture

### ERP System

The ERP source provides structured operational and commercial data, including:

- Delivery orders
- Order and delivery dates
- Customer identifiers
- Material identifiers
- Ordered and delivered cases
- Sales amounts
- Customer-level operational cost
- Fuel purchase-order line items
- Fuel purchase date and time
- Vehicle identifier
- Fuel quantity
- Fuel cost
- Odometer reading

The portfolio uses synthetic CSV files to represent these ERP extracts.

### Fleet Telematics Platform

The fleet telematics source provides vehicle and route activity, including:

- Vehicle GPS events
- Odometer readings
- Miles driven
- Engine hours
- Idle time
- Route activity
- Driver assignment
- Vehicle utilization

This data supports fuel-efficiency, mileage, driver-hours, and fleet-performance analysis.

### Reference Data

Reference datasets provide controlled business definitions, including:

- Customer categories
- Delivery-frequency thresholds
- Recommended weekly frequencies
- Region hierarchy
- Market Unit hierarchy
- Distribution Center hierarchy
- Sales Territory hierarchy
- Area Sales Manager assignment
- Market Development Manager assignment
- Missed-delivery classifications

### Road Intelligence

Road-level data is an optional portfolio enhancement inspired by prior road-analytics experience.

Python is used only to:

1. Read raw API or road-feedback responses.
2. Extract relevant event fields.
3. Convert unstructured or nested responses into structured records.
4. Produce a road-events dataset for Fabric ingestion.

The original delivery-standardization implementation did not include this road-intelligence integration.

---

## 4. Microsoft Fabric Data Architecture

### Fabric Data Factory Pipelines

Fabric pipelines are responsible for:

- Ingesting source CSV files
- Loading raw extracts into OneLake
- Scheduling daily or periodic refreshes
- Capturing ingestion metadata
- Logging pipeline failures
- Preventing duplicate source-file loads
- Orchestrating Bronze-to-Silver and Silver-to-Gold processing

### OneLake

OneLake provides centralized storage for:

- Raw source files
- Bronze Delta tables
- Silver Delta tables
- Supporting reference data
- Structured road-event output
- Historical source extracts

---

## 5. Bronze Layer

The Bronze layer stores source data with minimal transformation.

### Bronze Design Principles

- Preserve original source records.
- Retain source-system identifiers.
- Preserve source data types where practical.
- Add ingestion metadata.
- Avoid applying KPI or business logic.
- Support data lineage and reprocessing.

### Proposed Bronze Tables

```text
bronze_delivery_orders
bronze_customer_master
bronze_material_master
bronze_customer_material_sales
bronze_driver_hours
bronze_route_master
bronze_vehicle_master
bronze_vehicle_telemetry
bronze_fuel_purchase_orders
bronze_customer_cost_to_serve
bronze_frequency_matrix
bronze_sales_organization
bronze_missed_delivery_reasons
bronze_road_events
```

### Standard Bronze Metadata

Each Bronze table should include:

- `source_system`
- `source_file_name`
- `load_timestamp`
- `pipeline_run_id`
- `record_source`
- `ingestion_date`

---

## 6. Silver Layer

The Silver layer cleans, validates, standardizes, and integrates Bronze data.

### Silver Processing

The Silver layer performs:

- Duplicate removal
- Data-type correction
- Null-value handling
- Date and timestamp standardization
- Business-key validation
- Customer-ID standardization
- Material-ID standardization
- Driver, route, and vehicle validation
- Delivery-status standardization
- OTIF flag validation
- Hotshot and off-day classification
- Missed-delivery reason mapping
- Controllable and uncontrollable reason classification
- Sales-organization enrichment
- Vehicle and telemetry integration
- Road-event structuring and matching preparation

### Proposed Silver Tables

```text
silver_delivery_orders
silver_customers
silver_materials
silver_customer_material_sales
silver_driver_hours
silver_routes
silver_vehicles
silver_vehicle_telemetry
silver_fuel_purchases
silver_customer_cost_to_serve
silver_frequency_rules
silver_sales_organization
silver_missed_delivery_reasons
silver_road_events
```

### Data-Quality Checks

The Silver layer should validate:

- Unique delivery-order identifiers
- Valid customer keys
- Valid material keys
- Valid driver and route assignments
- Delivered cases not exceeding ordered cases unless explicitly allowed
- Valid delivery dates
- Valid purchase timestamps
- Positive fuel quantities and costs
- Valid odometer readings
- Valid frequency-rule ranges
- Complete sales-organization hierarchy

Invalid records should be logged for review rather than silently discarded.

---

## 7. Gold Layer

The Gold layer is implemented in the Fabric Warehouse and contains the business-ready dimensional model.

### Gold Fact Tables

| Fact Table | Grain |
|---|---|
| FactDeliveryOrder | One delivery/order representing one customer stop |
| FactDriverHours | One driver × one route × one work date |
| FactCustomerMaterialVolume | One customer × one material × one sales transaction |
| FactFrequencyRecommendation | One customer × one recommendation-run date |
| FactCustomerCostToServe | One customer × one activity date |
| FactFuelPurchase | One fuel-purchase invoice line item |
| FactVehicleTelemetry | One vehicle telemetry event |
| FactRoadEvent | One road event |

### Gold Dimension Tables

| Dimension Table | Purpose |
|---|---|
| DimDate | Calendar and reporting periods |
| DimCustomer | Customer attributes, category, ASM, and MDM |
| DimMaterial | Material and product attributes |
| DimDriver | Driver master |
| DimRoute | Route master |
| DimVehicle | Vehicle master and expected MPG |
| DimSalesOrganization | Region, Market Unit, Distribution Center, and Sales Territory |
| DimMissedReason | Detailed reason, category, and controllability |
| DimFrequencyMatrix | Customer category and rolling four-week cases thresholds |

---

## 8. Gold-Layer Business Modules

### Delivery Standardization

Uses:

- FactDeliveryOrder
- FactDriverHours
- DimCustomer
- DimRoute
- DimDriver
- DimVehicle
- DimSalesOrganization
- DimMissedReason

Supports:

- OTIF
- SLA
- On-time delivery
- Cases per hour
- Cases per stop
- Stops
- Hotshots
- Off-day deliveries
- Missed-delivery analysis
- Driver overtime

### Frequency Recommendation

Uses:

- FactCustomerMaterialVolume
- FactFrequencyRecommendation
- DimCustomer
- DimFrequencyMatrix
- DimDate

Business logic:

```text
Customer Category
        +
Rolling 4-Week Cases Sold
        ↓
Frequency Recommendation Matrix
        ↓
Recommended Weekly Frequency
        ↓
Compare with Current Frequency
        ↓
Estimate Stops, Miles, Fuel, Cost, and CO₂ Savings
```

The recommendation is rule-based and transparent. It is not presented as machine learning.

### Customer Health Scorecard

Uses:

- FactCustomerMaterialVolume
- DimCustomer
- DimDate
- DimSalesOrganization

Customer status is calculated dynamically using the selected Power BI reporting date.

Classifications include:

- Existing Customer
- New Customer
- Reactivated Customer
- Churned Customer

Business rules:

- A new customer has a purchase in the selected period with no prior purchase history.
- A reactivated customer purchases after more than 365 days of inactivity.
- A churned customer has no purchase during the previous 365 days as of the selected reporting date.
- An existing customer purchases in the selected period and also purchased during the preceding 365 days.

The scorecard supports filtering by:

- Region
- Market Unit
- Distribution Center
- Sales Territory
- Area Sales Manager
- Market Development Manager
- Customer

### Customer Cost to Serve

Uses:

- FactCustomerCostToServe
- DimCustomer
- DimDate
- DimSalesOrganization

Customer operational cost is supplied at the customer-date level.

Power BI dynamically calculates:

- Cost to Serve
- Cost per Case
- Cost per Stop
- Customer Profitability

### Fuel and Fleet Analytics

Uses:

- FactFuelPurchase
- FactDriverHours
- FactVehicleTelemetry
- DimVehicle
- DimDate
- DimSalesOrganization

Supports:

- Gallons purchased
- Fuel cost
- Miles driven
- Actual MPG
- Expected MPG
- MPG variance
- Fuel cost per mile
- CO₂ emissions
- Vehicle utilization

Fact tables are not directly joined to each other. They are filtered through shared dimensions such as Date, Vehicle, and Sales Organization.

### Road Intelligence Enhancement

Uses:

- FactRoadEvent
- FactDeliveryOrder
- DimRoute
- DimDate

A bridge table may be created:

```text
BridgeDeliveryRoadEvent
```

**Grain:** One delivery order × one matched road event.

This allows:

- One road event to affect multiple deliveries.
- One delivery to be associated with multiple relevant road events.
- A primary event to be identified.
- Match confidence and estimated delay to be stored.

---

## 9. Semantic Model Architecture

The Power BI semantic model connects to Gold Warehouse tables.

### Semantic-Model Responsibilities

- Define one-to-many relationships.
- Hide technical surrogate keys.
- Create business-friendly table and column names.
- Add date hierarchies.
- Add geographic and sales hierarchies.
- Create reusable DAX measures.
- Support dynamic date filtering.
- Support customer-status calculations.
- Support recommendation and savings analysis.
- Provide consistent KPI definitions across reports.

### Relationship Principles

- Dimensions filter fact tables.
- Relationships use single-direction filtering by default.
- Fact-to-fact relationships are avoided.
- Shared dimensions connect multiple facts.
- Role-playing date relationships are used where required.
- Bridge tables are used for valid many-to-many business scenarios.

---

## 10. Power BI Reports

The semantic model supports the following reports and pages:

### Executive Overview

- OTIF
- SLA
- Total Deliveries
- Total Stops
- Cost to Serve
- Customer Profitability
- Driver Overtime
- Fuel Consumption
- CO₂ Emissions
- Estimated Savings

### Delivery Standardization

- Cases per Hour
- Cases per Stop
- On-Time Delivery
- Hotshots
- Off-Day Deliveries
- Missed Deliveries
- Distribution Center comparison
- Route performance

### Frequency Recommendation

- Current frequency
- Recommended frequency
- Rolling four-week cases
- Stops saved
- Miles saved
- Fuel saved
- Cost saved
- CO₂ saved
- Implementation status

### Customer Health Scorecard

- Existing customers
- New customers
- Reactivated customers
- Churned customers
- Customer trends
- Churn by location
- New and reactivated customers by ASM and MDM

### Driver Hours and Productivity

- Regular hours
- Overtime hours
- Cases per hour
- Cases per stop
- Miles driven
- Driver and route comparison

### Fuel and Sustainability

- Fuel purchases
- Fuel cost
- Miles driven
- Actual MPG
- Expected MPG
- MPG variance
- Fuel cost per mile
- CO₂ emissions
- CO₂ savings

### Road Impact

- Traffic events
- School zones
- Turn restrictions
- Weather
- Construction
- Road closures
- Estimated delay
- Affected deliveries

This page is presented as a portfolio enhancement.

---

## 11. Technology Stack

| Layer | Technology |
|---|---|
| Programming | Python 3.x |
| Data Platform | Microsoft Fabric |
| Data Integration | Fabric Data Factory Pipelines |
| Central Storage | OneLake |
| Bronze Layer | Fabric Lakehouse |
| Silver Layer | Fabric Lakehouse |
| Gold Layer | Fabric Warehouse |
| Transformation | Fabric Notebooks, SQL, and Dataflows where appropriate |
| SQL Processing | T-SQL |
| Data Modeling | Dimensional Star Schema |
| Semantic Layer | Power BI Semantic Model |
| Visualization | Power BI |
| ERP Source | SAP-like synthetic source |
| Fleet Source | Samsara-like synthetic telemetry |
| Road Intelligence | Python-structured API or feedback data |
| Version Control | Git and GitHub |

---

## 12. Local Portfolio Implementation

Because a personal Fabric workspace may not be available, the project can be demonstrated locally using:

- Synthetic source CSV files
- SQL scripts representing Bronze, Silver, and Gold transformations
- Power BI Desktop
- Architecture diagrams
- Fabric pipeline designs
- Fabric notebook examples
- Warehouse DDL scripts
- Semantic-model documentation

The repository should clearly distinguish between:

- The intended Microsoft Fabric production architecture
- The locally executable portfolio demonstration

The lack of a publicly accessible Fabric workspace does not change the documented target architecture.

---

## 13. Design Principles

- Clearly define the grain of every fact table.
- Use shared conformed dimensions.
- Avoid direct fact-to-fact relationships.
- Keep Bronze data close to the source.
- Apply validation and standardization in Silver.
- Build business-ready star-schema tables in Gold.
- Keep KPI definitions centralized.
- Use dynamic calculations where date context matters.
- Use synthetic data throughout the public repository.
- Keep the frequency model transparent and rule-based.
- Present road intelligence honestly as a portfolio enhancement.
- Separate this project from the CMG Power Automate and Databricks automation project.

---

## 14. Confidentiality and Portfolio Safety

This repository must not contain:

- Employer data
- Customer information
- Employee information
- Proprietary source code
- Internal screenshots containing confidential data
- Production credentials
- API keys
- Internal URLs
- Confidential business thresholds

All source data, names, values, identifiers, and screenshots used publicly must be synthetic or anonymized.
