USE AdventureWorks2019;
/*
Question 11:

a. How many employees exist in the Database?

b. How many of these employees are active employees?

c. How many Job Titles equal the 'SP' Person type?

d. How many of these employees are sales people?
*/
--a.
SELECT 
  COUNT (*) as total_emp_count 
FROM 
  HumanResources.Employee e;
--b.
SELECT 
  COUNT(*) as active_emp_count 
from 
  HumanResources.Employee e 
  LEFT JOIN HumanResources.EmployeeDepartmentHistory edh on e.BusinessEntityID = edh.BusinessEntityID 
where 
  edh.EndDate is null;
--c.
SELECT 
  count(distinct e.JobTitle) whatever_this_is_count 
FROM 
  Person.Person p 
  INNER JOIN HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID 
WHERE 
  p.PersonType = 'SP';
--d.
SELECT 
  COUNT(distinct e.BusinessEntityID) as sales_people_count 
FROM 
  Person.Person p 
  INNER JOIN HumanResources.Employee e on p.BusinessEntityID = e.BusinessEntityID 
WHERE 
  p.PersonType = 'SP';


/*
Question 12:

a. What is the name of the CEO? Concatenate first and last name.

b. When did this person start working for AdventureWorks

c. Who reports to the CEO? Includes their names and title
*/

--a & b
select 
  e.HireDate, 
  CONCAT (p.FirstName, ' ', p.LastName) AS full_name 
from 
  HumanResources.Employee e 
  left join Person.Person p on e.BusinessEntityID = p.BusinessEntityID 
where 
  e.JobTitle = 'Chief Executive Officer';
-- c
select 
  e.JobTitle, 
  CONCAT (p.FirstName, ' ', p.LastName) AS full_name 
from 
  HumanResources.Employee e 
  left join Person.Person p on e.BusinessEntityID = p.BusinessEntityID 
where 
  e.OrganizationLevel = '1';


/*
Question 13

a. What is the job title for John Evans

b. What department does John Evans work in?
*/
select 
  CONCAT (p.FirstName, ' ', p.LastName) AS full_name, 
  e.JobTitle, 
  edh.DepartmentID, 
  d.Name 
from 
  HumanResources.Employee e 
  left join Person.Person p on e.BusinessEntityID = p.BusinessEntityID 
  left join HumanResources.EmployeeDepartmentHistory edh on p.BusinessEntityID = edh.BusinessEntityID 
  left join HumanResources.Department d on edh.DepartmentID = d.DepartmentID 
where 
  p.FirstName = 'John' 
  and p.LastName = 'Evans';


/*
Question 14

a. Which Purchasing vendors have the highest credit rating?

b. Using a case statement replace the 1 and 0 in Vendor.PreferredVendorStatus 
to "Preferred" vs "Not Preferred."   How many vendors are considered Preferred?

c. For Active Vendors only, do Preferred vendors have a High or lower average credit rating?

d. How many vendors are active and Not Preferred?
*/

--a.
SELECT 
  v.name, 
  CAST(v.CreditRating as decimal) as CreditRating 
FROM 
  Purchasing.Vendor v 
WHERE 
  CreditRating = 1;
--b.
SELECT 
  COUNT(*) AS PreferredVendorCount 
FROM 
  (
    SELECT 
      v.PreferredVendorStatus as PreferredVendorStatusDecimal, 
      case when v.PreferredVendorStatus = 1 then 'Preferred' else 'Not Preferred' end as PreferredVendorStatus 
    FROM 
      Purchasing.Vendor v
  ) as subquery 
WHERE 
  subquery.PreferredVendorStatus = 'Preferred';
Select 
  Case when PreferredVendorStatus = '1' Then 'Preferred' Else 'Not Preferred' End as PreferredStatus, 
  count(*) as CNT 
From 
  Purchasing.Vendor 
Group by 
  Case when PreferredVendorStatus = '1' Then 'Preferred' Else 'Not Preferred' End;
--c.
SELECT 
  case when v.PreferredVendorStatus = 1 then 'Preferred' else 'Not Preferred' end as PreferredVendorStatus, 
  AVG(
    CAST(v.CreditRating as decimal)
  ) as avgRating 
FROM 
  Purchasing.Vendor v 
WHERE 
  v.ActiveFlag = 1 
group by 
  case when v.PreferredVendorStatus = 1 then 'Preferred' else 'Not Preferred' end;
--d.
select 
  COUNT(*) as activeNotPreferredCnt 
from 
  Purchasing.Vendor 
where 
  ActiveFlag = 1 
  and PreferredVendorStatus = 0;


/*
Question 15:

Assume today is August 15, 2014.

a. Calculate the age for every current employee. What is the age of the oldest employee?

b. What is the average age by Organization level? Show answer with a single decimal

c. Use the ceiling function to round up

d. Use the floor function to round down
*/
SELECT 
  DATEFROMPARTS(2014, 8, 15) as MyDate;
--a.
SELECT 
  e.BusinessEntityID, 
  e.BirthDate, 
  DATEDIFF(
    year, 
    e.BirthDate, 
    DATEFROMPARTS(2014, 8, 15)
  ) as EmpAge --I could simply write '2014-08-15'
FROM 
  HumanResources.Employee e 
ORDER BY 
  EmpAge DESC;
--b, c, d
SELECT 
  CAST(
    AVG(
      DATEDIFF(year, e.BirthDate, '2014-08-15')
    ) AS DECIMAL (10, 1)
  ) as AvgEmpAge, 
  CEILING(
    CAST(
      AVG(
        DATEDIFF(year, e.BirthDate, '2014-08-15')
      ) AS DECIMAL(10, 1)
    )
  ) as CeilingEmpAge, 
  FLOOR(
    CAST(
      AVG(
        DATEDIFF(year, e.BirthDate, '2014-08-15')
      ) AS DECIMAL(10, 1)
    )
  ) as FloorEmpAge, 
  AVG(
    cast(
      datediff(year, BirthDate, '2014-08-15') as decimal
    )
  ), 
  OrganizationLevel 
FROM 
  HumanResources.Employee e 
GROUP BY 
  OrganizationLevel;


/*
Question 16:

a. How many products are sold by AdventureWorks?

b. How many of these products are actively being sold by AdventureWorks?

c. How many of these active products are made in house vs. purchased?
--Production.Product MakeFlag
*/

select 
  top 10 * 
from 
  Production.Product;
-- a.
SELECT 
  COUNT(distinct ProductID) as prodCount 
FROM 
  Production.Product 
WHERE 
  FinishedGoodsFlag = 1;
--b.
SELECT 
  COUNT(distinct ProductID) as prodCount 
FROM 
  Production.Product 
WHERE 
  SellEndDate IS NULL 
  AND FinishedGoodsFlag = 1;
--c.
SELECT 
  COUNT(
    distinct CASE WHEN p.MakeFlag = 0 THEN p.ProductID END
  ) as purchasedProdCnt, 
  COUNT(
    distinct CASE WHEN p.MakeFlag = 1 THEN p.ProductID END
  ) as inHouseProdCnt 
FROM 
  Production.Product p 
WHERE 
  SellEndDate IS NULL 
  AND FinishedGoodsFlag = 1;


/*
Question 17

We learned in Question 16 that the product table includes a few different type of products - i.e., manufactured vs. purchased.

a. Sum the LineTotal in SalesOrderDetail. Format as currency

b. Sum the LineTotal in SalesOrderDetail by the MakeFlag in the product table. 
Use a case statement to specify manufactured vs. purchased. Format as currency.

c. Add a count of distinct SalesOrderIDs

d. What is the average LineTotal per SalesOrderID?
*/

--a.
SELECT 
  FORMAT(
    SUM(LineTotal), 
    'C', 
    'en-us'
  ) as TotalAmount 
FROM 
  Sales.SalesOrderDetail;
--b
SELECT 
  CASE WHEN p.MakeFlag = 0 THEN 'Purchased' ELSE 'Manufactured' END AS MakeFlagDesc, 
  FORMAT(
    sum(od.LineTotal), 
    'C', 
    'en-us'
  ) as TotalAmount 
FROM 
  Sales.SalesOrderDetail od 
  LEFT JOIN Production.Product p on od.ProductID = p.ProductID 
GROUP BY 
  p.MakeFlag;
--c
SELECT 
  CASE WHEN p.MakeFlag = 0 THEN 'Purchased' ELSE 'Manufactured' END AS MakeFlagDesc, 
  FORMAT(
    sum(od.LineTotal), 
    'C', 
    'en-us'
  ) as TotalAmount, 
  FORMAT(
    COUNT(DISTINCT od.SalesOrderID), 
    'N0'
  ) as OrderCnt 
FROM 
  Sales.SalesOrderDetail od 
  LEFT JOIN Production.Product p on od.ProductID = p.ProductID 
GROUP BY 
  p.MakeFlag;
--d.
SELECT 
  CASE WHEN p.MakeFlag = 0 THEN 'Purchased' ELSE 'Manufactured' END AS MakeFlagDesc, 
  FORMAT(
    sum(od.LineTotal), 
    'C', 
    'en-us'
  ) as TotalAmount, 
  FORMAT(
    COUNT(DISTINCT od.SalesOrderID), 
    'N0'
  ) as OrderCnt, 
  FORMAT(
    SUM(LineTotal)/ COUNT(DISTINCT od.SalesOrderID), 
    'C0'
  ) AS AvgLineTotal 
FROM 
  Sales.SalesOrderDetail od 
  LEFT JOIN Production.Product p on od.ProductID = p.ProductID 
GROUP BY 
  p.MakeFlag;

/*
Question 18

The AdventureWorks Cyclery database includes historical and present transactions.

a. In the TransactionHistory and TransactionHistoryArchive tables a "W","S",
and "P" are used as Transaction types. What do these abbreviations mean?

b. Union TransactionHistory and TransactionHistoryArchive

c. Find the First and Last TransactionDate in the TransactionHistory 
and TransactionHistoryArchive tables. Use the union written in part b. 
The current data type for TransactionDate is datetime. Convert or Cast the data type to date.

d. Find the First and Last Date for each transaction type. 
Use a case statement to specify the transaction types. 
*/

-- a.
/*
W = Work Order
P = Purchase Order
S = Sales Order
*/

--b.
SELECT 
  * 
FROM 
  Production.TransactionHistory 
UNION 
  --ALL
SELECT 
  * 
FROM 
  Production.TransactionHistoryArchive;
-- c.
Select 
  Cast(
    MIN(TransactionDate) as Date
  ) as FirstDate, 
  Convert(
    date, 
    MAX(TransactionDate)
  ) as LastDate 
From 
  (
    Select 
      * 
    from 
      Production.TransactionHistoryArchive 
    Union 
    Select 
      * 
    from 
      Production.TransactionHistory
  ) a 
  --d. 
  -- so basiaclly if i need to select min, max, aggregations etc.
  -- for various categories of variables write CASE WHEN statement
Select 
  Case When TransactionType = 'W' Then 'WorkOrder' When TransactionType = 'S' Then 'SalesOrder' When TransactionType = 'P' Then 'PurchaseOrder' Else Null End as TransactionType, 
  Convert(
    date, 
    MIN(TransactionDate)
  ) as FirstDate, 
  Convert(
    date, 
    MAX(TransactionDate)
  ) as LastDate 
From 
  (
    Select 
      * 
    from 
      Production.TransactionHistoryArchive 
    Union 
    Select 
      * 
    from 
      Production.TransactionHistory
  ) a 
Group by 
  TransactionType;


/*
Question 19

We learned in Question 18 that the most recent SalesOrder transaction occurred on 2014-06-30 
and the First Sales Order transaction occurred on 2011-05-31. 

Does the SalesOrderHeader table show a similar Order date for the first and Last Sale? Format as Date 
*/
SELECT 
  MIN(
    cast(soh.OrderDate as date)
  ) as firstOrder, 
  MAX(
    convert(date, soh.OrderDate)
  ) as lastOrder 
FROM 
  Sales.SalesOrderHeader soh;

-- yes, they do

/*
Question 20

We learned in Question 19 that the first and most recent OrderDate in the SalesOrderHeader table
matches the Sales Order Dates in the transactionHistory table (Question 18).

a. Find the other tables and dates that should match the WorkOrder
and PurchaseOrder Dates. Format these dates as a date in the YYYY-MM-DD format.

b. Do the dates match? Why/Why not?
*/

--a.
SELECT 
  MIN(
    convert(varchar, StartDate, 23)
  ) as workOrderMinDate, 
  MAX(
    convert(varchar, StartDate, 23)
  ) as workOrderMaxDate 
FROM 
  Production.WorkOrder;
SELECT 
  MIN(
    convert(varchar, OrderDate, 23)
  ) as purchaseOrderMinDate, 
  MAX(
    convert(varchar, OrderDate, 23)
  ) as purchaseOrderMaxDate 
FROM 
  Purchasing.PurchaseOrderHeader;

--b.
-- work order matches, purchase order doesn't