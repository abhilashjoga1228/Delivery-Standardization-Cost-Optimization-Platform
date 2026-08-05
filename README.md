# Delivery Standardization & Cost Optimization Platform

An enterprise analytics and data engineering solution designed to standardize customer delivery schedules, identify inefficient deliveries, reduce transportation costs, improve service performance, and measure sustainability benefits.

> This portfolio project is inspired by a real-world beverage distribution analytics implementation. All data, company names, customer information, identifiers, and performance values used in this repository are synthetic.

---

## Business Problem

Distribution centers may use inconsistent delivery frequencies, route plans, and customer-service practices. This can result in:

- Unnecessary delivery stops
- Low-volume and unprofitable deliveries
- Increased driver overtime
- Higher fuel consumption
- Hotshot and off-day deliveries
- Missed or delayed deliveries
- Inconsistent service-level performance
- Increased carbon emissions

The platform centralizes operational data and provides standardized KPIs, root-cause analysis, and delivery-frequency recommendations.

---

## Project Objectives

- Standardize delivery-performance measurement across distribution centers
- Identify high-cost and low-profit deliveries
- Analyze OTIF and on-time delivery performance
- Measure cases per hour and cases per stop
- Monitor hotshots, off-day deliveries, stops, and driver overtime
- Analyze the causes of missed and delayed deliveries
- Recommend optimized customer delivery frequencies
- Estimate stops, miles, fuel, cost, and CO₂ savings
- Provide executive and operational Power BI reporting

---

## Core KPIs

| Category | KPIs |
|---|---|
| Service | OTIF, SLA, On-Time Delivery, Missed Deliveries |
| Productivity | Cases per Hour, Cases per Stop, Stops, Driver Overtime |
| Exceptions | Hotshots, Off-Day Deliveries |
| Financial | Cost to Serve, Cost per Stop, Delivery Profit |
| Sustainability | Fuel Consumption, CO₂ Emissions, Fuel Saved, CO₂ Saved |
| Optimization | Recommended Frequency, Stops Saved, Miles Saved, Cost Saved |

---

## Solution Architecture

```text
Operational CSV Sources
        |
        v
SQL Server Bronze Layer
        |
        v
SQL Cleaning and Standardization
        |
        v
Silver Business Tables
        |
        v
Gold Star Schema
        |
        v
Power BI Semantic Model
        |
        v
Executive and Operational Reports
