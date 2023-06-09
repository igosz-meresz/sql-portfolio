USE AdventureWorks2019;

/*
Question 41:

In this question we are going to build a report that will be used in Question 42 to update a null column in the SalesOrderHeader.
The results in this question need to include one row per SalesOrderID (31,465 rows). Include the following columns:

a. SalesOrderID
b. Customer Name (include First and Last Names)
c. Person.PersonType (don't use the abbreviations, spell out each PersonType)
d. Sales Person Name (include First and Last Names). If a SalesOrderID doesn't have a Sales person then specify with 'No Sales Person'
e. OrderDate
f. Amount of Product quantity purchased
*/
SELECT
	soh.SalesOrderID
	, CONCAT(cp.FirstName, ' ', cp.LastName) as CustomerName
	, CASE WHEN cp.PersonType = 'IN' THEN 'Individual Customer'
		   WHEN cp.PersonType = 'SC' THEN 'Store Contact'
		   ELSE NULL END as PersonType
	, CASE WHEN CONCAT(sp.FirstName, ' ', sp.LastName) = ' ' THEN 'No sales person'
		   ELSE CONCAT(sp.FirstName, ' ', sp.LastName) END as SalesPerson
	, OrderDate
	, SUM(OrderQty) as ProductQty
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Sales.Customer c on c.CustomerID = soh.CustomerID
INNER JOIN Person.Person cp on cp.BusinessEntityID = c.PersonID
LEFT JOIN Person.Person sp on sp.BusinessEntityID = soh.SalesPersonID
GROUP BY 
	soh.SalesOrderID
	, CONCAT(cp.FirstName, ' ', cp.LastName)
	, CONCAT(sp.FirstName, ' ', sp.LastName)
	, cp.PersonType
	, OrderDate

/*
Question 42:

Using the results from Question 41 (see below) we are going to update the comment column in SalesOrderHeader.
The column is currently null. We want the comment in SalesOrderHeader to say:

	"[CustomerName] is a(n) [PersonType] and purchased [OrderQty] Product(s) from [SalesPersonName] on [OrderDate]."

a. Using the column elements From Question 41 build a CTE (common table expression) that includes two columns - SalesOrderID and Comment.
   Here is an example for Customer (BusinessEntityID) 49123:

	"Michael Allen is a(n) Store Contact and purchased 72 Product(s) from Jillian Carson on 12/31/2012"

b. Update SalesOrderHeader.Comment using the CTE from part a.
   Remember there are 31,465 unique SalesOrderID's.

Hint:
a. You can either use Concat or '+' to make the comment/sentence.
   Use cast or convert for Sum(OrderQty) and OrderDate
*/
-- a.
SELECT * FROM Sales.SalesOrderHeader soh WHERE soh.Comment IS NOT NULL;


-- result query
WITH CTE as (
	SELECT
		soh.SalesOrderID
		, (CONCAT(cp.FirstName, ' ', cp.LastName)
		+' is an(n) '
		+ CASE WHEN cp.PersonType = 'IN' THEN 'Individual Customer'
			   WHEN cp.PersonType = 'SC' THEN 'Store Contact'
			   ELSE NULL END
		+' and purchased '
		+ CAST(SUM(OrderQty) AS varchar)
		+' product(s) from '
		+ CASE WHEN CONCAT(sp.FirstName, ' ', sp.LastName) = ' ' THEN 'No sales person'
			   ELSE CONCAT(sp.FirstName, ' ', sp.LastName) END
		+' on '
		+ CONVERT(varchar, soh.OrderDate, 101)) as Comment
	FROM Sales.SalesOrderHeader soh
	INNER JOIN Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
	INNER JOIN Sales.Customer c on c.CustomerID = soh.CustomerID
	INNER JOIN Person.Person cp on cp.BusinessEntityID = c.PersonID
	LEFT JOIN Person.Person sp on sp.BusinessEntityID = soh.SalesPersonID
	GROUP BY 
		soh.SalesOrderID
		, CONCAT(cp.FirstName, ' ', cp.LastName)
		, CONCAT(sp.FirstName, ' ', sp.LastName)
		, cp.PersonType
		, OrderDate
		)
UPDATE Sales.SalesOrderHeader
SET Comment = CTE.Comment
FROM Sales.SalesOrderHeader soh
INNER JOIN CTE on CTE.SalesOrderID = soh.SalesOrderID
;

-- to rollback to original comment is null
UPDATE Sales.SalesOrderHeader
SET Comment = NULL
;

/*
Question 43

a. How many Sales people are meeting their YTD Quota?
   Use an Inner query (subquery) to show a single value meeting this criteria

b. How many Sales People have YTD sales greater than the average Sales Person YTD sales.
   Also use an Inner Query to show a single value of those meeting this criteria.

	Hint:
	There are multiple ways to accomplish this question.
	The key is to find the right answer while using an inner query.
*/

--a.
SELECT COUNT(*) as CNT
FROM(
	SELECT *
	FROM Sales.SalesPerson sp
	WHERE sp.SalesYTD > sp.SalesQuota
	) a

--b.
SELECT COUNT(*) as CNT
FROM Sales.SalesPerson sp
WHERE sp.SalesYTD >
	(
	SELECT AVG(SalesYTD)
	FROM Sales.SalesPerson sp
	) 
