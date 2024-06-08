1. List of all customers

Select FirstName,LastName
From Person.Person
Order by FirstName ASC

2. list of all customers where company name ending in N

SELECT Customer.CustomerID,Store.Name AS CompanyName
FROM Sales.Customer
JOIN Sales.Store ON Customer.StoreID = Store.BusinessEntityID
WHERE Store.Name LIKE '%N'

3. list of all customers who live in Berlin or London

SELECT 
    Customer.CustomerID,
    Person.FirstName,
    Person.LastName,
    Address.City
FROM 
    Sales.Customer AS Customer
JOIN 
    Person.Person AS Person ON Customer.PersonID=Person.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress AS BusinessEntityAddress ON Person.BusinessEntityID=BusinessEntityAddress.BusinessEntityID
JOIN 
    Person.Address AS Address ON BusinessEntityAddress.AddressID=Address.AddressID
WHERE 
    Address.City IN ('Berlin', 'London')


4. list of all customers who live in UK or USA

SELECT 
    Customer.CustomerID,
    Person.FirstName,
    Person.LastName,
    sp.CountryRegionCode
FROM 
    Sales.Customer AS Customer
JOIN 
    Person.Person AS Person ON Customer.PersonID = Person.BusinessEntityID
JOIN 
    Person.BusinessEntityAddress AS BusinessEntityAddress ON Person.BusinessEntityID = BusinessEntityAddress.BusinessEntityID
JOIN 
    Person.Address AS Address ON BusinessEntityAddress.AddressID = Address.AddressID
JOIN 
    Person.StateProvince AS sp ON Address.StateProvinceID = sp.StateProvinceID
WHERE 
    sp.CountryRegionCode IN ('UK', 'USA')


5. list of all products sorted by product name
SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color
FROM Production.Product
ORDER BY 
    ProductName


6. list of all products where product name starts with an A

SELECT 
    ProductID,
    Name AS ProductName,
    ProductNumber,
    Color
FROM 
    Production.Product
WHERE 
    Name LIKE 'A%'
ORDER BY 
    ProductName

7. List of customers who ever placed an order

SELECT DISTINCT 
    Sales.Customer.CustomerID,
    Person.Person.FirstName,
    Person.Person.LastName
FROM 
    Sales.Customer
JOIN 
    Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
JOIN 
    Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID;


8. list of Customers who live in London and have bought chai

SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID

SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress AS bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address AS a ON bea.AddressID = a.AddressID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN  Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS prod ON sod.ProductID = prod.ProductID
WHERE a.City = 'London' AND prod.Name = 'Chai';


9. List of customers who never place an order

SELECT 
    Customer.CustomerID,
    Person.FirstName,
    Person.LastName
FROM 
    Sales.Customer AS Customer
JOIN 
    Person.Person AS Person ON Customer.PersonID = Person.BusinessEntityID
LEFT JOIN 
    Sales.SalesOrderHeader AS SalesOrder ON Customer.CustomerID = SalesOrder.CustomerID
WHERE 
    SalesOrder.CustomerID IS NULL


10. List of customers who ordered Tofu


SELECT DISTINCT
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM 
    Sales.Customer AS c
JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN 
    Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Production.Product AS prod ON sod.ProductID = prod.ProductID
WHERE 
    prod.Name = 'Tofu';


11. Details of first order of the system

SELECT TOP 1
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID,
    p.FirstName,
    p.LastName
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
ORDER BY 
    soh.OrderDate;

12. Find the details of most expensive order date

SELECT TOP 1
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerID,
    p.FirstName,
    p.LastName,
    soh.TotalDue
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
ORDER BY 
    soh.TotalDue DESC;


13. For each order get the OrderID and Average quantity of items in that order

SELECT 
    SalesOrderID AS OrderID,
    AVG(OrderQty) AS AverageQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID;

SELECT 
    SalesOrderID AS OrderID,
    MIN(OrderQty) AS MinQuantity,
    MAX(OrderQty) AS MaxQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID;

14. For each order get the orderID, minimum quantity and maximum quantity for that order

SELECT 
    SalesOrderID,
    MIN(OrderQty) AS MinQuantity,
    MAX(OrderQty) AS MaxQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID;


15. Get a list of all managers and total number of employees who report to them.

SELECT 
    Manager.ManagerID,
    CONCAT(Manager.FirstName, ' ', Manager.LastName) AS ManagerName,
    COUNT(*) AS TotalEmployees
FROM 
    HumanResources.Employee AS Manager
JOIN 
    HumanResources.Employee AS Employee ON Manager.BusinessEntityID = Employee.ManagerID
GROUP BY 
    Manager.ManagerID, Manager.FirstName, Manager.LastName;


16. Get the OrderID and the total quantity for each order that has a total quantity of greater than 300

SELECT 
    SalesOrderID AS OrderID,
    SUM(OrderQty) AS TotalQuantity
FROM 
    Sales.SalesOrderDetail
GROUP BY 
    SalesOrderID
HAVING 
    SUM(OrderQty) > 300;

17. list of all orders placed on or after 1996/12/31

SELECT 
    SalesOrderID,
    OrderDate
FROM 
    Sales.SalesOrderHeader
WHERE 
    OrderDate >= '1996-12-31'


18. list of all orders shipped to Canada

SELECT 
    soh.SalesOrderID,
    soh.OrderDate
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    Purchasing.ShipMethod AS sm ON soh.ShipMethodID = sm.ShipMethodID
WHERE 
    sm.Name LIKE '%Canada%';


19. list of all orders with order total > 200

SELECT 
    SalesOrderID,
    OrderDate,
    TotalDue
FROM 
    Sales.SalesOrderHeader
WHERE 
    TotalDue > 200;

20. List of countries and sales made in each country

SELECT 
    Person.Address.CountryRegionCode AS Country,
    SUM(Sales.SalesOrderHeader.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader
JOIN 
    Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID
GROUP BY 
    Person.Address.CountryRegionCode;


21. List of Customer ContactName and number of orders they placed

SELECT 
    Person.Person.FirstName + ' ' + Person.Person.LastName AS ContactName,
    COUNT(Sales.SalesOrderHeader.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.Customer
JOIN 
    Sales.SalesOrderHeader ON Sales.Customer.CustomerID = Sales.SalesOrderHeader.CustomerID
JOIN 
    Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
GROUP BY 
    Person.Person.FirstName, Person.Person.LastName;



22. List of customer contactnames who have placed more than 3 orders

SELECT 
    p.FirstName + ' ' + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.Customer AS c
JOIN 
    Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
JOIN 
    Person.Person AS p ON c.PersonID = p.BusinessEntityID
GROUP BY 
    p.FirstName, p.LastName
HAVING 
    COUNT(soh.SalesOrderID) > 3;

23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998

SELECT DISTINCT
    p.Name AS ProductName
FROM 
    Production.Product AS p
JOIN 
    Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
JOIN 
    Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE 
    p.DiscontinuedDate IS NOT NULL
    AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';


24. List of employee firsname, lastName, superviser FirstName, LastName

SELECT 
    e.FirstName AS EmployeeFirstName,
    e.LastName AS EmployeeLastName,
    m.FirstName AS SupervisorFirstName,
    m.LastName AS SupervisorLastName
FROM 
    HumanResources.Employee AS emp
JOIN 
    Person.Person AS e ON emp.BusinessEntityID = e.BusinessEntityID
LEFT JOIN 
    HumanResources.Employee AS sup ON emp.ManagerID = sup.BusinessEntityID
LEFT JOIN 
    Person.Person AS m ON sup.BusinessEntityID = m.BusinessEntityID;


25. List of Employees id and total sale condcuted by employee

SELECT 
    e.BusinessEntityID AS EmployeeID,
    SUM(soh.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader AS soh
JOIN 
    HumanResources.Employee AS e ON soh.SalesPersonID = e.BusinessEntityID
GROUP BY 
    e.BusinessEntityID;


26. list of employees whose FirstName contains character a

SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName,
    p.LastName
FROM 
    HumanResources.Employee AS e
JOIN 
    Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
WHERE 
    p.FirstName LIKE '%a%';

27. List of managers who have more than four people reporting to them.

SELECT 
    e.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(emp.BusinessEntityID) AS NumberOfReports
FROM 
    HumanResources.Employee AS emp
JOIN 
    HumanResources.Employee AS e ON emp.ManagerID = e.BusinessEntityID
JOIN 
    Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
GROUP BY 
    e.BusinessEntityID, p.FirstName, p.LastName
HAVING 
    COUNT(emp.BusinessEntityID) > 4;


28. List of Orders and ProductNames

SELECT 
    soh.SalesOrderID,
    p.Name AS ProductName
FROM 
    Sales.SalesOrderDetail AS sod
JOIN 
    Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
JOIN 
    Production.Product AS p ON sod.ProductID = p.ProductID;


29. List of orders place by the best customer

WITH BestCustomer AS (
    SELECT 
        SalesOrderHeader.CustomerID,
        SUM(SalesOrderHeader.TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader
    GROUP BY 
        Sales.SalesOrderHeader.CustomerID
    ORDER BY 
        TotalSales DESC
    FETCH FIRST 1 ROWS ONLY

30. List of orders placed by customers who do not have a Fax number

SELECT 
    Sales.SalesOrderHeader.SalesOrderID,
    Sales.SalesOrderHeader.OrderDate,
    Sales.SalesOrderHeader.TotalDue
FROM 
    Sales.SalesOrderHeader
JOIN 
    Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
JOIN 
    Person.Person ON Sales.Customer.PersonID = Person.Person.BusinessEntityID
WHERE 
    Person.Person.FaxNumber IS NULL;


31. List of Postal codes where the product Tofu was shipped

SELECT DISTINCT
    Person.Address.PostalCode
FROM 
    Sales.SalesOrderDetail
JOIN 
    Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
JOIN 
    Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN 
    Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID
WHERE 
    Production.Product.Name = 'Tofu';


32. List of product Names that were shipped to France

SELECT DISTINCT
    Production.Product.Name AS ProductName
FROM 
    Sales.SalesOrderDetail
JOIN 
    Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
JOIN 
    Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
JOIN 
    Person.Address ON Sales.SalesOrderHeader.ShipToAddressID = Person.Address.AddressID
JOIN 
    Person.StateProvince ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID
JOIN 
    Person.CountryRegion ON Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode
WHERE 
    Person.CountryRegion.Name = 'France';


33. List of ProductNames and Categories for the supplier 'Specialty Biscuits, Ltd'.

SELECT 
    Production.Product.Name AS ProductName,
    Production.ProductCategory.Name AS CategoryName
FROM 
    Production.Product
JOIN 
    Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
JOIN 
    Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID
JOIN 
    Purchasing.ProductVendor ON Production.Product.ProductID = Purchasing.ProductVendor.ProductID
JOIN 
    Purchasing.Vendor ON Purchasing.ProductVendor.BusinessEntityID = Purchasing.Vendor.BusinessEntityID
WHERE 
    Purchasing.Vendor.Name = 'Specialty Biscuits, Ltd.';


34. List of products that were never ordered

SELECT 
    Production.Product.Name AS ProductName
FROM 
    Production.Product
LEFT JOIN 
    Sales.SalesOrderDetail ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID
WHERE 
    Sales.SalesOrderDetail.ProductID IS NULL;


35. List of products where units in stock is less than 10 and units on order are 0.

SELECT 
    Production.Product.Name AS ProductName,
    Production.ProductInventory.Quantity AS UnitsInStock,
    Production.ProductInventory.Quantity - Production.ProductInventory.SafetyStockLevel AS UnitsOnOrder
FROM 
    Production.Product
JOIN 
    Production.ProductInventory ON Production.Product.ProductID = Production.ProductInventory.ProductID
WHERE 
    Production.ProductInventory.Quantity < 10
    AND (Production.ProductInventory.Quantity - Production.ProductInventory.SafetyStockLevel) = 0;


    
 36. List of top 10 countries by sales
   
SELECT 
    Person.CountryRegion.Name AS Country,
    SUM(Sales.SalesOrderHeader.TotalDue) AS TotalSales
FROM 
    Sales.SalesOrderHeader
JOIN 
    Person.Address ON Sales.SalesOrderHeader.BillToAddressID = Person.Address.AddressID
JOIN 
    Person.StateProvince ON Person.Address.StateProvinceID = Person.StateProvince.StateProvinceID
JOIN 
    Person.CountryRegion ON Person.StateProvince.CountryRegionCode = Person.CountryRegion.CountryRegionCode
GROUP BY 
    Person.CountryRegion.Name
ORDER BY 
    TotalSales DESC
FETCH FIRST 10 ROWS ONLY;


37. Number of orders each employee has taken for customers with CustomerIDs between A and AO

SELECT 
    Sales.SalesOrderHeader.SalesPersonID AS EmployeeID,
    COUNT(Sales.SalesOrderHeader.SalesOrderID) AS NumberOfOrders
FROM 
    Sales.SalesOrderHeader
JOIN 
    Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
WHERE 
    Sales.Customer.CustomerID BETWEEN 'A' AND 'AO'
GROUP BY 
    Sales.SalesOrderHeader.SalesPersonID;


38. Orderdate of most expensive order

SELECT 
    TOP 1 Sales.SalesOrderHeader.OrderDate
FROM 
    Sales.SalesOrderHeader
ORDER BY 
    Sales.SalesOrderHeader.TotalDue DESC;


39. Product name and total revenue from that product

SELECT 
    Production.Product.Name AS ProductName,
    SUM(Sales.SalesOrderDetail.LineTotal) AS TotalRevenue
FROM 
    Production.Product
JOIN 
    Sales.SalesOrderDetail ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID
GROUP BY 
    Production.Product.Name;


40. Supplierid and number of products offered
SELECT 
    Purchasing.Vendor.BusinessEntityID AS SupplierID,
    COUNT(Production.Product.ProductID) AS NumberOfProducts
FROM 
    Production.Product
JOIN 
    Purchasing.ProductVendor ON Production.Product.ProductID = Purchasing.ProductVendor.ProductID
JOIN 
    Purchasing.Vendor ON Purchasing.ProductVendor.BusinessEntityID = Purchasing.Vendor.BusinessEntityID
GROUP BY 
    Purchasing.Vendor.BusinessEntityID;


41. Top ten customers based on their business

SELECT 
    TOP 10 Sales.Customer.CustomerID,
    SUM(Sales.SalesOrderHeader.TotalDue) AS TotalBusiness
FROM 
    Sales.SalesOrderHeader
JOIN 
    Sales.Customer ON Sales.SalesOrderHeader.CustomerID = Sales.Customer.CustomerID
GROUP BY 
    Sales.Customer.CustomerID
ORDER BY 
    TotalBusiness DESC;

42. What is the total revenue of the company

SELECT SUM(Sales.SalesOrderHeader.TotalDue) AS TotalRevenue
FROM Sales.SalesOrderHeader;
