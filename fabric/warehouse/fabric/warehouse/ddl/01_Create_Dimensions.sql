/*
===============================================================================
Project: Delivery Standardization & Cost Optimization Platform
File: 01_Create_Dimensions.sql
Platform: Microsoft Fabric Warehouse
Purpose: Create Gold-layer dimension tables
===============================================================================

Important:
- Execute this script in a Microsoft Fabric Warehouse.
- Keys are metadata constraints and are NOT ENFORCED by Fabric Warehouse.
- Surrogate keys will be populated by the Gold-layer loading process.
===============================================================================
*/


/*==============================================================================
  1. CREATE GOLD SCHEMA
==============================================================================*/

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'gold'
)
BEGIN
    EXEC('CREATE SCHEMA gold');
END;
GO


/*==============================================================================
  2. DIM DATE
  Grain: One row per calendar date
==============================================================================*/

CREATE TABLE gold.DimDate
(
    DateKey                 INT             NOT NULL,
    FullDate                DATE            NOT NULL,
    DayOfMonth              SMALLINT        NOT NULL,
    DayName                 VARCHAR(10)     NOT NULL,
    DayOfWeekNumber         SMALLINT        NOT NULL,
    DayOfYear               SMALLINT        NOT NULL,
    WeekOfYear              SMALLINT        NOT NULL,
    MonthNumber             SMALLINT        NOT NULL,
    MonthName               VARCHAR(10)     NOT NULL,
    MonthShortName          VARCHAR(3)      NOT NULL,
    QuarterNumber           SMALLINT        NOT NULL,
    QuarterName             VARCHAR(2)      NOT NULL,
    CalendarYear            SMALLINT        NOT NULL,
    YearMonthNumber         INT             NOT NULL,
    YearMonthLabel          VARCHAR(7)      NOT NULL,
    IsWeekday               BIT             NOT NULL,
    IsWeekend               BIT             NOT NULL,
    IsMonthEnd              BIT             NOT NULL,
    IsQuarterEnd            BIT             NOT NULL,
    IsYearEnd               BIT             NOT NULL
);
GO

ALTER TABLE gold.DimDate
ADD CONSTRAINT PK_DimDate
PRIMARY KEY NONCLUSTERED (DateKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimDate
ADD CONSTRAINT UQ_DimDate_FullDate
UNIQUE NONCLUSTERED (FullDate) NOT ENFORCED;
GO


/*==============================================================================
  3. DIM SALES ORGANIZATION
  Grain: One sales-organization hierarchy assignment
==============================================================================*/

CREATE TABLE gold.DimSalesOrganization
(
    SalesOrganizationKey        BIGINT          NOT NULL,
    SalesOrganizationID         VARCHAR(50)     NOT NULL,

    RegionID                    VARCHAR(30)     NULL,
    RegionName                  VARCHAR(100)    NOT NULL,

    MarketUnitID                VARCHAR(30)     NULL,
    MarketUnitName              VARCHAR(100)    NOT NULL,

    DistributionCenterID        VARCHAR(30)     NOT NULL,
    DistributionCenterName      VARCHAR(150)    NOT NULL,

    SalesTerritoryID            VARCHAR(30)     NOT NULL,
    SalesTerritoryName          VARCHAR(150)    NOT NULL,

    DistributionCenterLatitude  DECIMAL(9,6)    NULL,
    DistributionCenterLongitude DECIMAL(9,6)    NULL,

    EffectiveStartDate          DATE            NOT NULL,
    EffectiveEndDate            DATE            NULL,
    IsCurrent                   BIT             NOT NULL,
    ActiveFlag                  BIT             NOT NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimSalesOrganization
ADD CONSTRAINT PK_DimSalesOrganization
PRIMARY KEY NONCLUSTERED (SalesOrganizationKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimSalesOrganization
ADD CONSTRAINT UQ_DimSalesOrganization_ID
UNIQUE NONCLUSTERED
(
    SalesOrganizationID,
    EffectiveStartDate
) NOT ENFORCED;
GO


/*==============================================================================
  4. DIM CUSTOMER
  Grain: One customer master-data version
==============================================================================*/

CREATE TABLE gold.DimCustomer
(
    CustomerKey               BIGINT          NOT NULL,
    CustomerID                VARCHAR(50)     NOT NULL,
    CustomerName              VARCHAR(200)    NOT NULL,

    CustomerCategory          VARCHAR(100)    NOT NULL,
    CustomerSegment           VARCHAR(100)    NULL,
    CustomerType              VARCHAR(100)    NULL,

    SalesOrganizationKey      BIGINT          NOT NULL,

    AreaSalesManagerID        VARCHAR(50)     NULL,
    AreaSalesManagerName      VARCHAR(150)    NULL,

    MarketDevelopmentManagerID
                              VARCHAR(50)     NULL,
    MarketDevelopmentManagerName
                              VARCHAR(150)    NULL,

    CurrentWeeklyFrequency    SMALLINT        NULL,
    PlannedDeliveryDays       VARCHAR(50)     NULL,

    CustomerLatitude          DECIMAL(9,6)    NULL,
    CustomerLongitude         DECIMAL(9,6)    NULL,

    CustomerStatus            VARCHAR(30)     NOT NULL,
    EffectiveStartDate        DATE            NOT NULL,
    EffectiveEndDate          DATE            NULL,
    IsCurrent                 BIT             NOT NULL,
    ActiveFlag                BIT             NOT NULL,

    SourceSystem              VARCHAR(50)     NOT NULL,
    CreatedTimestamp          DATETIME2(6)    NOT NULL,
    UpdatedTimestamp          DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimCustomer
ADD CONSTRAINT PK_DimCustomer
PRIMARY KEY NONCLUSTERED (CustomerKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimCustomer
ADD CONSTRAINT UQ_DimCustomer_ID
UNIQUE NONCLUSTERED
(
    CustomerID,
    EffectiveStartDate
) NOT ENFORCED;
GO

ALTER TABLE gold.DimCustomer
ADD CONSTRAINT FK_DimCustomer_DimSalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
GO


/*==============================================================================
  5. DIM MATERIAL
  Grain: One material master-data version
==============================================================================*/

CREATE TABLE gold.DimMaterial
(
    MaterialKey              BIGINT          NOT NULL,
    MaterialID               VARCHAR(50)     NOT NULL,
    MaterialName             VARCHAR(200)    NOT NULL,

    BrandID                  VARCHAR(50)     NULL,
    BrandName                VARCHAR(100)    NULL,

    ProductCategory          VARCHAR(100)    NOT NULL,
    ProductSubcategory       VARCHAR(100)    NULL,

    PackageType              VARCHAR(50)     NULL,
    PackageSize              VARCHAR(50)     NULL,
    PackageConfiguration     VARCHAR(100)    NULL,

    UnitOfMeasure            VARCHAR(30)     NOT NULL,
    UnitsPerCase             DECIMAL(12,3)   NULL,

    EffectiveStartDate       DATE            NOT NULL,
    EffectiveEndDate         DATE            NULL,
    IsCurrent                BIT             NOT NULL,
    ActiveFlag               BIT             NOT NULL,

    SourceSystem             VARCHAR(50)     NOT NULL,
    CreatedTimestamp         DATETIME2(6)    NOT NULL,
    UpdatedTimestamp         DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimMaterial
ADD CONSTRAINT PK_DimMaterial
PRIMARY KEY NONCLUSTERED (MaterialKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimMaterial
ADD CONSTRAINT UQ_DimMaterial_ID
UNIQUE NONCLUSTERED
(
    MaterialID,
    EffectiveStartDate
) NOT ENFORCED;
GO


/*==============================================================================
  6. DIM DRIVER
  Grain: One driver master-data version
==============================================================================*/

CREATE TABLE gold.DimDriver
(
    DriverKey                   BIGINT          NOT NULL,
    DriverID                    VARCHAR(50)     NOT NULL,
    DriverName                  VARCHAR(150)    NOT NULL,

    HomeSalesOrganizationKey    BIGINT          NOT NULL,

    EmploymentType              VARCHAR(50)     NULL,
    ScheduledDailyHours         DECIMAL(6,2)    NULL,
    RegularHourlyRate           DECIMAL(12,2)   NULL,
    OvertimeHourlyRate          DECIMAL(12,2)   NULL,

    HireDate                    DATE            NULL,
    LicenseClass                VARCHAR(30)     NULL,

    EffectiveStartDate          DATE            NOT NULL,
    EffectiveEndDate            DATE            NULL,
    IsCurrent                   BIT             NOT NULL,
    ActiveFlag                  BIT             NOT NULL,

    SourceSystem                VARCHAR(50)     NOT NULL,
    CreatedTimestamp            DATETIME2(6)    NOT NULL,
    UpdatedTimestamp            DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimDriver
ADD CONSTRAINT PK_DimDriver
PRIMARY KEY NONCLUSTERED (DriverKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimDriver
ADD CONSTRAINT UQ_DimDriver_ID
UNIQUE NONCLUSTERED
(
    DriverID,
    EffectiveStartDate
) NOT ENFORCED;
GO

ALTER TABLE gold.DimDriver
ADD CONSTRAINT FK_DimDriver_DimSalesOrganization
FOREIGN KEY (HomeSalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
GO


/*==============================================================================
  7. DIM ROUTE
  Grain: One route master-data version
==============================================================================*/

CREATE TABLE gold.DimRoute
(
    RouteKey                  BIGINT          NOT NULL,
    RouteID                   VARCHAR(50)     NOT NULL,
    RouteName                 VARCHAR(150)    NOT NULL,

    SalesOrganizationKey      BIGINT          NOT NULL,

    RouteType                 VARCHAR(50)     NULL,
    Urbanicity                VARCHAR(30)     NULL,

    PlannedDistanceMiles      DECIMAL(12,2)   NULL,
    PlannedStops              INT             NULL,
    PlannedDurationHours      DECIMAL(8,2)    NULL,

    RouteStartLatitude        DECIMAL(9,6)    NULL,
    RouteStartLongitude       DECIMAL(9,6)    NULL,

    EffectiveStartDate        DATE            NOT NULL,
    EffectiveEndDate          DATE            NULL,
    IsCurrent                 BIT             NOT NULL,
    ActiveFlag                BIT             NOT NULL,

    SourceSystem              VARCHAR(50)     NOT NULL,
    CreatedTimestamp          DATETIME2(6)    NOT NULL,
    UpdatedTimestamp          DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimRoute
ADD CONSTRAINT PK_DimRoute
PRIMARY KEY NONCLUSTERED (RouteKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimRoute
ADD CONSTRAINT UQ_DimRoute_ID
UNIQUE NONCLUSTERED
(
    RouteID,
    EffectiveStartDate
) NOT ENFORCED;
GO

ALTER TABLE gold.DimRoute
ADD CONSTRAINT FK_DimRoute_DimSalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
GO


/*==============================================================================
  8. DIM VEHICLE
  Grain: One vehicle master-data version
==============================================================================*/

CREATE TABLE gold.DimVehicle
(
    VehicleKey                BIGINT          NOT NULL,
    VehicleID                 VARCHAR(50)     NOT NULL,
    TruckNumber               VARCHAR(50)     NOT NULL,

    SalesOrganizationKey      BIGINT          NOT NULL,

    VehicleType               VARCHAR(50)     NOT NULL,
    VehicleClass              VARCHAR(50)     NULL,

    Manufacturer              VARCHAR(100)    NULL,
    ModelName                 VARCHAR(100)    NULL,
    ModelYear                 SMALLINT        NULL,

    CapacityCases             INT             NULL,
    FuelType                  VARCHAR(30)     NOT NULL,
    ExpectedMPG               DECIMAL(8,2)    NULL,

    TelematicsDeviceID        VARCHAR(100)    NULL,
    InServiceDate             DATE            NULL,
    OutOfServiceDate          DATE            NULL,

    EffectiveStartDate        DATE            NOT NULL,
    EffectiveEndDate          DATE            NULL,
    IsCurrent                 BIT             NOT NULL,
    ActiveFlag                BIT             NOT NULL,

    SourceSystem              VARCHAR(50)     NOT NULL,
    CreatedTimestamp          DATETIME2(6)    NOT NULL,
    UpdatedTimestamp          DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimVehicle
ADD CONSTRAINT PK_DimVehicle
PRIMARY KEY NONCLUSTERED (VehicleKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimVehicle
ADD CONSTRAINT UQ_DimVehicle_ID
UNIQUE NONCLUSTERED
(
    VehicleID,
    EffectiveStartDate
) NOT ENFORCED;
GO

ALTER TABLE gold.DimVehicle
ADD CONSTRAINT FK_DimVehicle_DimSalesOrganization
FOREIGN KEY (SalesOrganizationKey)
REFERENCES gold.DimSalesOrganization (SalesOrganizationKey)
NOT ENFORCED;
GO


/*==============================================================================
  9. DIM MISSED REASON
  Grain: One missed-delivery reason
==============================================================================*/

CREATE TABLE gold.DimMissedReason
(
    MissedReasonKey          BIGINT          NOT NULL,
    MissedReasonCode         VARCHAR(30)     NOT NULL,
    MissedReasonName         VARCHAR(100)    NOT NULL,

    ReasonCategory           VARCHAR(100)    NOT NULL,
    ControlClassification    VARCHAR(30)     NOT NULL,
    ResponsibleArea          VARCHAR(100)    NULL,

    ReasonDescription        VARCHAR(500)    NULL,

    ActiveFlag               BIT             NOT NULL,
    SourceSystem             VARCHAR(50)     NOT NULL,
    CreatedTimestamp         DATETIME2(6)    NOT NULL,
    UpdatedTimestamp         DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimMissedReason
ADD CONSTRAINT PK_DimMissedReason
PRIMARY KEY NONCLUSTERED (MissedReasonKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimMissedReason
ADD CONSTRAINT UQ_DimMissedReason_Code
UNIQUE NONCLUSTERED (MissedReasonCode) NOT ENFORCED;
GO


/*==============================================================================
  10. DIM FREQUENCY MATRIX
  Grain: One customer-category and four-week-volume recommendation rule
==============================================================================*/

CREATE TABLE gold.DimFrequencyMatrix
(
    FrequencyRuleKey             BIGINT          NOT NULL,
    FrequencyRuleID              VARCHAR(50)     NOT NULL,

    CustomerCategory             VARCHAR(100)    NOT NULL,

    MinimumRolling4WeekCases     DECIMAL(18,2)   NOT NULL,
    MaximumRolling4WeekCases     DECIMAL(18,2)   NULL,

    RecommendedWeeklyFrequency   SMALLINT        NOT NULL,

    RuleDescription              VARCHAR(500)    NULL,
    RulePriority                 INT             NULL,

    EffectiveStartDate           DATE            NOT NULL,
    EffectiveEndDate             DATE            NULL,
    IsCurrent                    BIT             NOT NULL,
    ActiveFlag                   BIT             NOT NULL,

    SourceSystem                 VARCHAR(50)     NOT NULL,
    CreatedTimestamp             DATETIME2(6)    NOT NULL,
    UpdatedTimestamp             DATETIME2(6)    NULL
);
GO

ALTER TABLE gold.DimFrequencyMatrix
ADD CONSTRAINT PK_DimFrequencyMatrix
PRIMARY KEY NONCLUSTERED (FrequencyRuleKey) NOT ENFORCED;
GO

ALTER TABLE gold.DimFrequencyMatrix
ADD CONSTRAINT UQ_DimFrequencyMatrix_Rule
UNIQUE NONCLUSTERED
(
    FrequencyRuleID,
    EffectiveStartDate
) NOT ENFORCED;
GO


/*==============================================================================
  11. POST-CREATION VALIDATION
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
      'DimDate',
      'DimSalesOrganization',
      'DimCustomer',
      'DimMaterial',
      'DimDriver',
      'DimRoute',
      'DimVehicle',
      'DimMissedReason',
      'DimFrequencyMatrix'
  )
ORDER BY t.name;
GO
