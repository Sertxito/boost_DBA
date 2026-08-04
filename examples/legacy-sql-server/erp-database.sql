-- ============================================================================
-- ERP Legacy Database Case Study
-- A realistic SQL Server database with the typical problems we're solving
-- ============================================================================

-- The Problem: 
-- This ERP system has been running since 2005, accumulating 15 years of
-- layers on top of layers. DBAs are afraid to touch it, developers don't
-- understand it, and nobody knows what will break if they change something.

-- ============================================================================
-- CORE TABLES (the critical ones)
-- ============================================================================

CREATE TABLE [dbo].[Companies] (
    CompanyID INT PRIMARY KEY IDENTITY(1,1),
    CompanyName NVARCHAR(100) NOT NULL,
    CompanyCode CHAR(5) NOT NULL UNIQUE,
    Created DATETIME DEFAULT GETDATE(),
    Modified DATETIME DEFAULT GETDATE(),
    Status CHAR(1) DEFAULT 'A'  -- A=Active, I=Inactive
);

CREATE TABLE [dbo].[Products] (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductCode NVARCHAR(50) NOT NULL UNIQUE,
    ProductName NVARCHAR(200) NOT NULL,
    CompanyID INT NOT NULL FOREIGN KEY REFERENCES Companies(CompanyID),
    Price DECIMAL(18,4) NOT NULL,
    CostPrice DECIMAL(18,4) NOT NULL,
    UnitOfMeasure CHAR(5) DEFAULT 'UNIT',
    StockLevel INT DEFAULT 0,
    ReorderLevel INT DEFAULT 100,
    WarehouseLocation NVARCHAR(50),
    LastReceived DATETIME,
    LastShipped DATETIME,
    Status CHAR(1) DEFAULT 'A'
);

CREATE TABLE [dbo].[Customers] (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerCode NVARCHAR(50) NOT NULL UNIQUE,
    CustomerName NVARCHAR(200) NOT NULL,
    CompanyID INT NOT NULL FOREIGN KEY REFERENCES Companies(CompanyID),
    BillingAddress NVARCHAR(500),
    ShippingAddress NVARCHAR(500),
    CreditLimit DECIMAL(18,2) DEFAULT 0,
    PriceListID INT,
    TaxID NVARCHAR(20),
    Status CHAR(1) DEFAULT 'A',
    Created DATETIME DEFAULT GETDATE(),
    LastModified DATETIME DEFAULT GETDATE()
);

CREATE TABLE [dbo].[Orders] (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    OrderNumber NVARCHAR(50) NOT NULL UNIQUE,
    OrderDate DATETIME NOT NULL,
    CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customers(CustomerID),
    CompanyID INT NOT NULL FOREIGN KEY REFERENCES Companies(CompanyID),
    OrderTotal DECIMAL(18,2) NOT NULL,
    OrderStatus NVARCHAR(20) DEFAULT 'OPEN',  -- OPEN, SHIPPED, CANCELLED, INVOICED
    ShippingDate DATETIME,
    InvoiceDate DATETIME,
    ShippingMethod CHAR(3),
    TrackingNumber NVARCHAR(100),
    Created DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(50),
    Modified DATETIME DEFAULT GETDATE(),
    ModifiedBy NVARCHAR(50),
    Notes NVARCHAR(1000),
    InternalNotes NVARCHAR(1000),
    ApprovedBy NVARCHAR(50),
    ApprovalDate DATETIME
);

CREATE TABLE [dbo].[OrderDetails] (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT NOT NULL FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,4) NOT NULL,
    LineDiscount DECIMAL(18,4) DEFAULT 0,
    LineTotal DECIMAL(18,2) NOT NULL,
    WarehouseCode NVARCHAR(20),
    SerialNumber NVARCHAR(100),
    ExpirationDate DATETIME,
    ShippedQuantity INT DEFAULT 0,
    ShippingStatus NVARCHAR(20) DEFAULT 'PENDING'
);

-- ============================================================================
-- THE LEGACY LAYER - Problem Area #1: Duplication
-- ============================================================================
-- Business rule implemented in multiple places creates inconsistency

CREATE TABLE [dbo].[OrderApprovals] (
    ApprovalID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
    ApprovalLevel INT,
    ApproverId NVARCHAR(50),
    ApprovalDate DATETIME,
    ApprovalStatus NVARCHAR(20),
    Comments NVARCHAR(500)
);

-- ============================================================================
-- THE REALLY LEGACY LAYER - Problem Area #2: Abandoned Patterns
-- ============================================================================
-- This table exists but nothing new is added to it - pure legacy

CREATE TABLE [dbo].[OrderArchive_2018] (
    ArchiveID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT NOT NULL,
    OrderData NVARCHAR(MAX),  -- Someone stored entire XML here instead of proper archive
    ArchiveDate DATETIME DEFAULT GETDATE()
);

-- ============================================================================
-- CRITICAL STORED PROCEDURES
-- ============================================================================

-- Procedure #1: The Monthly Closing - CRITICAL, runs at month-end
CREATE PROCEDURE [dbo].[sp_MonthlyClosing]
    @CompanyID INT,
    @ClosingMonth INT,
    @ClosingYear INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- This procedure is called from 3 different places and implemented differently
    -- each time. It's the foundation of financial reporting but fragile.
    
    DECLARE @ClosingDate DATETIME;
    SET @ClosingDate = CAST(CAST(@ClosingYear AS NVARCHAR(4)) + '-' + 
                            CAST(@ClosingMonth AS NVARCHAR(2)) + '-01' AS DATETIME);
    
    -- Lock down all orders for the closed month
    UPDATE [dbo].[Orders]
    SET OrderStatus = 'CLOSED'
    WHERE CompanyID = @CompanyID
      AND MONTH(OrderDate) = @ClosingMonth
      AND YEAR(OrderDate) = @ClosingYear
      AND OrderStatus IN ('INVOICED', 'SHIPPED');
    
    -- Archive old orders (more than 5 years)
    INSERT INTO [dbo].[OrderArchive_2018]
    SELECT OrderID, (SELECT * FROM Orders FOR XML RAW) 
    FROM Orders
    WHERE CompanyID = @CompanyID 
      AND DATEDIFF(YEAR, OrderDate, GETDATE()) > 5;
    
    -- Calculate monthly revenue
    DECLARE @MonthlyRevenue DECIMAL(18,2);
    SELECT @MonthlyRevenue = SUM(OrderTotal)
    FROM Orders
    WHERE CompanyID = @CompanyID
      AND MONTH(OrderDate) = @ClosingMonth
      AND YEAR(OrderDate) = @ClosingYear;
    
    -- Call dependent procedure (hidden dependency!)
    EXEC sp_UpdateCompanyMetrics @CompanyID, @MonthlyRevenue;
    
    -- Call another dependent procedure
    EXEC sp_SendMonthlyReports @CompanyID, @ClosingMonth, @ClosingYear;
    
    PRINT 'Month closed for Company ' + CAST(@CompanyID AS NVARCHAR(10));
END;
GO

-- Procedure #2: Calculate Order Total - Used by multiple places
-- Problem: No consistency, modified multiple times, nobody remembers why
CREATE PROCEDURE [dbo].[sp_CalculateOrderTotal]
    @OrderID INT,
    @RecalculateOnly BIT = 0  -- This parameter is never documented why it exists
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Total DECIMAL(18,2) = 0;
    
    -- Sum line totals
    SELECT @Total = SUM(LineTotal)
    FROM OrderDetails
    WHERE OrderID = @OrderID;
    
    -- Apply discount (but why only for some customers?)
    IF EXISTS (SELECT 1 FROM Orders o 
               JOIN Customers c ON o.CustomerID = c.CustomerID
               WHERE o.OrderID = @OrderID AND c.CreditLimit > 50000)
    BEGIN
        SET @Total = @Total * 0.95;  -- 5% discount for large customers
    END
    
    -- Apply tax (but calculation inconsistent across systems)
    SET @Total = @Total * 1.21;  -- Hardcoded 21% tax
    
    IF @RecalculateOnly = 0
    BEGIN
        UPDATE Orders SET OrderTotal = @Total WHERE OrderID = @OrderID;
    END
    
    SELECT @Total AS OrderTotal;
END;
GO

-- Procedure #3: Get Customer Orders
-- This procedure is called from reports that nobody maintains
CREATE PROCEDURE [dbo].[sp_GetCustomerOrders]
    @CustomerID INT,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StatusFilter NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL SET @StartDate = DATEADD(YEAR, -1, GETDATE());
    IF @EndDate IS NULL SET @EndDate = GETDATE();
    
    SELECT o.OrderID, o.OrderNumber, o.OrderDate, o.OrderTotal, o.OrderStatus,
           c.CustomerName, c.CompanyID,
           COUNT(od.OrderDetailID) AS LineCount,
           (SELECT COUNT(*) FROM OrderApprovals oa WHERE oa.OrderID = o.OrderID) AS ApprovalCount
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID
    LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
    LEFT JOIN OrderApprovals oa ON o.OrderID = oa.OrderID
    WHERE o.CustomerID = @CustomerID
      AND o.OrderDate BETWEEN @StartDate AND @EndDate
      AND (@StatusFilter IS NULL OR o.OrderStatus = @StatusFilter)
    GROUP BY o.OrderID, o.OrderNumber, o.OrderDate, o.OrderTotal, o.OrderStatus,
             c.CustomerName, c.CompanyID
    ORDER BY o.OrderDate DESC;
END;
GO

-- Procedure #4: Process shipment - Hidden complexity
CREATE PROCEDURE [dbo].[sp_ProcessShipment]
    @OrderID INT,
    @ShipmentDate DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ShipmentDate IS NULL SET @ShipmentDate = GETDATE();
    
    BEGIN TRANSACTION;
    
    -- Update order status
    UPDATE Orders SET OrderStatus = 'SHIPPED', ShippingDate = @ShipmentDate
    WHERE OrderID = @OrderID;
    
    -- Update shipment status for line items
    UPDATE OrderDetails SET ShippingStatus = 'SHIPPED', ShippedQuantity = Quantity
    WHERE OrderID = @OrderID;
    
    -- Decrement stock levels
    UPDATE p SET StockLevel = StockLevel - od.Quantity
    FROM Products p
    INNER JOIN OrderDetails od ON p.ProductID = od.ProductID
    WHERE od.OrderID = @OrderID;
    
    -- Call external system (but what if it fails?)
    EXEC sp_SendShippingNotification @OrderID;
    
    -- Update customer metrics (undocumented dependency)
    EXEC sp_UpdateCustomerOrderMetrics @OrderID;
    
    COMMIT TRANSACTION;
END;
GO

-- ============================================================================
-- THE PROBLEMATIC PROCEDURES
-- ============================================================================

-- This procedure has zero documentation, runs nightly, and if it fails nobody knows
CREATE PROCEDURE [dbo].[sp_NightlyReconciliation]
AS
BEGIN
    -- The actual logic is lost to history
    -- Someone commented it out because it was causing issues, but left it in the code
    
    /*
    -- This was supposed to reconcile something but we don't know what
    UPDATE Orders 
    SET OrderStatus = 'RECONCILED' 
    WHERE OrderDate < DATEADD(DAY, -30, GETDATE());
    */
    
    -- So now it does nothing but still runs every night taking up resources
    RETURN 0;
END;
GO

-- Procedure that nobody knows if it's used
CREATE PROCEDURE [dbo].[sp_LegacyReportExtract]
    @ReportType NVARCHAR(50),
    @OutputPath NVARCHAR(500)
AS
BEGIN
    -- This used to export to files that were consumed by legacy system
    -- That system was retired 3 years ago
    -- But this procedure is still here because we're not sure what depends on it
    
    DECLARE @SQL NVARCHAR(MAX);
    
    IF @ReportType = 'DAILY_SALES'
    BEGIN
        -- Complex query nobody maintains
        SELECT * FROM Orders WHERE OrderDate = CAST(GETDATE() AS DATE);
    END
    
    -- The rest is similar undocumented code
END;
GO

-- ============================================================================
-- INDEXES - Some optimized, some forgotten
-- ============================================================================

-- Good indexes
CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID] ON [Orders](CustomerID) INCLUDE (OrderStatus, OrderDate);
CREATE NONCLUSTERED INDEX [IX_Orders_OrderStatus] ON [Orders](OrderStatus) INCLUDE (OrderDate, OrderTotal);
CREATE NONCLUSTERED INDEX [IX_Products_CompanyID] ON [Products](CompanyID) INCLUDE (StockLevel, Price);

-- Forgotten indexes (these would help but nobody knows they should exist)
-- CREATE NONCLUSTERED INDEX [IX_OrderDetails_ProductID] ON [OrderDetails](ProductID);
-- CREATE NONCLUSTERED INDEX [IX_Customers_CompanyID] ON [Customers](CompanyID);

-- ============================================================================
-- VIEWS - Some useful, some dangerous
-- ============================================================================

-- Useful view that's documented
CREATE VIEW [dbo].[v_OpenOrders] AS
SELECT o.OrderID, o.OrderNumber, o.OrderDate, c.CustomerName, o.OrderTotal
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE o.OrderStatus IN ('OPEN', 'PENDING');
GO

-- Dangerous view - people query it not knowing it's expensive
CREATE VIEW [dbo].[v_CustomerCreditStatus] AS
SELECT c.CustomerID, c.CustomerName, c.CreditLimit,
       SUM(CASE WHEN o.OrderStatus IN ('OPEN', 'SHIPPED') THEN o.OrderTotal ELSE 0 END) AS OutstandingBalance,
       c.CreditLimit - SUM(CASE WHEN o.OrderStatus IN ('OPEN', 'SHIPPED') THEN o.OrderTotal ELSE 0 END) AS AvailableCredit
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.CreditLimit;
GO

-- ============================================================================
-- ANALYSIS STARTING POINTS
-- ============================================================================
-- These queries can be used to analyze the database using the skills

-- Find dependencies
SELECT DISTINCT OBJECT_NAME(referencing_id) AS DependentObject,
                OBJECT_NAME(referenced_id) AS ReferencedObject
FROM sys.sql_expression_dependencies
WHERE database_id = DB_ID()
ORDER BY OBJECT_NAME(referencing_id);

-- Find potentially unused procedures
SELECT name FROM sys.procedures 
WHERE name LIKE 'sp_%' 
  AND OBJECTPROPERTY(object_id, 'ExecIsStartup') = 0
  AND name NOT IN ('sp_MonthlyClosing', 'sp_ProcessShipment', 'sp_GetCustomerOrders');

-- Find complex procedures (multiple nested calls)
SELECT OBJECT_NAME(object_id) AS ProcedureName,
       LEN(OBJECT_DEFINITION(object_id)) AS CodeLength,
       (SELECT COUNT(DISTINCT referenced_id) 
        FROM sys.sql_expression_dependencies 
        WHERE referencing_id = p.object_id) AS DependencyCount
FROM sys.procedures p
WHERE name LIKE 'sp_%'
ORDER BY CodeLength DESC;

