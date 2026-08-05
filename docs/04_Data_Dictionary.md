
# Data Dictionary

## 1. Purpose

This document defines the Gold-layer fact and dimension tables used by the Delivery Standardization & Cost Optimization Platform.

Each table includes:

- Table grain
- Primary key
- Foreign keys
- Business purpose
- Core analytical fields

---

## 2. Dimension Tables

### DimDate

**Purpose:** Provides calendar attributes for filtering, grouping, and time-intelligence calculations.

**Primary Key:** `date_key`

| Column | Data Type | Description |
|---|---|---|
| date_key | Integer | Surrogate date key in YYYYMMDD format |
| full_date | Date | Calendar date |
| day_name | Text | Day of week |
| day_number_of_week | Integer | Numeric weekday |
| week_number | Integer | Week of year |
| month_number | Integer | Calendar month number |
| month_name | Text | Calendar month name |
| quarter | Text | Calendar quarter |
| year | Integer | Calendar year |
| is_weekend | Boolean | Weekend indicator |

### DimCustomer

**Purpose:** Stores customer attributes, business classification, location ownership, and sales-management assignments.

**Primary Key:** `customer_key`

| Column | Data Type | Description |
|---|---|---|
| customer_key | Integer | Surrogate customer key |
| customer_id | Text | Source-system customer identifier |
| customer_name | Text | Synthetic customer name |
| customer_category | Text | Club, Retail, Convenience Retail, Restaurant, or Institutional |
| sales_organization_key | Integer | Foreign key to DimSalesOrganization |
| asm_id | Text | Area Sales Manager identifier |
| asm_name | Text | Area Sales Manager name |
| mdm_id | Text | Market Development Manager identifier |
| mdm_name | Text | Market Development Manager name |
| customer_status | Text | Source master-data status |
| latitude | Decimal | Customer latitude |
| longitude | Decimal | Customer longitude |
| active_flag | Boolean | Current master-record indicator |

### DimMaterial

**Purpose:** Stores material and product attributes used for customer purchase, sales-volume, and product-mix analysis.

**Primary Key:** `material_key`

| Column | Data Type | Description |
|---|---|---|
| material_key | Integer | Surrogate material key |
| material_id | Text | Source-system material identifier |
| material_name | Text | Synthetic product name |
| brand | Text | Product brand |
| product_category | Text | Beverage or product category |
| package_type | Text | Bottle, can, fountain, case, or other packaging type |
| package_size | Text | Package size or configuration |
| unit_of_measure | Text | Sales-volume unit |
| active_flag | Boolean | Current material-record indicator |

### DimDriver

**Purpose:** Stores driver master attributes.

**Primary Key:** `driver_key`

| Column | Data Type | Description |
|---|---|---|
| driver_key | Integer | Surrogate driver key |
| driver_id | Text | Source-system driver identifier |
| driver_name | Text | Synthetic driver name |
| home_distribution_center_key | Integer | Driver’s primary distribution center |
| scheduled_daily_hours | Decimal | Standard daily scheduled hours |
| hourly_rate | Decimal | Synthetic regular hourly labor rate |
| active_flag | Boolean | Current driver-record indicator |

### DimRoute

**Purpose:** Stores route master attributes.

**Primary Key:** `route_key`

| Column | Data Type | Description |
|---|---|---|
| route_key | Integer | Surrogate route key |
| route_id | Text | Source-system route identifier |
| route_name | Text | Synthetic route name |
| distribution_center_key | Integer | Route origin distribution center |
| planned_distance_miles | Decimal | Baseline planned route mileage |
| planned_stops | Integer | Expected customer stops |
| route_type | Text | Urban, Suburban, Rural, or Mixed |
| active_flag | Boolean | Current route-record indicator |

### DimVehicle

**Purpose:** Stores vehicle master and expected fuel-efficiency attributes.

**Primary Key:** `vehicle_key`

| Column | Data Type | Description |
|---|---|---|
| vehicle_key | Integer | Surrogate vehicle key |
| vehicle_id | Text | Source-system vehicle identifier |
| truck_number | Text | Business-facing truck number |
| vehicle_type | Text | Truck or vehicle type |
| vehicle_class | Text | Fleet classification |
| capacity_cases | Integer | Estimated case capacity |
| fuel_type | Text | Diesel, Gasoline, Hybrid, or Electric |
| expected_mpg | Decimal | Expected fuel efficiency |
| manufacturer | Text | Vehicle manufacturer |
| model | Text | Vehicle model |
| model_year | Integer | Vehicle model year |
| distribution_center_key | Integer | Assigned distribution center |
| active_flag | Boolean | Current vehicle-record indicator |

### DimSalesOrganization

**Purpose:** Stores the organizational hierarchy used for reporting and filtering.

**Primary Key:** `sales_organization_key`

| Column | Data Type | Description |
|---|---|---|
| sales_organization_key | Integer | Surrogate key |
| region | Text | Business region |
| market_unit | Text | Market unit |
| distribution_center | Text | Distribution center |
| sales_territory | Text | Sales territory |
| active_flag | Boolean | Current hierarchy indicator |

---

### DimMissedReason

**Purpose:** Stores missed-delivery reasons and operational classifications.

**Primary Key:** `missed_reason_key`

| Column | Data Type | Description |
|---|---|---|
| missed_reason_key | Integer | Surrogate key |
| missed_reason_code | Text | Business reason code |
| missed_reason_name | Text | Missed delivery reason |
| reason_category | Text | Customer, Fleet, External, Road, Weather |
| control_classification | Text | Controllable or Uncontrollable |
| active_flag | Boolean | Current record indicator |

---

### DimFrequencyMatrix

**Purpose:** Stores the business rules used by the frequency recommendation engine.

**Primary Key:** `frequency_rule_key`

| Column | Data Type | Description |
|---|---|---|
| frequency_rule_key | Integer | Surrogate key |
| customer_category | Text | Customer category |
| minimum_cases | Integer | Minimum rolling 4-week cases |
| maximum_cases | Integer | Maximum rolling 4-week cases |
| recommended_frequency | Integer | Recommended deliveries per week |
| effective_start_date | Date | Rule effective start date |
| effective_end_date | Date | Rule effective end date |
| active_flag | Boolean | Current rule indicator |

---

# 3. Fact Tables

## FactDeliveryOrder

**Grain:** One delivery/order representing one customer stop.

| Column | Data Type | Description |
|---------|-----------|-------------|
| delivery_order_key | Integer | Surrogate key |
| delivery_order_id | Text | Source delivery/order ID |
| customer_key | Integer | FK to DimCustomer |
| driver_key | Integer | FK to DimDriver |
| vehicle_key | Integer | FK to DimVehicle |
| route_key | Integer | FK to DimRoute |
| delivery_date_key | Integer | FK to DimDate |
| missed_reason_key | Integer | FK to DimMissedReason |
| ordered_cases | Decimal | Ordered cases |
| delivered_cases | Decimal | Delivered cases |
| total_sales | Decimal | Sales amount |
| hotshot_flag | Boolean | Hotshot delivery |
| offday_flag | Boolean | Off-day delivery |
| ontime_flag | Boolean | On-time indicator |
| infull_flag | Boolean | In-full indicator |
| otif_flag | Boolean | OTIF indicator |
| missed_delivery_flag | Boolean | Missed delivery |

---

## FactDriverHours

**Grain:** One Driver × One Route × One Work Date

| Column | Data Type | Description |
|---------|-----------|-------------|
| driver_hours_key | Integer | Surrogate key |
| driver_key | Integer | FK |
| route_key | Integer | FK |
| vehicle_key | Integer | FK |
| work_date_key | Integer | FK |
| regular_hours | Decimal | Regular hours |
| overtime_hours | Decimal | OT hours |
| total_hours | Decimal | Total worked hours |
| total_deliveries | Integer | Deliveries completed |
| total_stops | Integer | Stops completed |
| total_cases | Decimal | Cases delivered |
| miles_driven | Decimal | Miles driven |
