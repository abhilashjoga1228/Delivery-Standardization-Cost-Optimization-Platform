
# KPI Definitions

## 1. Purpose

This document defines the business KPIs used in the Delivery Standardization & Cost Optimization Platform.

Each KPI includes:

- Business definition
- Calculation logic
- Data source
- Reporting purpose

---

# 2. Service KPIs

## OTIF %

**Definition**

Percentage of delivery orders completed both **On Time** and **In Full**.

**Business Rule**

A delivery is considered OTIF when:

- On Time = Yes
- In Full = Yes

**Calculation**

```
OTIF % =
OTIF Delivery Orders
/
Total Eligible Delivery Orders
```

**Source Table**

- FactDeliveryOrder

**Business Value**

Measures customer service performance and overall delivery reliability.

---

## On-Time Delivery %

**Definition**

Percentage of deliveries completed within the planned delivery window.

**Calculation**

```
On-Time Delivery % =
On-Time Deliveries
/
Total Deliveries
```

**Source Table**

- FactDeliveryOrder

---

## Missed Delivery Rate

**Definition**

Percentage of deliveries that were not completed.

**Calculation**

```
Missed Delivery Rate =
Missed Deliveries
/
Total Deliveries
```

**Source Table**

- FactDeliveryOrder

---

## SLA %

**Definition**

Percentage of deliveries meeting the agreed customer service level.

**Calculation**

```
SLA % =
Deliveries Meeting SLA
/
Eligible Deliveries
```

**Source Table**

- FactDeliveryOrder

---

# 3. Productivity KPIs

## Cases per Hour

**Definition**

Average cases delivered per driver hour.

**Calculation**

```
Cases per Hour =
Total Delivered Cases
/
Total Driver Hours
```

**Source Tables**

- FactDriverHours
- FactDeliveryOrder

---

## Cases per Stop

**Definition**

Average delivered cases for each customer stop.

**Calculation**

```
Cases per Stop =
Delivered Cases
/
Total Stops
```

**Source Table**

- FactDeliveryOrder

---

## Driver Overtime Hours

**Definition**

Total overtime worked by drivers.

**Source Table**

- FactDriverHours

---

## Total Stops

**Definition**

Total customer delivery stops.

Since one delivery order equals one stop:

```
Total Stops =
Count of Delivery Orders
```

**Source Table**

- FactDeliveryOrder

---

# 4. Exception KPIs

## Hotshots

Emergency deliveries performed outside the normal schedule.

**Source Table**

- FactDeliveryOrder

---

## Off-Day Deliveries

Deliveries performed outside the customer's planned delivery schedule.

**Source Table**

- FactDeliveryOrder

---

## Missed Delivery Reasons

Analyzed by:

- Customer Closed
- Traffic
- School Zone
- No Left Turn
- Weather
- Vehicle Breakdown
- Customer Refused
- Driver Delay

These can also be grouped into:

- Controllable
- Uncontrollable

**Source Table**

- DimMissedReason

---

# 5. Financial KPIs

## Cost to Serve

Customer operational cost supplied by the source system.

**Calculation**

```
Cost to Serve =
Sum(Operational Cost)
```

**Source Table**

- FactCustomerCostToServe

---

## Cost per Stop

```
Cost per Stop =
Cost to Serve
/
Total Stops
```

---

## Cost per Case

```
Cost per Case =
Cost to Serve
/
Total Cases
```

---

## Customer Profitability

```
Customer Profitability =
Total Sales
-
Cost to Serve
```

---

# 6. Sustainability KPIs

## Fuel Consumption

Total gallons purchased.

**Source**

- FactFuelPurchase

---

## Fuel Cost

Total fuel purchase cost.

---

## Fuel Efficiency (MPG)

```
Miles Driven
/
Gallons Purchased
```

Uses:

- FactDriverHours
- FactFuelPurchase

---

## CO₂ Emissions

Estimated using fuel consumption.

---

## CO₂ Savings

Estimated reduction after implementing delivery-frequency recommendations.

---

# 7. Customer Health KPIs

## Active Customers

Customers with purchases during the selected reporting period.

---

## Existing Customers

Customers with purchases in both:

- Selected period
- Previous 365 days

---

## New Customers

Customers purchasing during the selected period with **no purchases in the previous 365 days**.

---

## Reactivated Customers

Customers purchasing during the selected period after more than **365 days of inactivity**.

---

## Churned Customers

Customers with **no purchases during the previous 365 days** as of the selected reporting date.

All customer health metrics are calculated dynamically in the Power BI semantic model.

---

# 8. Frequency Recommendation KPIs

## Current Weekly Frequency

Current delivery frequency assigned to the customer.

---

## Recommended Weekly Frequency

Business-rule recommendation based on:

- Customer Category
- Rolling 4-Week Cases Sold

---

## Stops Saved

Estimated reduction in customer stops after implementation.

---

## Miles Saved

Estimated reduction in route miles.

---

## Fuel Saved

Estimated fuel reduction.

---

## Cost Saved

Estimated operational cost reduction.

---

## CO₂ Saved

Estimated reduction in carbon emissions.
