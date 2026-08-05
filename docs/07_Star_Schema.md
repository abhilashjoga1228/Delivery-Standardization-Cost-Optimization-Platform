# Star Schema Design

## 1. Purpose

This document defines the analytical data model for the Delivery Standardization & Cost Optimization Platform.

The model supports:

- Delivery performance
- Driver hours and overtime
- Customer material sales
- Frequency recommendations
- Customer health and churn
- Cost to serve
- Fuel purchases and mileage analysis
- Vehicle telemetry
- Missed-delivery reasons
- Optional road-level enrichment

The design uses shared dimensions and multiple fact tables at clearly defined grains.

---

## 2. Core Fact Tables

| Fact Table | Grain |
|---|---|
| FactDeliveryOrder | One delivery/order, representing one customer stop |
| FactDriverHours | One driver × one route × one work date |
| FactCustomerMaterialVolume | One customer × one material × one sales transaction |
| FactFrequencyRecommendation | One customer × one recommendation run date |
| FactCustomerCostToServe | One customer × one activity date |
| FactFuelPurchase | One fuel-purchase invoice line item |
| FactVehicleTelemetry | One vehicle telemetry event |
| FactRoadEvent | One road event |
---

## 3. Core Dimension Tables

| Dimension Table | Purpose |
|---|---|
| DimDate | Calendar and reporting periods |
| DimCustomer | Customer master, category, ASM, MDM, and customer attributes |
| DimMaterial | Material, brand, category, package, and product attributes |
| DimDriver | Driver master |
| DimRoute | Route master |
| DimVehicle | Vehicle master and expected fuel efficiency |
| DimSalesOrganization | Region, Market Unit, Distribution Center, and Sales Territory hierarchy |
| DimMissedReason | Missed-delivery reason, reason category, and controllability |
| DimFrequencyMatrix | Customer category and four-week case-volume thresholds used for recommendations |
---

## 4. Business Hierarchies

### Sales and Location Hierarchy

```text
Region
  ↓
Market Unit
  ↓
Distribution Center
  ↓
Sales Territory
  ↓
Area Sales Manager
  ↓
Market Development Manager
  ↓
Customer
```

## 5. Fact Table Definitions

### FactDeliveryOrder

**Grain:** One delivery/order, representing one customer stop.

This fact supports delivery performance, service, productivity, and exception analysis.

Key fields include:

- delivery_order_key
- delivery_order_id
- order_date_key
- delivery_date_key
- customer_key
- route_key
- driver_key
- vehicle_key
- sales_organization_key
- missed_reason_key
- ordered_cases
- delivered_cases
- total_sales_amount
- stop_count
- hotshot_flag
- off_day_flag
- on_time_flag
- in_full_flag
- otif_flag
- missed_delivery_flag

Because one delivery/order equals one stop, total stops can be calculated by counting eligible delivery-order rows.

### FactDriverHours

**Grain:** One driver × one route × one work date.

This fact supports:

- Regular hours
- Overtime hours
- Total hours
- Cases delivered
- Stops completed
- Miles driven
- Deliveries completed
- Missed deliveries
- Cases per hour
- Cases per stop

### FactCustomerMaterialVolume

**Grain:** One customer × one material × one sales transaction.

This fact stores:

- Customer purchase activity
- Material-level sales
- Cases sold
- Sales amount
- Purchase date
- Order or transaction ID

It supports material analysis and dynamic customer-health calculations.

### FactFrequencyRecommendation

**Grain:** One customer × one recommendation run date.

The recommendation logic uses:

- Customer category
- Rolling four-week cases sold
- Current weekly delivery frequency
- Frequency recommendation matrix

The fact stores:

- Recommendation run date
- Rolling four-week cases
- Current frequency
- Recommended frequency
- Stops saved
- Estimated miles saved
- Estimated fuel saved
- Estimated cost saved
- Estimated CO₂ saved
- Implementation status
---

### FactCustomerCostToServe

**Grain:** One customer × one activity date.

This fact stores customer-level operational costs supplied by the source system.

Key fields include:

- cost_activity_key
- activity_date_key
- customer_key
- distribution_center_key
- total_sales
- total_cases
- total_stops
- operational_cost

Power BI dynamically calculates:

- Cost to Serve
- Cost per Case
- Cost per Stop
- Customer Profitability

---

### FactFuelPurchase

**Grain:** One fuel purchase invoice line item.

Data originates from ERP purchase orders.

Key fields include:

- fuel_purchase_key
- purchase_order_number
- purchase_datetime
- vehicle_key
- distribution_center_key
- gallons_purchased
- fuel_purchase_cost
- odometer_reading
- vendor_name
- invoice_number

This fact is used together with vehicle mileage to calculate:

- Fuel efficiency (MPG)
- Fuel cost per mile
- Fuel consumption
- CO₂ emissions

---

### FactVehicleTelemetry

**Grain:** One vehicle telemetry event.

Data originates from fleet telematics (Samsara-like system).

Key fields include:

- telemetry_key
- vehicle_key
- driver_key
- route_key
- event_timestamp
- odometer
- miles_driven
- engine_hours
- idle_time
- average_speed

This fact supports:

- Vehicle utilization
- Mileage analysis
- Fuel efficiency
- Fleet performance

---

### FactRoadEvent (Portfolio Enhancement)

**Grain:** One road event.

This module is a portfolio enhancement inspired by prior road-intelligence analytics experience.

Road events include:

- Traffic
- School Zone
- No Left Turn
- Weather
- Construction
- Road Closure

Road events are matched to delivery orders through route and time-window logic using a bridge table.

---

## 6. Modeling Principles

- Every fact table has a clearly defined grain.
- Dimensions are shared across facts.
- No fact-to-fact joins are used.
- Customer health metrics are calculated dynamically in the semantic model.
- Frequency recommendations are based on business rules, not machine learning.
- Synthetic data is used throughout the project.
