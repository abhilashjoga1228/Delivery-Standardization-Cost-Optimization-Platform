/*
===============================================================================
Project: Delivery Standardization & Cost Optimization Platform
File: 02_Create_Facts.sql
Platform: Microsoft Fabric Warehouse
Purpose: Create Gold-layer fact and bridge tables
===============================================================================

Prerequisite:
- Execute 01_Create_Dimensions.sql first.
- The gold schema and all dimension tables must already exist.

Important:
- Primary and foreign keys are metadata constraints.
- Fabric Warehouse does not enforce these relationships.
- Duplicate and orphan-key validation will be implemented separately.
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
    OTIF_Flag                   BIT             NOT NULL,
    SLAFlag                     BIT             NOT NULL,
    MissedDeliveryFlag          BIT             NOT NULL,

    DeliveryStatus              VARCHAR(30)     NOT NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT PK_FactDeliveryOrder
PRIMARY KEY NONCLUSTERED (DeliveryOrderKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT UQ_FactDeliveryOrder_ID
UNIQUE NONCLUSTERED (DeliveryOrderID) NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_OrderDate
FOREIGN KEY (OrderDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_PlannedDeliveryDate
FOREIGN KEY (PlannedDeliveryDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_ActualDeliveryDate
FOREIGN KEY (ActualDeliveryDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_Customer
FOREIGN KEY (CustomerKey)
REFERENCES gold.DimCustomer (CustomerKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_Driver
FOREIGN KEY (DriverKey)
REFERENCES gold.DimDriver (DriverKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_Route
FOREIGN KEY (RouteKey)
REFERENCES gold.DimRoute (RouteKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_Vehicle
FOREIGN KEY (VehicleKey)
REFERENCES gold.DimVehicle (VehicleKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDeliveryOrder
ADD CONSTRAINT FK_FactDeliveryOrder_MissedReason
FOREIGN KEY (MissedReasonKey)
REFERENCES gold.DimMissedReason (MissedReasonKey)
NOT ENFORCED;
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

ALTER TABLE gold.FactDriverHours
ADD CONSTRAINT PK_FactDriverHours
PRIMARY KEY NONCLUSTERED (DriverHoursKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactDriverHours
ADD CONSTRAINT UQ_FactDriverHours_Grain
UNIQUE NONCLUSTERED
(
    WorkDateKey,
    DriverKey,
    RouteKey,
    VehicleKey
) NOT ENFORCED;
GO

ALTER TABLE gold.FactDriverHours
ADD CONSTRAINT FK_FactDriverHours_Date
FOREIGN KEY (WorkDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDriverHours
ADD CONSTRAINT FK_FactDriverHours_Driver
FOREIGN KEY (DriverKey)
REFERENCES gold.DimDriver (DriverKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDriverHours
ADD CONSTRAINT FK_FactDriverHours_Route
FOREIGN KEY (RouteKey)
REFERENCES gold.DimRoute (RouteKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDriverHours
ADD CONSTRAINT FK_FactDriverHours_Vehicle
FOREIGN KEY (VehicleKey)
REFERENCES gold.DimVehicle (VehicleKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactDriverHours
ADD CONSTRAINT FK_FactDriverHours_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
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

ALTER TABLE gold.FactCustomerMaterialVolume
ADD CONSTRAINT PK_FactCustomerMaterialVolume
PRIMARY KEY NONCLUSTERED
(CustomerMaterialVolumeKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerMaterialVolume
ADD CONSTRAINT UQ_FactCustomerMaterialVolume_Transaction
UNIQUE NONCLUSTERED
(
    SalesTransactionID,
    SalesTransactionLineNumber
) NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerMaterialVolume
ADD CONSTRAINT FK_FactCustomerMaterialVolume_Date
FOREIGN KEY (PurchaseDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerMaterialVolume
ADD CONSTRAINT FK_FactCustomerMaterialVolume_Customer
FOREIGN KEY (CustomerKey)
REFERENCES gold.DimCustomer (CustomerKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerMaterialVolume
ADD CONSTRAINT FK_FactCustomerMaterialVolume_Material
FOREIGN KEY (MaterialKey)
REFERENCES gold.DimMaterial (MaterialKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerMaterialVolume
ADD CONSTRAINT FK_FactCustomerMaterialVolume_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
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

ALTER TABLE gold.FactCustomerCostToServe
ADD CONSTRAINT PK_FactCustomerCostToServe
PRIMARY KEY NONCLUSTERED
(CustomerCostToServeKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerCostToServe
ADD CONSTRAINT UQ_FactCustomerCostToServe_Grain
UNIQUE NONCLUSTERED
(
    ActivityDateKey,
    CustomerKey
) NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerCostToServe
ADD CONSTRAINT FK_FactCustomerCostToServe_Date
FOREIGN KEY (ActivityDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerCostToServe
ADD CONSTRAINT FK_FactCustomerCostToServe_Customer
FOREIGN KEY (CustomerKey)
REFERENCES gold.DimCustomer (CustomerKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactCustomerCostToServe
ADD CONSTRAINT FK_FactCustomerCostToServe_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
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
    ImplementationDateKey           INT             NULL,

    ReviewRequiredFlag              BIT             NOT NULL,
    ApprovedFlag                    BIT             NOT NULL,

    SourceSystem                    VARCHAR(50)     NOT NULL,
    CreatedTimestamp                DATETIME2(6)    NOT NULL,
    UpdatedTimestamp                DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT PK_FactFrequencyRecommendation
PRIMARY KEY NONCLUSTERED
(FrequencyRecommendationKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT UQ_FactFrequencyRecommendation_ID
UNIQUE NONCLUSTERED (RecommendationID) NOT ENFORCED;
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT UQ_FactFrequencyRecommendation_Grain
UNIQUE NONCLUSTERED
(
    RecommendationDateKey,
    CustomerKey
) NOT ENFORCED;
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT FK_FactFrequencyRecommendation_Date
FOREIGN KEY (RecommendationDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT FK_FactFrequencyRecommendation_ImplementationDate
FOREIGN KEY (ImplementationDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT FK_FactFrequencyRecommendation_Customer
FOREIGN KEY (CustomerKey)
REFERENCES gold.DimCustomer (CustomerKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT FK_FactFrequencyRecommendation_FrequencyRule
FOREIGN KEY (FrequencyRuleKey)
REFERENCES gold.DimFrequencyMatrix (FrequencyRuleKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactFrequencyRecommendation
ADD CONSTRAINT FK_FactFrequencyRecommendation_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
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

ALTER TABLE gold.FactFuelPurchase
ADD CONSTRAINT PK_FactFuelPurchase
PRIMARY KEY NONCLUSTERED (FuelPurchaseKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactFuelPurchase
ADD CONSTRAINT UQ_FactFuelPurchase_Line
UNIQUE NONCLUSTERED
(
    PurchaseOrderNumber,
    PurchaseOrderLineNumber
) NOT ENFORCED;
GO

ALTER TABLE gold.FactFuelPurchase
ADD CONSTRAINT FK_FactFuelPurchase_Date
FOREIGN KEY (PurchaseDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactFuelPurchase
ADD CONSTRAINT FK_FactFuelPurchase_Vehicle
FOREIGN KEY (VehicleKey)
REFERENCES gold.DimVehicle (VehicleKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactFuelPurchase
ADD CONSTRAINT FK_FactFuelPurchase_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
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

ALTER TABLE gold.FactVehicleTelemetry
ADD CONSTRAINT PK_FactVehicleTelemetry
PRIMARY KEY NONCLUSTERED
(VehicleTelemetryKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactVehicleTelemetry
ADD CONSTRAINT UQ_FactVehicleTelemetry_Event
UNIQUE NONCLUSTERED
(TelemetryEventID) NOT ENFORCED;
GO

ALTER TABLE gold.FactVehicleTelemetry
ADD CONSTRAINT FK_FactVehicleTelemetry_Date
FOREIGN KEY (EventDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactVehicleTelemetry
ADD CONSTRAINT FK_FactVehicleTelemetry_Vehicle
FOREIGN KEY (VehicleKey)
REFERENCES gold.DimVehicle (VehicleKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactVehicleTelemetry
ADD CONSTRAINT FK_FactVehicleTelemetry_Driver
FOREIGN KEY (DriverKey)
REFERENCES gold.DimDriver (DriverKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactVehicleTelemetry
ADD CONSTRAINT FK_FactVehicleTelemetry_Route
FOREIGN KEY (RouteKey)
REFERENCES gold.DimRoute (RouteKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactVehicleTelemetry
ADD CONSTRAINT FK_FactVehicleTelemetry_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
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

ALTER TABLE gold.FactRoadEvent
ADD CONSTRAINT PK_FactRoadEvent
PRIMARY KEY NONCLUSTERED (RoadEventKey) NOT ENFORCED;
GO

ALTER TABLE gold.FactRoadEvent
ADD CONSTRAINT UQ_FactRoadEvent_ID
UNIQUE NONCLUSTERED (RoadEventID) NOT ENFORCED;
GO

ALTER TABLE gold.FactRoadEvent
ADD CONSTRAINT FK_FactRoadEvent_Date
FOREIGN KEY (EventDateKey)
REFERENCES gold.DimDate (DateKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactRoadEvent
ADD CONSTRAINT FK_FactRoadEvent_Route
FOREIGN KEY (RouteKey)
REFERENCES gold.DimRoute (RouteKey)
NOT ENFORCED;
GO

ALTER TABLE gold.FactRoadEvent
ADD CONSTRAINT FK_FactRoadEvent_SalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
GO


/*==============================================================================
  9. BRIDGE DELIVERY ROAD EVENT

  Grain:
  One delivery order x one matched road event.

  Purpose:
  Supports valid many-to-many matching between deliveries and road events.
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

ALTER TABLE gold.BridgeDeliveryRoadEvent
ADD CONSTRAINT PK_BridgeDeliveryRoadEvent
PRIMARY KEY NONCLUSTERED
(DeliveryRoadEventKey) NOT ENFORCED;
GO

ALTER TABLE gold.BridgeDeliveryRoadEvent
ADD CONSTRAINT UQ_BridgeDeliveryRoadEvent_Match
UNIQUE NONCLUSTERED
(
    DeliveryOrderKey,
    RoadEventKey
) NOT ENFORCED;
GO

ALTER TABLE gold.BridgeDeliveryRoadEvent
ADD CONSTRAINT FK_BridgeDeliveryRoadEvent_Delivery
FOREIGN KEY (DeliveryOrderKey)
REFERENCES gold.FactDeliveryOrder (DeliveryOrderKey)
NOT ENFORCED;
GO

ALTER TABLE gold.BridgeDeliveryRoadEvent
ADD CONSTRAINT FK_BridgeDeliveryRoadEvent_RoadEvent
FOREIGN KEY (RoadEventKey)
REFERENCES gold.FactRoadEvent (RoadEventKey)
NOT ENFORCED;
GO


/*==============================================================================
  10. POST-CREATION VALIDATION

  Confirms that all fact and bridge tables were created.
==============================================================================*/

SELECT
    SchemaName = s.name,
    TableName  = t.name
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
