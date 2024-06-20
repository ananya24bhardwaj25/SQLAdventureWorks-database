1.
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(4, 2) = 0
AS
BEGIN
    DECLARE @ActualUnitPrice DECIMAL(10, 2);
    DECLARE @StockQuantity INT;
    DECLARE @ReorderLevel INT;
    DECLARE @ErrorMessage NVARCHAR(250);

    IF @UnitPrice IS NULL
    BEGIN
        SELECT @ActualUnitPrice = ListPrice
        FROM Production.Product
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        SET @ActualUnitPrice = @UnitPrice;
    END
    SELECT @StockQuantity = p.Quantity,@ReorderLevel = p.ReorderLevel
    FROM Production.ProductInventory AS p
    WHERE p.ProductID = @ProductID;

    IF @StockQuantity < @Quantity
    BEGIN
        SET @ErrorMessage = 'Failed to place the order. Not enough stock available.';
        RAISERROR (@ErrorMessage, 16, 1);
        RETURN;
    END

    INSERT INTO Sales.OrderDetail (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @ActualUnitPrice, @Quantity, @Discount);

    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID;

    
    IF @StockQuantity - @Quantity < @ReorderLevel
    BEGIN
        PRINT 'Warning: The quantity in stock for the product has dropped below the reorder level.';
    END
END;
GO


2.
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(4, 2) = NULL
AS
BEGIN

    DECLARE @CurrentUnitPrice DECIMAL(10, 2);
    DECLARE @CurrentQuantity INT;
    DECLARE @CurrentDiscount DECIMAL(4, 2);
    DECLARE @OldQuantity INT;
    DECLARE @StockQuantity INT;
    DECLARE @NewStockQuantity INT;

    SELECT @CurrentUnitPrice = UnitPrice,
           @CurrentQuantity = Quantity,
           @CurrentDiscount = Discount
    FROM Sales.OrderDetail
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    SET @UnitPrice = ISNULL(@UnitPrice, @CurrentUnitPrice);
    SET @Quantity = ISNULL(@Quantity, @CurrentQuantity);
    SET @Discount = ISNULL(@Discount, @CurrentDiscount);

    SELECT @StockQuantity = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;


    SET @OldQuantity = @CurrentQuantity;
    SET @NewStockQuantity = @StockQuantity + @OldQuantity - @Quantity;

    IF @NewStockQuantity < 0
    BEGIN
        RAISERROR ('Failed to update the order. Not enough stock available.', 16, 1);
        RETURN;
    END
    UPDATE Sales.OrderDetail
    SET UnitPrice = @UnitPrice,
        Quantity = @Quantity,
        Discount = @Discount
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    UPDATE Production.ProductInventory
    SET Quantity = @NewStockQuantity
    WHERE ProductID = @ProductID;

    
    DECLARE @ReorderLevel INT;
    SELECT @ReorderLevel = ReorderLevel
    FROM Production.Product
    WHERE ProductID = @ProductID;

    IF @NewStockQuantity < @ReorderLevel
    BEGIN
        PRINT 'Warning: The quantity in stock for the product has dropped below the reorder level.';
    END

    PRINT 'Order updated successfully.';
END;

3.
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Sales.OrderDetail WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS NVARCHAR(10)) + ' does not exist';
        RETURN 1;
    END

    SELECT OrderID, ProductID, UnitPrice, Quantity, Discount
    FROM Sales.OrderDetail
    WHERE OrderID = @OrderID;
END;

4.
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(250);
    IF NOT EXISTS (SELECT 1 FROM Sales.OrderDetail WHERE OrderID = @OrderID)
    BEGIN
        SET @ErrorMessage = 'Error: The OrderID ' + CAST(@OrderID AS NVARCHAR(10)) + ' does not exist.';
        PRINT @ErrorMessage;
        RETURN -1;
    END

 
    IF NOT EXISTS (SELECT 1 FROM Sales.OrderDetail WHERE OrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        SET @ErrorMessage = 'Error: The ProductID ' + CAST(@ProductID AS NVARCHAR(10)) + ' does not exist for OrderID ' + CAST(@OrderID AS NVARCHAR(10)) + '.';
        PRINT @ErrorMessage;
        RETURN -1;
    END

    DELETE FROM Sales.OrderDetail
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    IF @@ROWCOUNT = 0
    BEGIN
        SET @ErrorMessage = 'Error: Failed to delete the order detail for OrderID ' + CAST(@OrderID AS NVARCHAR(10)) + ' and ProductID ' + CAST(@ProductID AS NVARCHAR(10)) + '.';
        PRINT @ErrorMessage;
        RETURN -1;
    END

    PRINT 'Successfully deleted the order detail for OrderID ' + CAST(@OrderID AS NVARCHAR(10)) + ' and ProductID ' + CAST(@ProductID AS NVARCHAR(10)) + '.';
END;


Functions 
1. 
CREATE FUNCTION dbo.FormatDate_MMDDYYYY (@InputDate DATETIME)
RETURNS NVARCHAR(10)
AS
BEGIN
    RETURN CONVERT(VARCHAR(10), @InputDate, 101);
END;


2.
CREATE FUNCTION dbo.FormatDate_YYYYMMDD (@InputDate DATETIME)
RETURNS NVARCHAR(8)
AS
BEGIN
    RETURN CONVERT(VARCHAR(8), @InputDate, 112);
END;

Views
1.
CREATE VIEW vwCustomerOrders AS
SELECT 
    s.Name AS CompanyName,
    o.SalesOrderID AS OrderID,
    o.OrderDate,
    od.ProductID,
    p.Name AS ProductName,
    od.OrderQty AS Quantity,
    od.UnitPrice,
    od.OrderQty * od.UnitPrice AS TotalPrice
FROM 
    Sales.SalesOrderHeader AS o
INNER JOIN 
    Sales.SalesOrderDetail AS od ON o.SalesOrderID = od.SalesOrderID
INNER JOIN 
    Production.Product AS p ON od.ProductID = p.ProductID
INNER JOIN 
    Sales.Customer AS c ON o.CustomerID = c.CustomerID
LEFT JOIN 
    Sales.Store AS s ON c.StoreID = s.BusinessEntityID;


2.
    CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT 
    s.Name AS CompanyName,
    o.SalesOrderID AS OrderID,
    o.OrderDate,
    od.ProductID,
    p.Name AS ProductName,
    od.OrderQty AS Quantity,
    od.UnitPrice,
    od.OrderQty * od.UnitPrice AS TotalPrice
FROM 
    Sales.SalesOrderHeader AS o
INNER JOIN 
    Sales.SalesOrderDetail AS od ON o.SalesOrderID = od.SalesOrderID
INNER JOIN 
    Production.Product AS p ON od.ProductID = p.ProductID
INNER JOIN 
    Sales.Customer AS c ON o.CustomerID = c.CustomerID
LEFT JOIN 
    Sales.Store AS s ON c.StoreID = s.BusinessEntityID
WHERE 
    o.OrderDate >= CAST(CONVERT(VARCHAR, DATEADD(day, -1, GETDATE()), 101) AS DATE)
    AND o.OrderDate < CAST(CONVERT(VARCHAR, GETDATE(), 101) AS DATE);

 3.
 CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.QuantityPerUnit,
    p.ListPrice AS UnitPrice,
    s.Name AS CompanyName,
    c.Name AS CategoryName
FROM 
    Production.Product AS p
INNER JOIN 
    Purchasing.ProductVendor AS pv ON p.ProductID = pv.ProductID
INNER JOIN 
    Purchasing.Vendor AS s ON pv.BusinessEntityID = s.BusinessEntityID
INNER JOIN 
    Production.ProductSubcategory AS ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
INNER JOIN 
    Production.ProductCategory AS c ON ps.ProductCategoryID = c.ProductCategoryID
WHERE 
    p.DiscontinuedDate IS NULL;


Triggers
1. 
CREATE TRIGGER trgInsteadOfDeleteOrders
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OrderID INT;

    DECLARE delete_cursor CURSOR FOR 
    SELECT OrderID FROM deleted;
    
    OPEN delete_cursor;

    FETCH NEXT FROM delete_cursor INTO @OrderID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DELETE FROM [Order Details] WHERE OrderID = @OrderID;


        DELETE FROM Orders WHERE OrderID = @OrderID;

        FETCH NEXT FROM delete_cursor INTO @OrderID;
    END;

    CLOSE delete_cursor;
    DEALLOCATE delete_cursor;
END;

DECLARE @OrderID INT;
SET @OrderID = (SELECT TOP 1 OrderID FROM Orders ORDER BY OrderID DESC);

INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES (@OrderID, (SELECT TOP 1 ProductID FROM Products ORDER BY ProductID DESC), 20.00, 10, 0);

DELETE FROM Orders WHERE OrderID = @OrderID;
SELECT * FROM Orders WHERE OrderID = @OrderID;
SELECT * FROM [Order Details] WHERE OrderID = @OrderID;




2.
CREATE TRIGGER trgAfterInsertOrderDetails
ON [Order Details]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @OrderQty INT, @UnitsInStock INT;

    -- Loop through each inserted row
    DECLARE insert_cursor CURSOR FOR 
    SELECT ProductID, Quantity FROM inserted;
    
    OPEN insert_cursor;

    FETCH NEXT FROM insert_cursor INTO @ProductID, @OrderQty;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check stock
        SELECT @UnitsInStock = UnitsInStock FROM Products WHERE ProductID = @ProductID;

        IF @UnitsInStock < @OrderQty
        BEGIN
            -- Rollback the transaction if insufficient stock
            ROLLBACK TRANSACTION;
            RAISERROR ('Insufficient stock for product ID %d. Order cannot be fulfilled.', 16, 1, @ProductID);
            RETURN;
        END
        ELSE
        BEGIN
            -- Update stock
            UPDATE Products
            SET UnitsInStock = UnitsInStock - @OrderQty
            WHERE ProductID = @ProductID;
        END

        FETCH NEXT FROM insert_cursor INTO @ProductID, @OrderQty;
    END;

    CLOSE insert_cursor;
    DEALLOCATE insert_cursor;
END;

INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES (@OrderID, (SELECT TOP 1 ProductID FROM Products ORDER BY ProductID DESC), 20.00, 5, 0);


INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES (@OrderID, (SELECT TOP 1 ProductID FROM Products ORDER BY ProductID DESC), 20.00, 200, 0);
