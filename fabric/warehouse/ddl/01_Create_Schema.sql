/*
===============================================================================
Project: Delivery Standardization & Cost Optimization Platform
File: 01_Create_Schema.sql
Platform: Microsoft Fabric Warehouse
Purpose: Create the Gold schema
===============================================================================
*/

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
