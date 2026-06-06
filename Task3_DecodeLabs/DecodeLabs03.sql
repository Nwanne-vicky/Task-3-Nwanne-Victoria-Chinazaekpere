Create Database SalesData;

Select *
from dbo.SalesData

--Cleaning Dataset
UPDATE dbo.SalesData
SET CouponCode = 'No coupon'
WHERE CouponCode IS NULL;

--Checking
Select *
from dbo.SalesData
where CouponCode = 'No coupon'

SELECT 
    TotalPrice,
    TRY_CAST(TotalPrice AS DECIMAL(10,2)) AS ConvertedTotalPrice
FROM dbo.SalesData;

SELECT 
    UnitPrice,
    TRY_CAST(UnitPrice AS DECIMAL(10,2)) AS ConvertedUnitPrice
FROM dbo.SalesData;

--Checking for errors before converting total price to 2 decimal
SELECT TotalPrice
FROM dbo.SalesData
WHERE TRY_CAST(TotalPrice AS DECIMAL(10,2)) IS NULL
AND TotalPrice IS NOT NULL;

--Updating the datatypes
Alter Table dbo.salesData
Alter Column TotalPrice DECIMAL(10,2);

Alter Table dbo.salesData
Alter Column UnitPrice DECIMAL(10,2);

--Checking for duplicate
Select CustomerID, Count(*) as CustomerIDCount
from dbo.SalesData
Group by CustomerID
--Having Count(*) > 1
Order by CustomerIDCount Desc

Select CustomerID, OrderID,
Product,TotalPrice,
Count(*) over(Partition by CustomerID, OrderID, Product, UnitPrice) As DuplicateCount
From dbo.SalesData
Order by CustomerID 

--Using CTE expression to obtain duplicate
With CustomerDuplicate As
(
Select CustomerID, OrderID,
Product,TotalPrice,
Count(*) over(Partition by CustomerID) As DuplicateCount
From dbo.SalesData
)

Select *
From CustomerDuplicate
Where DuplicateCount > 1


--Product Category comparism
Select Distinct Product, Sum(TotalPrice) as TotalProductPrice
from dbo.SalesData
Group by Product
order by TotalProductPrice Desc

--Top-Selling Product
Select Top 5 Product, Sum(Quantity) as TotalQuantity, Sum(TotalPrice) as TotalProductPrice
from dbo.SalesData
Group by Product
order by TotalQuantity Desc

--PaymentMethod Comparism
Select Distinct PaymentMethod, Count(*) as PaymentMethodCount
from dbo.SalesData
Group by PaymentMethod
order by PaymentMethodCount Desc

Select Distinct PaymentMethod, Cast(Avg(TotalPrice) As Decimal(10,2)) as PaymentMethodCount
from dbo.SalesData
Group by PaymentMethod
order by PaymentMethodCount Desc

--OrderStatus Comparism
Select Distinct OrderStatus, Count(*) as OrderStatusCount
from dbo.SalesData
Group by OrderStatus
order by OrderStatusCount Desc

Select Distinct OrderStatus, Sum(TotalPrice) as OrderStatusCount
from dbo.SalesData
Group by OrderStatus
order by OrderStatusCount Desc

Select Distinct OrderStatus, Cast(Avg(TotalPrice) As Decimal(10,2)) as AvgTotalPrice
from dbo.SalesData
Group by OrderStatus
order by AvgTotalPrice Desc

--Referral Source Performance
Select ReferralSource, Count(OrderID) as ReferralSourceCount, 
Sum(TotalPrice) as ReferralSourceCount
from dbo.SalesData
Group by ReferralSource
order by ReferralSourceCount Desc


Select Distinct ReferralSource, Cast(Avg(TotalPrice) As Decimal(10,2)) as AvgTotalPrice
from dbo.SalesData
Group by ReferralSource
order by AvgTotalPrice Desc

--Most Valuable Customer
Select Top 10 CustomerID, 
Count(OrderID) As TotalOrders, 
Sum(TotalPrice) As CustomerSpending
From dbo.SalesData
group by CustomerID
Order by CustomerSpending Desc

--Detect Duplicate Customers
SELECT CustomerID, COUNT(*) AS DuplicateCount 
FROM dbo.SalesData 
GROUP BY CustomerID 
HAVING COUNT(*) > 1;

--Average Order Value
Select Avg(TotalPrice) As AvgPrice
from dbo.SalesData

SELECT 
    Product,
    SUM(TotalPrice) AS Revenue,
    
    CAST(
        100.0 * SUM(TotalPrice)
        / SUM(SUM(TotalPrice)) OVER()
        AS DECIMAL(10,2)
    ) AS RevenuePercentage
FROM dbo.SalesData
GROUP BY Product
ORDER BY Revenue DESC;

--Shipping Address Analysis
Select Top 10 ShippingAddress, 
count(OrderID) as TotalOrders,
sum(TotalPrice) as TotalRevenue
From dbo.SalesData
Group by ShippingAddress
order by TotalRevenue Desc

--Highest Revenue Product Per Customer
WITH ProductRevenue AS
(
    SELECT 
        CustomerID,
        Product,
        SUM(TotalPrice) AS Revenue,
        
        RANK() OVER(
            PARTITION BY CustomerID
            ORDER BY SUM(TotalPrice) DESC
        ) AS ProductRank
        
    FROM dbo.SalesData
    GROUP BY CustomerID, Product
)

SELECT *
FROM ProductRevenue
WHERE ProductRank = 1;




SELECT 
    Date,
    TotalPrice,
    SUM(TotalPrice) OVER(
        ORDER BY Date
    ) AS RunningRevenue
FROM dbo.SalesData;







