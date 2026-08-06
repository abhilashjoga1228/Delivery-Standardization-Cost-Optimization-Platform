/*
===============================================================================
Project: Delivery Standardization & Cost Optimization Platform
File: 03_Create_Facts.sql
Platform: Microsoft Fabric Warehouse
Purpose: Create Gold-layer fact and bridge tables
===============================================================================

Prerequisites:
- Run 01_Create_Schema.sql first.
- Run 02_Create_Dimensions.sql before this script.

Deployment order:
1. Create schema
2. Create dimensions
3. Create facts
4. Add primary keys
5. Add unique keys
6. Add foreign keys
7. Run validation tests
===============================================================================
*/


/*==============================================================================
  1. FACT DELIVERY ORDER

  Grain:
  One row per delivery/order.

  Business rule:
  One delivery/order represents one customer stop.
==============================================================================*/

CREATE TABLE gold.FactDeliveryOrder
(
    DeliveryOrderKey            BIGINT          NOT NULL,
    DeliveryOrderID             VARCHAR(50)     NOT NULL,
    SourceOrderNumber           VARCHAR(50)     NULL,
    ShipmentNumber              VARCHAR(50)     NULL,

    OrderDateKey                INT             NOT NULL,
    PlannedDeliveryDateKey      INT             NOT NULL,
    ActualDeliveryDateKey       INT             NULL,

    CustomerKey                 BIGINT          NOT NULL,
    DriverKey                   BIGINT          NOT NULL,
    RouteKey                    BIGINT          NOT NULL,
    VehicleKey                  BIGINT          NOT NULL,
    SalesOrganizationKey        BIGINT          NOT NULL,
    MissedReasonKey             BIGINT          NULL,

    PlannedDeliveryTimestamp    DATETIME2(6)    NULL,
    ActualDeliveryTimestamp     DATETIME2(6)    NULL,

    OrderedCases                DECIMAL(18,2)   NOT NULL,
    DeliveredCases              DECIMAL(18,2)   NOT NULL,
    UndeliveredCases            DECIMAL(18,2)   NOT NULL,
    TotalSalesAmount            DECIMAL(18,2)   NOT NULL,

    PlannedStopCount            SMALLINT        NOT NULL,
    ActualStopCount             SMALLINT        NOT NULL,
    DeliveryDelayMinutes        INT             NULL,

    HotshotFlag                 BIT             NOT NULL,
    OffDayFlag                  BIT             NOT NULL,
    OnTimeFlag                  BIT             NOT NULL,
    InFullFlag                  BIT             NOT NULL,
    OTIFFlag                    BIT             NOT NULL,
    SLAFlag                     BIT             NOT NULL,
    MissedDeliveryFlag          BIT             NOT NULL,

    DeliveryStatus              VARCHAR(30)     NOT NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO


/*==============================================================================
  2. FACT DRIVER HOURS

  Grain:
  One driver x one route x one vehicle x one work date.
==============================================================================*/

CREATE TABLE gold.FactDriverHours
(
    DriverHoursKey              BIGINT          NOT NULL,

    WorkDateKey                 INT             NOT NULL,
    DriverKey                   BIGINT          NOT NULL,
    RouteKey                    BIGINT          NOT NULL,
    VehicleKey                  BIGINT          NOT NULL,
    SalesOrganizationKey        BIGINT          NOT NULL,

    ShiftStartTimestamp         DATETIME2(6)    NULL,
    ShiftEndTimestamp           DATETIME2(6)    NULL,

    ScheduledHours              DECIMAL(8,2)    NOT NULL,
    RegularHours                DECIMAL(8,2)    NOT NULL,
    OvertimeHours               DECIMAL(8,2)    NOT NULL,
    TotalHours                  DECIMAL(8,2)    NOT NULL,

    TotalDeliveries             INT             NOT NULL,
    TotalStops                  INT             NOT NULL,
    CompletedStops              INT             NOT NULL,
    MissedStops                 INT             NOT NULL,

    TotalCasesDelivered         DECIMAL(18,2)   NOT NULL,
    PlannedMiles                DECIMAL(18,2)   NULL,
    MilesDriven                 DECIMAL(18,2)   NOT NULL,

    RegularLaborCost            DECIMAL(18,2)   NULL,
    OvertimeLaborCost           DECIMAL(18,2)   NULL,
    TotalLaborCost              DECIMAL(18,2)   NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO


/*==============================================================================
  3. FACT CUSTOMER MATERIAL VOLUME

  Grain:
  One customer x one material x one sales transaction line.
==============================================================================*/

CREATE TABLE gold.FactCustomerMaterialVolume
(
    CustomerMaterialVolumeKey   BIGINT          NOT NULL,

    SalesTransactionID          VARCHAR(50)     NOT NULL,
    SalesTransactionLineNumber  INT             NOT NULL,
    DeliveryOrderID             VARCHAR(50)     NULL,

    PurchaseDateKey             INT             NOT NULL,
    CustomerKey                 BIGINT          NOT NULL,
    MaterialKey                 BIGINT          NOT NULL,
    SalesOrganizationKey        BIGINT          NOT NULL,

    CasesSold                   DECIMAL(18,2)   NOT NULL,
    UnitsSold                   DECIMAL(18,2)   NULL,

    GrossSalesAmount            DECIMAL(18,2)   NOT NULL,
    DiscountAmount              DECIMAL(18,2)   NULL,
    NetSalesAmount              DECIMAL(18,2)   NOT NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO


/*==============================================================================
  4. FACT CUSTOMER COST TO SERVE

  Grain:
  One customer x one activity date.

  Source:
  Operational cost is supplied at customer-date level.
==============================================================================*/

CREATE TABLE gold.FactCustomerCostToServe
(
    CustomerCostToServeKey      BIGINT          NOT NULL,

    ActivityDateKey             INT             NOT NULL,
    CustomerKey                 BIGINT          NOT NULL,
    SalesOrganizationKey        BIGINT          NOT NULL,

    TotalSalesAmount            DECIMAL(18,2)   NOT NULL,
    TotalCases                  DECIMAL(18,2)   NOT NULL,
    TotalStops                  INT             NOT NULL,

    DriverLaborCost             DECIMAL(18,2)   NULL,
    OvertimeCost                DECIMAL(18,2)   NULL,
    FuelCost                    DECIMAL(18,2)   NULL,
    VehicleOperatingCost        DECIMAL(18,2)   NULL,
    DeliveryHandlingCost        DECIMAL(18,2)   NULL,
    HotshotCost                 DECIMAL(18,2)   NULL,
    OffDayDeliveryCost          DECIMAL(18,2)   NULL,
    OtherOperationalCost        DECIMAL(18,2)   NULL,

    TotalOperationalCost        DECIMAL(18,2)   NOT NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO


/*==============================================================================
  5. FACT FREQUENCY RECOMMENDATION

  Grain:
  One customer x one recommendation-run date.
==============================================================================*/

CREATE TABLE gold.FactFrequencyRecommendation
(
    FrequencyRecommendationKey      BIGINT          NOT NULL,
    RecommendationID                VARCHAR(50)     NOT NULL,

    RecommendationDateKey           INT             NOT NULL,
    ImplementationDateKey           INT             NULL,

    CustomerKey                     BIGINT          NOT NULL,
    FrequencyRuleKey                BIGINT          NOT NULL,
    SalesOrganizationKey            BIGINT          NOT NULL,

    Rolling4WeekCases               DECIMAL(18,2)   NOT NULL,
    AverageWeeklyCases              DECIMAL(18,2)   NOT NULL,

    CurrentWeeklyFrequency          SMALLINT        NOT NULL,
    RecommendedWeeklyFrequency      SMALLINT        NOT NULL,
    WeeklyFrequencyChange           SMALLINT        NOT NULL,

    EstimatedWeeklyStopsSaved       DECIMAL(18,2)   NOT NULL,
    EstimatedAnnualStopsSaved       DECIMAL(18,2)   NOT NULL,
    EstimatedAnnualMilesSaved       DECIMAL(18,2)   NOT NULL,
    EstimatedAnnualDriverHoursSaved DECIMAL(18,2)   NOT NULL,
    EstimatedAnnualFuelSaved        DECIMAL(18,2)   NOT NULL,
    EstimatedAnnualCostSaved        DECIMAL(18,2)   NOT NULL,
    EstimatedAnnualCO2Saved         DECIMAL(18,2)   NOT NULL,

    RecommendationStatus            VARCHAR(30)     NOT NULL,
    ImplementationStatus            VARCHAR(30)     NOT NULL,

    ReviewRequiredFlag              BIT             NOT NULL,
    ApprovedFlag                    BIT             NOT NULL,

    SourceSystem                    VARCHAR(50)     NOT NULL,
    CreatedTimestamp                DATETIME2(6)    NOT NULL,
    UpdatedTimestamp                DATETIME2(6)    NULL
);
GO


/*==============================================================================
  6. FACT FUEL PURCHASE

  Grain:
  One fuel purchase-order or invoice line item for one vehicle.
==============================================================================*/

CREATE TABLE gold.FactFuelPurchase
(
    FuelPurchaseKey             BIGINT          NOT NULL,

    PurchaseOrderNumber         VARCHAR(50)     NOT NULL,
    PurchaseOrderLineNumber     INT             NOT NULL,
    InvoiceNumber               VARCHAR(50)     NULL,

    PurchaseDateKey             INT             NOT NULL,
    PurchaseTimestamp           DATETIME2(6)    NOT NULL,

    VehicleKey                  BIGINT          NOT NULL,
    SalesOrganizationKey        BIGINT          NOT NULL,

    VendorID                    VARCHAR(50)     NULL,
    VendorName                  VARCHAR(150)    NULL,

    FuelType                    VARCHAR(30)     NOT NULL,
    GallonsPurchased            DECIMAL(18,3)   NOT NULL,
    FuelUnitPrice               DECIMAL(18,4)   NOT NULL,
    FuelPurchaseCost            DECIMAL(18,2)   NOT NULL,
    OdometerReading             DECIMAL(18,2)   NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO


/*==============================================================================
  7. FACT VEHICLE TELEMETRY

  Grain:
  One vehicle telemetry event.
==============================================================================*/

CREATE TABLE gold.FactVehicleTelemetry
(
    VehicleTelemetryKey         BIGINT          NOT NULL,
    TelemetryEventID            VARCHAR(100)    NOT NULL,

    EventDateKey                INT             NOT NULL,
    EventTimestamp              DATETIME2(6)    NOT NULL,

    VehicleKey                  BIGINT          NOT NULL,
    DriverKey                   BIGINT          NULL,
    RouteKey                    BIGINT          NULL,
    SalesOrganizationKey        BIGINT          NOT NULL,

    Latitude                    DECIMAL(9,6)    NULL,
    Longitude                   DECIMAL(9,6)    NULL,

    OdometerReading             DECIMAL(18,2)   NULL,
    MilesDriven                 DECIMAL(18,2)   NULL,
    EngineHours                 DECIMAL(18,2)   NULL,
    IdleHours                   DECIMAL(18,2)   NULL,

    AverageSpeedMPH             DECIMAL(10,2)   NULL,
    MaximumSpeedMPH             DECIMAL(10,2)   NULL,

    HarshBrakingEvents          INT             NULL,
    HarshAccelerationEvents     INT             NULL,
    SpeedingEvents              INT             NULL,

    EngineOnFlag                BIT             NULL,
    VehicleMovingFlag           BIT             NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO


/*==============================================================================
  8. FACT ROAD EVENT

  Grain:
  One road event.

  Note:
  This is a portfolio enhancement inspired by prior road-intelligence work.
==============================================================================*/

CREATE TABLE gold.FactRoadEvent
(
    RoadEventKey                BIGINT          NOT NULL,
    RoadEventID                 VARCHAR(100)    NOT NULL,

    EventDateKey                INT             NOT NULL,
    RouteKey                    BIGINT          NULL,
    SalesOrganizationKey        BIGINT          NULL,

    EventStartTimestamp         DATETIME2(6)    NOT NULL,
    EventEndTimestamp           DATETIME2(6)    NULL,

    EventType                   VARCHAR(50)     NOT NULL,
    EventCategory               VARCHAR(50)     NULL,
    SeverityLevel               VARCHAR(30)     NULL,

    RoadSegmentID               VARCHAR(100)    NULL,
    RoadName                    VARCHAR(150)    NULL,

    Latitude                    DECIMAL(9,6)    NULL,
    Longitude                   DECIMAL(9,6)    NULL,

    EstimatedDelayMinutes       INT             NULL,
    ImpactRadiusMiles           DECIMAL(10,2)   NULL,

    ControlClassification       VARCHAR(30)     NULL,
    EventDescription            VARCHAR(500)    NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO


/*==============================================================================
  9. BRIDGE DELIVERY ROAD EVENT

  Grain:
  One delivery order x one matched road event.

  Purpose:
  Resolves the many-to-many relationship between delivery orders and road events.
==============================================================================*/

CREATE TABLE gold.BridgeDeliveryRoadEvent
(
    DeliveryRoadEventKey        BIGINT          NOT NULL,

    DeliveryOrderKey            BIGINT          NOT NULL,
    RoadEventKey                BIGINT          NOT NULL,

    MatchedDelayMinutes         INT             NULL,
    MatchConfidenceScore        DECIMAL(5,4)    NULL,
    PrimaryEventFlag            BIT             NOT NULL,

    MatchMethod                 VARCHAR(50)     NULL,
    MatchNotes                  VARCHAR(500)    NULL,

    CreatedTimestamp            DATETIME2(6)    NOT NULL
);
GO


/*==============================================================================
  10. POST-CREATION CHECK

  Confirms that the expected tables exist.
==============================================================================*/

SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables AS t
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
WHERE s.name = 'gold'
  AND t.name IN
  (
      'FactDeliveryOrder',
      'FactDriverHours',
      'FactCustomerMaterialVolume',
      'FactCustomerCostToServe',
      'FactFrequencyRecommendation',
      'FactFuelPurchase',
      'FactVehicleTelemetry',
      'FactRoadEvent',
      'BridgeDeliveryRoadEvent'
  )
ORDER BY t.name;
GO
