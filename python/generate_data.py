"""
Delivery Standardization & Cost Optimization Platform
Synthetic Source Data Generator

All names, identifiers, locations, transactions, and business values generated
by this script are synthetic and intended only for portfolio demonstration.
"""

from __future__ import annotations

import argparse
import random
from datetime import date, datetime, timedelta
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd


DEFAULT_SEED = 42
DEFAULT_OUTPUT_DIRECTORY = Path("data/raw")


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate synthetic delivery-standardization source data."
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUTPUT_DIRECTORY,
        help="Output directory for generated CSV files.",
    )
    parser.add_argument(
        "--deliveries",
        type=int,
        default=100_000,
        help="Number of delivery orders to generate.",
    )
    parser.add_argument(
        "--customers",
        type=int,
        default=2_500,
        help="Number of customers to generate.",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=DEFAULT_SEED,
        help="Random seed for reproducible results.",
    )
    return parser.parse_args()


def initialize_random_generators(seed: int) -> np.random.Generator:
    random.seed(seed)
    np.random.seed(seed)
    return np.random.default_rng(seed)


def random_timestamp(
    rng: np.random.Generator,
    start: datetime,
    end: datetime,
) -> datetime:
    seconds = int((end - start).total_seconds())
    return start + timedelta(seconds=int(rng.integers(0, seconds + 1)))


def create_sales_organization() -> pd.DataFrame:
    rows: list[dict[str, Any]] = []
    sales_org_number = 1

    hierarchy = {
        "West Region": {
            "Mountain Market Unit": ["Salt Lake DC", "Denver DC"],
            "Pacific Market Unit": ["Seattle DC", "Portland DC"],
        },
        "Central Region": {
            "Midwest Market Unit": ["Chicago DC", "Detroit DC"],
            "Southern Plains Market Unit": ["Dallas DC", "Oklahoma City DC"],
        },
        "East Region": {
            "Northeast Market Unit": ["Boston DC", "Newark DC"],
            "Southeast Market Unit": ["Atlanta DC", "Charlotte DC"],
        },
    }

    base_latitudes = {
        "Salt Lake DC": 40.7608,
        "Denver DC": 39.7392,
        "Seattle DC": 47.6062,
        "Portland DC": 45.5152,
        "Chicago DC": 41.8781,
        "Detroit DC": 42.3314,
        "Dallas DC": 32.7767,
        "Oklahoma City DC": 35.4676,
        "Boston DC": 42.3601,
        "Newark DC": 40.7357,
        "Atlanta DC": 33.7490,
        "Charlotte DC": 35.2271,
    }

    base_longitudes = {
        "Salt Lake DC": -111.8910,
        "Denver DC": -104.9903,
        "Seattle DC": -122.3321,
        "Portland DC": -122.6784,
        "Chicago DC": -87.6298,
        "Detroit DC": -83.0458,
        "Dallas DC": -96.7970,
        "Oklahoma City DC": -97.5164,
        "Boston DC": -71.0589,
        "Newark DC": -74.1724,
        "Atlanta DC": -84.3880,
        "Charlotte DC": -80.8431,
    }

    for region_index, (region, market_units) in enumerate(hierarchy.items(), start=1):
        for market_index, (market_unit, distribution_centers) in enumerate(
            market_units.items(), start=1
        ):
            for dc_index, distribution_center in enumerate(
                distribution_centers, start=1
            ):
                for territory_number in range(1, 5):
                    rows.append(
                        {
                            "sales_organization_id": (
                                f"SO{sales_org_number:04d}"
                            ),
                            "region_id": f"R{region_index:02d}",
                            "region_name": region,
                            "market_unit_id": (
                                f"MU{region_index:02d}{market_index:02d}"
                            ),
                            "market_unit_name": market_unit,
                            "distribution_center_id": (
                                f"DC{region_index:02d}"
                                f"{market_index:02d}{dc_index:02d}"
                            ),
                            "distribution_center_name": distribution_center,
                            "sales_territory_id": (
                                f"T{sales_org_number:04d}"
                            ),
                            "sales_territory_name": (
                                f"{distribution_center} Territory "
                                f"{territory_number}"
                            ),
                            "distribution_center_latitude": (
                                base_latitudes[distribution_center]
                            ),
                            "distribution_center_longitude": (
                                base_longitudes[distribution_center]
                            ),
                            "active_flag": True,
                        }
                    )
                    sales_org_number += 1

    return pd.DataFrame(rows)


def create_customers(
    rng: np.random.Generator,
    sales_organization: pd.DataFrame,
    customer_count: int,
) -> pd.DataFrame:
    categories = [
        "Club",
        "Retail",
        "Convenience Retail",
        "Restaurant",
        "Institutional",
    ]
    category_probabilities = [0.08, 0.31, 0.36, 0.18, 0.07]

    business_names = [
        "Summit Market",
        "Corner Stop",
        "Valley Grocery",
        "Metro Foods",
        "Pioneer Retail",
        "Evergreen Mart",
        "Canyon Cafe",
        "Lakeside Store",
        "Mountain Club",
        "Central Dining",
    ]

    sales_org_records = sales_organization.to_dict("records")
    rows: list[dict[str, Any]] = []

    for customer_number in range(1, customer_count + 1):
        sales_org = random.choice(sales_org_records)
        category = rng.choice(categories, p=category_probabilities)

        asm_number = int(sales_org["sales_territory_id"][1:]) // 4 + 1
        mdm_number = customer_number % 120 + 1

        rows.append(
            {
                "customer_id": f"CUST{customer_number:06d}",
                "customer_name": (
                    f"{random.choice(business_names)} {customer_number:04d}"
                ),
                "customer_category": category,
                "sales_organization_id": (
                    sales_org["sales_organization_id"]
                ),
                "area_sales_manager_id": f"ASM{asm_number:03d}",
                "area_sales_manager_name": (
                    f"Area Sales Manager {asm_number:03d}"
                ),
                "market_development_manager_id": f"MDM{mdm_number:03d}",
                "market_development_manager_name": (
                    f"Market Development Manager {mdm_number:03d}"
                ),
                "current_weekly_frequency": int(
                    rng.choice([1, 2, 3, 4, 5], p=[0.14, 0.24, 0.32, 0.20, 0.10])
                ),
                "customer_latitude": round(
                    float(sales_org["distribution_center_latitude"])
                    + float(rng.normal(0, 0.25)),
                    6,
                ),
                "customer_longitude": round(
                    float(sales_org["distribution_center_longitude"])
                    + float(rng.normal(0, 0.25)),
                    6,
                ),
                "customer_status": "Active",
                "active_flag": True,
            }
        )

    return pd.DataFrame(rows)


def create_materials() -> pd.DataFrame:
    categories = {
        "Sparkling Beverage": ["Classic Cola", "Diet Cola", "Lemon Lime"],
        "Water": ["Spring Water", "Purified Water", "Sparkling Water"],
        "Sports Drink": ["Citrus Sports", "Berry Sports"],
        "Juice": ["Orange Juice", "Apple Juice", "Fruit Punch"],
        "Energy Drink": ["Original Energy", "Zero Energy"],
    }
    package_types = ["Can", "Bottle", "Fountain", "Case"]
    package_sizes = ["12 oz", "16.9 oz", "20 oz", "1 Liter", "2 Liter"]

    rows: list[dict[str, Any]] = []
    material_number = 1

    for category, products in categories.items():
        for product in products:
            for package_type in package_types[:3]:
                rows.append(
                    {
                        "material_id": f"MAT{material_number:05d}",
                        "material_name": f"{product} {package_type}",
                        "brand_name": product,
                        "product_category": category,
                        "package_type": package_type,
                        "package_size": random.choice(package_sizes),
                        "unit_of_measure": "CASE",
                        "units_per_case": random.choice([6, 12, 18, 24]),
                        "active_flag": True,
                    }
                )
                material_number += 1

    return pd.DataFrame(rows)


def create_missed_reasons() -> pd.DataFrame:
    records = [
        ("CUSTOMER_CLOSED", "Customer Closed", "Customer", "Uncontrollable"),
        ("TRAFFIC", "Traffic", "External Conditions", "Uncontrollable"),
        ("SCHOOL_ZONE", "School Zone", "Road Restriction", "Uncontrollable"),
        ("NO_LEFT_TURN", "No Left Turn", "Road Restriction", "Uncontrollable"),
        ("WEATHER", "Weather", "External Conditions", "Uncontrollable"),
        ("VEHICLE_BREAKDOWN", "Vehicle Breakdown", "Fleet", "Controllable"),
        ("CUSTOMER_REFUSED", "Customer Refused", "Customer", "Uncontrollable"),
        ("DRIVER_DELAY", "Driver Delay", "Operations", "Controllable"),
    ]

    return pd.DataFrame(
        [
            {
                "missed_reason_code": code,
                "missed_reason_name": name,
                "reason_category": category,
                "control_classification": classification,
                "active_flag": True,
            }
            for code, name, category, classification in records
        ]
    )


def create_frequency_matrix() -> pd.DataFrame:
    thresholds = {
        "Club": [(0, 499, 2), (500, 1499, 3), (1500, None, 5)],
        "Retail": [(0, 299, 1), (300, 999, 2), (1000, None, 4)],
        "Convenience Retail": [(0, 199, 1), (200, 699, 2), (700, None, 3)],
        "Restaurant": [(0, 249, 1), (250, 749, 2), (750, None, 3)],
        "Institutional": [(0, 399, 1), (400, 1199, 2), (1200, None, 4)],
    }

    rows: list[dict[str, Any]] = []
    rule_number = 1

    for category, category_thresholds in thresholds.items():
        for minimum, maximum, frequency in category_thresholds:
            rows.append(
                {
                    "frequency_rule_id": f"FR{rule_number:03d}",
                    "customer_category": category,
                    "minimum_rolling_4_week_cases": minimum,
                    "maximum_rolling_4_week_cases": maximum,
                    "recommended_weekly_frequency": frequency,
                    "effective_start_date": "2025-01-01",
                    "effective_end_date": None,
                    "active_flag": True,
                }
            )
            rule_number += 1

    return pd.DataFrame(rows)


def create_drivers_routes_vehicles(
    rng: np.random.Generator,
    sales_organization: pd.DataFrame,
) -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    drivers: list[dict[str, Any]] = []
    routes: list[dict[str, Any]] = []
    vehicles: list[dict[str, Any]] = []

    driver_number = 1
    route_number = 1
    vehicle_number = 1

    for sales_org in sales_organization.to_dict("records"):
        for local_number in range(1, 5):
            drivers.append(
                {
                    "driver_id": f"DRV{driver_number:05d}",
                    "driver_name": f"Driver {driver_number:05d}",
                    "sales_organization_id": sales_org["sales_organization_id"],
                    "scheduled_daily_hours": 8.0,
                    "regular_hourly_rate": round(float(rng.uniform(23, 36)), 2),
                    "overtime_hourly_rate": round(float(rng.uniform(35, 54)), 2),
                    "active_flag": True,
                }
            )

            routes.append(
                {
                    "route_id": f"ROUTE{route_number:05d}",
                    "route_name": f"Route {route_number:05d}",
                    "sales_organization_id": sales_org["sales_organization_id"],
                    "route_type": random.choice(
                        ["Urban", "Suburban", "Rural", "Mixed"]
                    ),
                    "planned_distance_miles": round(
                        float(rng.uniform(40, 220)), 2
                    ),
                    "planned_stops": int(rng.integers(8, 31)),
                    "planned_duration_hours": round(
                        float(rng.uniform(6, 10)), 2
                    ),
                    "active_flag": True,
                }
            )

            vehicles.append(
                {
                    "vehicle_id": f"VEH{vehicle_number:05d}",
                    "truck_number": f"TRK-{vehicle_number:04d}",
                    "sales_organization_id": sales_org["sales_organization_id"],
                    "vehicle_type": random.choice(
                        ["Box Truck", "Straight Truck", "Tractor Trailer"]
                    ),
                    "vehicle_class": random.choice(
                        ["Medium Duty", "Heavy Duty"]
                    ),
                    "capacity_cases": int(rng.integers(600, 1801)),
                    "fuel_type": "Diesel",
                    "expected_mpg": round(float(rng.uniform(6.0, 10.5)), 2),
                    "model_year": int(rng.integers(2018, 2027)),
                    "active_flag": True,
                }
            )

            driver_number += 1
            route_number += 1
            vehicle_number += 1

    return (
        pd.DataFrame(drivers),
        pd.DataFrame(routes),
        pd.DataFrame(vehicles),
    )


def create_delivery_orders(
    rng: np.random.Generator,
    customers: pd.DataFrame,
    drivers: pd.DataFrame,
    routes: pd.DataFrame,
    vehicles: pd.DataFrame,
    missed_reasons: pd.DataFrame,
    delivery_count: int,
) -> pd.DataFrame:
    start = datetime(2024, 1, 1, 6, 0)
    end = datetime(2026, 7, 31, 18, 0)

    customers_by_org = {
        key: group.to_dict("records")
        for key, group in customers.groupby("sales_organization_id")
    }
    drivers_by_org = {
        key: group.to_dict("records")
        for key, group in drivers.groupby("sales_organization_id")
    }
    routes_by_org = {
        key: group.to_dict("records")
        for key, group in routes.groupby("sales_organization_id")
    }
    vehicles_by_org = {
        key: group.to_dict("records")
        for key, group in vehicles.groupby("sales_organization_id")
    }

    reason_codes = missed_reasons["missed_reason_code"].tolist()
    sales_org_ids = list(customers_by_org.keys())
    rows: list[dict[str, Any]] = []

    for delivery_number in range(1, delivery_count + 1):
        sales_org_id = random.choice(sales_org_ids)
        customer = random.choice(customers_by_org[sales_org_id])
        driver = random.choice(drivers_by_org[sales_org_id])
        route = random.choice(routes_by_org[sales_org_id])
        vehicle = random.choice(vehicles_by_org[sales_org_id])

        planned_timestamp = random_timestamp(rng, start, end)
        ordered_cases = round(float(rng.gamma(4.5, 18.0)), 2)

        missed = bool(rng.random() < 0.035)
        late = bool(rng.random() < 0.11)
        short_delivery = bool(rng.random() < 0.06)

        if missed:
            delivered_cases = 0.0
            actual_timestamp = None
            delay_minutes = None
            missed_reason = random.choice(reason_codes)
            delivery_status = "Missed"
        else:
            delivered_cases = (
                ordered_cases
                if not short_delivery
                else round(ordered_cases * float(rng.uniform(0.70, 0.98)), 2)
            )
            delay_minutes = (
                int(rng.integers(16, 181))
                if late
                else int(rng.integers(-60, 16))
            )
            actual_timestamp = planned_timestamp + timedelta(
                minutes=delay_minutes
            )
            missed_reason = None
            delivery_status = "Completed"

        on_time = not missed and not late
        in_full = not missed and delivered_cases >= ordered_cases
        hotshot = bool(rng.random() < 0.025)
        off_day = bool(rng.random() < 0.045)
        sla = not missed and delay_minutes is not None and delay_minutes <= 30

        rows.append(
            {
                "delivery_order_id": f"DEL{delivery_number:09d}",
                "source_order_number": f"ORD{delivery_number:09d}",
                "shipment_number": f"SHP{delivery_number:09d}",
                "order_date": (planned_timestamp - timedelta(days=1)).date(),
                "planned_delivery_timestamp": planned_timestamp,
                "actual_delivery_timestamp": actual_timestamp,
                "customer_id": customer["customer_id"],
                "driver_id": driver["driver_id"],
                "route_id": route["route_id"],
                "vehicle_id": vehicle["vehicle_id"],
                "sales_organization_id": sales_org_id,
                "missed_reason_code": missed_reason,
                "ordered_cases": ordered_cases,
                "delivered_cases": delivered_cases,
                "undelivered_cases": round(
                    ordered_cases - delivered_cases, 2
                ),
                "total_sales_amount": round(delivered_cases * float(rng.uniform(14, 29)), 2),
                "planned_stop_count": 1,
                "actual_stop_count": 0 if missed else 1,
                "delivery_delay_minutes": delay_minutes,
                "hotshot_flag": hotshot,
                "off_day_flag": off_day,
                "on_time_flag": on_time,
                "in_full_flag": in_full,
                "otif_flag": on_time and in_full,
                "sla_flag": sla,
                "missed_delivery_flag": missed,
                "delivery_status": delivery_status,
            }
        )

    return pd.DataFrame(rows)


def create_material_sales(
    rng: np.random.Generator,
    deliveries: pd.DataFrame,
    materials: pd.DataFrame,
) -> pd.DataFrame:
    material_records = materials.to_dict("records")
    rows: list[dict[str, Any]] = []
    transaction_number = 1

    completed = deliveries[
        deliveries["delivered_cases"] > 0
    ].reset_index(drop=True)

    for delivery in completed.to_dict("records"):
        line_count = int(rng.integers(1, 5))
        selected_materials = random.sample(
            material_records,
            k=min(line_count, len(material_records)),
        )

        weights = rng.dirichlet(np.ones(len(selected_materials)))
        allocated_cases = (
            weights * float(delivery["delivered_cases"])
        )

        for line_number, (material, cases) in enumerate(
            zip(selected_materials, allocated_cases), start=1
        ):
            cases = round(float(cases), 2)
            unit_price = float(rng.uniform(14, 29))
            gross_sales = round(cases * unit_price, 2)
            discount = round(gross_sales * float(rng.uniform(0, 0.08)), 2)

            rows.append(
                {
                    "sales_transaction_id": f"SALE{transaction_number:010d}",
                    "sales_transaction_line_number": line_number,
                    "delivery_order_id": delivery["delivery_order_id"],
                    "purchase_date": pd.Timestamp(
                        delivery["planned_delivery_timestamp"]
                    ).date(),
                    "customer_id": delivery["customer_id"],
                    "material_id": material["material_id"],
                    "sales_organization_id": (
                        delivery["sales_organization_id"]
                    ),
                    "cases_sold": cases,
                    "gross_sales_amount": gross_sales,
                    "discount_amount": discount,
                    "net_sales_amount": round(gross_sales - discount, 2),
                }
            )
        transaction_number += 1

    return pd.DataFrame(rows)


def create_driver_hours(
    rng: np.random.Generator,
    deliveries: pd.DataFrame,
) -> pd.DataFrame:
    working = deliveries.copy()
    working["work_date"] = pd.to_datetime(
        working["planned_delivery_timestamp"]
    ).dt.date

    grouped = (
        working.groupby(
            [
                "work_date",
                "driver_id",
                "route_id",
                "vehicle_id",
                "sales_organization_id",
            ],
            as_index=False,
        )
        .agg(
            total_deliveries=("delivery_order_id", "count"),
            total_stops=("actual_stop_count", "sum"),
            missed_stops=("missed_delivery_flag", "sum"),
            total_cases_delivered=("delivered_cases", "sum"),
        )
    )

    grouped["scheduled_hours"] = 8.0
    grouped["total_hours"] = (
        5.5
        + grouped["total_deliveries"] * 0.17
        + rng.normal(0.7, 0.8, len(grouped))
    ).clip(4.5, 13.0).round(2)

    grouped["regular_hours"] = grouped["total_hours"].clip(upper=8.0)
    grouped["overtime_hours"] = (
        grouped["total_hours"] - 8.0
    ).clip(lower=0).round(2)
    grouped["completed_stops"] = grouped["total_stops"]
    grouped["planned_miles"] = (
        grouped["total_deliveries"] * rng.uniform(3.5, 7.5, len(grouped))
    ).round(2)
    grouped["miles_driven"] = (
        grouped["planned_miles"] * rng.uniform(0.95, 1.25, len(grouped))
    ).round(2)

    return grouped


def create_cost_to_serve(
    rng: np.random.Generator,
    deliveries: pd.DataFrame,
) -> pd.DataFrame:
    working = deliveries.copy()
    working["activity_date"] = pd.to_datetime(
        working["planned_delivery_timestamp"]
    ).dt.date

    grouped = (
        working.groupby(
            ["activity_date", "customer_id", "sales_organization_id"],
            as_index=False,
        )
        .agg(
            total_sales_amount=("total_sales_amount", "sum"),
            total_cases=("delivered_cases", "sum"),
            total_stops=("actual_stop_count", "sum"),
            hotshots=("hotshot_flag", "sum"),
            off_day_deliveries=("off_day_flag", "sum"),
        )
    )

    grouped["driver_labor_cost"] = (
        grouped["total_stops"] * rng.uniform(28, 52, len(grouped))
    ).round(2)
    grouped["overtime_cost"] = (
        grouped["total_stops"] * rng.uniform(0, 14, len(grouped))
    ).round(2)
    grouped["fuel_cost"] = (
        grouped["total_stops"] * rng.uniform(8, 25, len(grouped))
    ).round(2)
    grouped["vehicle_operating_cost"] = (
        grouped["total_stops"] * rng.uniform(10, 35, len(grouped))
    ).round(2)
    grouped["delivery_handling_cost"] = (
        grouped["total_cases"] * rng.uniform(0.15, 0.55, len(grouped))
    ).round(2)
    grouped["hotshot_cost"] = (grouped["hotshots"] * 185).round(2)
    grouped["off_day_delivery_cost"] = (
        grouped["off_day_deliveries"] * 110
    ).round(2)
    grouped["other_operational_cost"] = (
        grouped["total_stops"] * rng.uniform(2, 12, len(grouped))
    ).round(2)

    cost_columns = [
        "driver_labor_cost",
        "overtime_cost",
        "fuel_cost",
        "vehicle_operating_cost",
        "delivery_handling_cost",
        "hotshot_cost",
        "off_day_delivery_cost",
        "other_operational_cost",
    ]
    grouped["total_operational_cost"] = grouped[cost_columns].sum(axis=1).round(2)

    return grouped


def create_fuel_purchases(
    rng: np.random.Generator,
    driver_hours: pd.DataFrame,
) -> pd.DataFrame:
    rows: list[dict[str, Any]] = []
    odometer_by_vehicle: dict[str, float] = {}

    sampled = driver_hours.sample(
        frac=0.35,
        random_state=DEFAULT_SEED,
    ).sort_values(["vehicle_id", "work_date"])

    for purchase_number, record in enumerate(
        sampled.to_dict("records"), start=1
    ):
        vehicle_id = record["vehicle_id"]
        current_odometer = odometer_by_vehicle.get(
            vehicle_id,
            float(rng.uniform(30_000, 180_000)),
        )
        current_odometer += float(record["miles_driven"])
        odometer_by_vehicle[vehicle_id] = current_odometer

        gallons = round(float(rng.uniform(18, 90)), 3)
        unit_price = round(float(rng.uniform(3.10, 4.85)), 4)

        purchase_date = pd.Timestamp(record["work_date"])
        purchase_timestamp = purchase_date + pd.Timedelta(
            hours=int(rng.integers(5, 20)),
            minutes=int(rng.integers(0, 60)),
        )

        rows.append(
            {
                "purchase_order_number": f"FPO{purchase_number:08d}",
                "purchase_order_line_number": 1,
                "invoice_number": f"FINV{purchase_number:08d}",
                "purchase_timestamp": purchase_timestamp,
                "vehicle_id": vehicle_id,
                "sales_organization_id": (
                    record["sales_organization_id"]
                ),
                "vendor_id": f"VENDOR{int(rng.integers(1, 21)):03d}",
                "vendor_name": (
                    f"Fuel Vendor {int(rng.integers(1, 21)):03d}"
                ),
                "fuel_type": "Diesel",
                "gallons_purchased": gallons,
                "fuel_unit_price": unit_price,
                "fuel_purchase_cost": round(gallons * unit_price, 2),
                "odometer_reading": round(current_odometer, 2),
            }
        )

    return pd.DataFrame(rows)


def create_frequency_recommendations(
    material_sales: pd.DataFrame,
    customers: pd.DataFrame,
    frequency_matrix: pd.DataFrame,
) -> pd.DataFrame:
    recommendation_date = pd.Timestamp("2026-08-01")
    lookback_start = recommendation_date - pd.Timedelta(days=28)

    working = material_sales.copy()
    working["purchase_date"] = pd.to_datetime(working["purchase_date"])

    recent = working[
        (working["purchase_date"] >= lookback_start)
        & (working["purchase_date"] < recommendation_date)
    ]

    rolling_cases = (
        recent.groupby("customer_id", as_index=False)["cases_sold"]
        .sum()
        .rename(columns={"cases_sold": "rolling_4_week_cases"})
    )

    result = customers.merge(rolling_cases, on="customer_id", how="left")
    result["rolling_4_week_cases"] = result[
        "rolling_4_week_cases"
    ].fillna(0)

    rules = frequency_matrix.to_dict("records")

    def find_frequency(row: pd.Series) -> tuple[str, int]:
        for rule in rules:
            maximum = rule["maximum_rolling_4_week_cases"]
            maximum_match = pd.isna(maximum) or (
                row["rolling_4_week_cases"] <= maximum
            )

            if (
                row["customer_category"] == rule["customer_category"]
                and row["rolling_4_week_cases"]
                >= rule["minimum_rolling_4_week_cases"]
                and maximum_match
            ):
                return (
                    rule["frequency_rule_id"],
                    int(rule["recommended_weekly_frequency"]),
                )
        return "UNMATCHED", int(row["current_weekly_frequency"])

    matched = result.apply(find_frequency, axis=1)
    result["frequency_rule_id"] = [item[0] for item in matched]
    result["recommended_weekly_frequency"] = [item[1] for item in matched]
    result["average_weekly_cases"] = (
        result["rolling_4_week_cases"] / 4
    ).round(2)
    result["weekly_frequency_change"] = (
        result["recommended_weekly_frequency"]
        - result["current_weekly_frequency"]
    )
    result["estimated_weekly_stops_saved"] = (
        result["current_weekly_frequency"]
        - result["recommended_weekly_frequency"]
    ).clip(lower=0)
    result["estimated_annual_stops_saved"] = (
        result["estimated_weekly_stops_saved"] * 52
    )
    result["estimated_annual_miles_saved"] = (
        result["estimated_annual_stops_saved"] * 6.2
    ).round(2)
    result["estimated_annual_driver_hours_saved"] = (
        result["estimated_annual_stops_saved"] * 0.38
    ).round(2)
    result["estimated_annual_fuel_saved"] = (
        result["estimated_annual_miles_saved"] / 8.2
    ).round(2)
    result["estimated_annual_cost_saved"] = (
        result["estimated_annual_stops_saved"] * 74
    ).round(2)
    result["estimated_annual_co2_saved"] = (
        result["estimated_annual_fuel_saved"] * 10.21
    ).round(2)

    output = result[
        [
            "customer_id",
            "sales_organization_id",
            "frequency_rule_id",
            "rolling_4_week_cases",
            "average_weekly_cases",
            "current_weekly_frequency",
            "recommended_weekly_frequency",
            "weekly_frequency_change",
            "estimated_weekly_stops_saved",
            "estimated_annual_stops_saved",
            "estimated_annual_miles_saved",
            "estimated_annual_driver_hours_saved",
            "estimated_annual_fuel_saved",
            "estimated_annual_cost_saved",
            "estimated_annual_co2_saved",
        ]
    ].copy()

    output.insert(
        0,
        "recommendation_id",
        [f"REC{number:07d}" for number in range(1, len(output) + 1)],
    )
    output.insert(1, "recommendation_date", recommendation_date.date())
    output["recommendation_status"] = "Generated"
    output["implementation_status"] = "Pending Review"
    output["review_required_flag"] = True
    output["approved_flag"] = False

    return output


def save_csv(
    dataframe: pd.DataFrame,
    output_directory: Path,
    filename: str,
) -> None:
    output_path = output_directory / filename
    dataframe.to_csv(output_path, index=False)
    print(f"Created {output_path} — {len(dataframe):,} rows")


def main() -> None:
    args = parse_arguments()

    if args.deliveries <= 0 or args.customers <= 0:
        raise ValueError("Delivery and customer counts must be greater than zero.")

    args.output.mkdir(parents=True, exist_ok=True)
    rng = initialize_random_generators(args.seed)

    print("Generating synthetic delivery-standardization datasets...")

    sales_organization = create_sales_organization()
    customers = create_customers(
        rng,
        sales_organization,
        args.customers,
    )
    materials = create_materials()
    missed_reasons = create_missed_reasons()
    frequency_matrix = create_frequency_matrix()

    drivers, routes, vehicles = create_drivers_routes_vehicles(
        rng,
        sales_organization,
    )

    deliveries = create_delivery_orders(
        rng,
        customers,
        drivers,
        routes,
        vehicles,
        missed_reasons,
        args.deliveries,
    )

    material_sales = create_material_sales(
        rng,
        deliveries,
        materials,
    )

    driver_hours = create_driver_hours(rng, deliveries)
    customer_cost = create_cost_to_serve(rng, deliveries)
    fuel_purchases = create_fuel_purchases(rng, driver_hours)
    recommendations = create_frequency_recommendations(
        material_sales,
        customers,
        frequency_matrix,
    )

    datasets = {
        "sales_organization.csv": sales_organization,
        "customers.csv": customers,
        "materials.csv": materials,
        "missed_delivery_reasons.csv": missed_reasons,
        "frequency_matrix.csv": frequency_matrix,
        "drivers.csv": drivers,
        "routes.csv": routes,
        "vehicles.csv": vehicles,
        "delivery_orders.csv": deliveries,
        "customer_material_sales.csv": material_sales,
        "driver_hours.csv": driver_hours,
        "customer_cost_to_serve.csv": customer_cost,
        "fuel_purchases.csv": fuel_purchases,
        "frequency_recommendations.csv": recommendations,
    }

    for filename, dataframe in datasets.items():
        save_csv(dataframe, args.output, filename)

    print("\nSynthetic data generation completed successfully.")


if __name__ == "__main__":
    main()
