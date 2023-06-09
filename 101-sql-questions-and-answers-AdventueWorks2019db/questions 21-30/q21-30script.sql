USE AdventureWorks2019;

/*
Question 21:

AdventureWorks works with customers, employees and business partners all over the globe.
The accounting department needs to be sure they are up-to-date on Country and State tax rates.

a. Pull a list of every country and state in the database.
b. Includes tax rates.
c. There are 181 rows when looking at countries and states, but once you add tax rates the number of rows increases to 184. Why is this?
d. Which location has the highest tax rate?

Hint:
a. Start by using the StateProvince table
b. Use a left join when joining SalesTaxRate to StateProvince
c. Find the countries/states that have more than 1 tax rate
*/
--a.
SELECT 
  cr.Name as CountryName, 
  sp.Name as StateName 
FROM 
  Person.StateProvince sp 
  INNER JOIN Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode


--b.
SELECT 
  sp.Name, 
  sp.StateProvinceCode, 
  st.TaxRate 
FROM 
  Person.StateProvince sp 
  LEFT JOIN Sales.SalesTaxRate st on sp.StateProvinceID = st.StateProvinceID 
ORDER BY 
  st.TaxRate DESC;
-- countries/states with more than 1 tax rate:
SELECT 
  sp.StateProvinceID as StateRegionCode, 
  sp.Name, 
  COUNT(*) as NumberOfTaxRates 
FROM 
  Person.StateProvince sp 
  INNER JOIN Sales.SalesTaxRate st on sp.StateProvinceID = st.StateProvinceID 
GROUP BY 
  sp.StateProvinceID, 
  sp.Name 
HAVING 
  COUNT(*) > 1;


/*
Question 22

The Marketing Department has never ran ads in the United Kingdom 
and would like you pull a list of every individual customer (PersonType = IN) by country.

a. How many individual (retail) customers exist in the person table?
b. Show this breakdown by country
c. What percent of total customers reside in each country. 
	For Example,  if there are 1000 total customers and 200 live 
	in the United States then 20% of the customers live in the United States.  

	Hint
b. Be sure the total retail customers found in part a doesn't change  as you join tables.
c. Multiple ways to do this. Try using an Inner Query
*/
--a.
SELECT 
  distinct(
    COUNT(p.BusinessEntityID)
  ) as individualCustCount 
FROM 
  Person.Person p 
WHERE 
  p.PersonType = 'IN';
--b
--with temp as (
SELECT 
  count(distinct p.BusinessEntityID) as custCount, 
  cr.Name as Country 
FROM 
  Person.Person p 
  LEFT JOIN Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID 
  LEFT JOIN Person.Address a on bea.AddressID = a.AddressID 
  LEFT JOIN Person.StateProvince sp on a.StateProvinceID = sp.StateProvinceID 
  LEFT JOIN Person.CountryRegion cr on sp.CountryRegionCode = cr.CountryRegionCode 
WHERE 
  p.PersonType = 'IN' 
GROUP BY 
  cr.Name;

/*
)
SELECT
	SUM(temp.custCount)
FROM temp
-- 18484, checks out;
*/

--c.
SELECT 
  count(distinct p.BusinessEntityID) as custCount, 
  cr.Name as Country, 
  CONCAT(
    ROUND(
      (
        COUNT(DISTINCT p.BusinessEntityID) * 100.0 / t.total
      ), 
      2
    ), 
    '%'
  ) as '% of total' 
FROM 
  Person.Person p 
  LEFT JOIN Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID 
  LEFT JOIN Person.Address a on bea.AddressID = a.AddressID 
  LEFT JOIN Person.StateProvince sp on a.StateProvinceID = sp.StateProvinceID 
  LEFT JOIN Person.CountryRegion cr on sp.CountryRegionCode = cr.CountryRegionCode 
  --The CROSS JOIN is used to join the subquery result with the main query, so that the total count is available for all rows.
  CROSS 
  JOIN (
    SELECT 
      COUNT(DISTINCT p2.BusinessEntityID) as total 
    FROM 
      Person.Person p2 
    WHERE 
      p2.PersonType = 'IN'
  ) as t 
WHERE 
  p.PersonType = 'IN' 
GROUP BY 
  cr.Name, 
  t.total;


--alternatively
Select 
  cr.Name as Country, 
  Format(
    count(Distinct p.BusinessEntityID), 
    'N0'
  ) as CNT, 
  Format(
    Cast(
      count(Distinct p.BusinessEntityID) as float
    ) /(
      Select 
        count(BusinessEntityID) 
      from 
        Person.Person 
      Where 
        PersonType = 'IN'
    ), 
    'P'
  ) as '%ofTotal' 
from 
  Person.Person p 
  Inner Join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID 
  Inner Join Person.Address a on a.AddressID = bea.AddressID 
  Inner Join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID 
  Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode 
Where 
  PersonType = 'IN' 
Group by 
  cr.Name 
Order by 
  2 desc


/*
Question 23

In Question 22 I used an Inner Query as the denominator when calculating the '%ofTotal' (see below).
Take this query and replace the denomiator with a declare/local variable.
Below you will find a "Current Query" and a "Desired Query."
Write the syntax necessary to make the "Desired Query" Functional.
*/

-- current query:
Select 
  cr.Name as Country, 
  Format(
    count(Distinct p.BusinessEntityID), 
    'N0'
  ) as CNT, 
  Format(
    Cast(
      count(Distinct p.BusinessEntityID) as float
    ) / (
      Select 
        count(BusinessEntityID) 
      from 
        Person.Person 
      Where 
        PersonType = 'IN'
    ), 
    'P'
  ) as '%ofTotal' 
from 
  Person.Person p 
  Inner Join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID 
  Inner Join Person.Address a on a.AddressID = bea.AddressID 
  Inner Join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID 
  Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode 
Where 
  PersonType = 'IN' 
Group by 
  cr.Name 
Order by 
  2 desc


-- desired query:
    
-- declare and set variable @TotalRetailCustomers
-- must run all three part at the same time
DECLARE @TotalRetailCustomers INT;
SET 
  @TotalRetailCustomers = (
    Select 
      count(BusinessEntityID) 
    from 
      Person.Person 
    Where 
      PersonType = 'IN'
  );

	
Select 
  cr.Name as Country, 
  Format(
    count(Distinct p.BusinessEntityID), 
    'N0'
  ) as CNT, 
  Format(
    Cast(
      count(Distinct p.BusinessEntityID) as float
    ) / @TotalRetailCustomers, 
    'P'
  ) as '%ofTotal' 
from 
  Person.Person p 
  Inner Join Person.BusinessEntityAddress bea on bea.BusinessEntityID = p.BusinessEntityID 
  Inner Join Person.Address a on a.AddressID = bea.AddressID 
  Inner Join Person.StateProvince sp on sp.StateProvinceID = a.StateProvinceID 
  Inner Join Person.CountryRegion cr on cr.CountryRegionCode = sp.CountryRegionCode 
Where 
  PersonType = 'IN' 
Group by 
  cr.Name 
Order by 
  2 desc;


/*
Question 24
In this question use SalesOrderID '69411' to determine answer.

a. In the SalesOrderHeader what is the difference between "SubTotal" and "TotalDue"?
b. Which one of these matches the "LineTotal" in the SalesOrderDetail?
c. How is TotalDue calculated in SalesOrderHeader?
d. How is LineTotal calculated in SalesOrderDetail?

Hint
Use SalesOrderDetail to join Product and SalesOrderHeader
*/
--a, b, c.
-- SubTotal is price where tax, freight are not included
-- if you sum LineTotal for this order it will match SubTotal
SELECT 
  SubTotal, 
  TaxAmt, 
  Freight, 
  TotalDue,
  -- this is how TotalDue is calculated in SalesOrderHeader
  --, SubTotal + TaxAmt + Freight as sumOfTotal
  sod.LineTotal 
FROM 
  Sales.SalesOrderHeader soh 
  JOIN Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID 
WHERE 
  sod.SalesOrderID = 69411;

--d.
--LineTotal is per product subtotal. Computed as OrderQty * UnitPrice.

/*
Question 25

In general Gross Revenue is calculated by taking the Amount of Sales/Revenue
without removing the expenses to sell that item. Which also means that in general
Net Revenue is the Amount of Sales/Revenue after the expenses have been subtracted.

Which product has the best margins? (Highest Net Revenue)

Hint
List Price and Standard Cost in Production.Product
*/
SELECT 
  p.Name, 
  p.ProductID, 
  FORMAT(p.StandardCost, 'C0') as StandardCost, 
  FORMAT(p.ListPrice, 'C0') as ListPrice, 
  FORMAT(
    CASE WHEN p.ListPrice = 0 THEN 0 ELSE p.ListPrice / p.StandardCost END, 
    'P'
  ) as '% Margin', 
  FORMAT(
    p.ListPrice - p.StandardCost, 'C0'
  ) as '$ Margin' 
FROM 
  Production.Product p 
ORDER BY 
  '$ Margin' desc;


/*
Question 26

As we learned in Question 25, the "Mountain-100 Silver"
and the "Mountain-100 Black" bicycles have the highest margins...
meaning the ListPrice to StandardCost ratio is higher than any other product.

a. Within the Production.Product table find a identifier that groups the 8 "Mountain-100" bicycles (4 Silver and 4 Black).
b. How many special offers have been applied to these 8 bicycles? 
   When did the special offer start?
   When did the special offer end?
   What was the special offer?
c. Based on the most recent special offer start date is the product actually discontinued? Is the product still sold?
d. When was the last date the product was sold to an actual customer?

Hint
Use SpecialOfferProduct to join SpecialOffer and Product
*/

--a.
SELECT 
  * 
FROM 
  Production.Product p 
WHERE 
  p.Name LIKE '%Mountain-100%' -- is it ProductModelID = 19?
  ;
--b.
SELECT 
  so.StartDate, 
  so.EndDate, 
  so.Type, 
  so.Category, 
  so.Description, 
  so.DiscountPct, 
  COUNT(DISTINCT p.Name) as prodCNT 
FROM 
  Production.Product p 
  INNER JOIN Sales.SpecialOfferProduct sop on p.ProductID = sop.ProductID 
  INNER JOIN Sales.SpecialOffer so on sop.SpecialOfferID = so.SpecialOfferID 
WHERE 
  p.ProductModelID = 19 
GROUP BY 
  so.StartDate, 
  so.EndDate, 
  so.Type, 
  so.Category, 
  so.Description, 
  so.DiscountPct;
--c.
SELECT 
  p.Name, 
  sop.SpecialOfferID --, COUNT(DISTINCT sop.SpecialOfferID) as SpecialOfferCnt
  , 
  MIN(so.StartDate) as StartDateSO, 
  MAX(so.EndDate) as EndDateSO, 
  MIN(p.DiscontinuedDate) as DiscontinuedDate --, so.Description
FROM 
  Production.Product p 
  JOIN Sales.SpecialOfferProduct sop on p.ProductID = sop.ProductID 
  LEFT JOIN Sales.SpecialOffer so on sop.SpecialOfferID = so.SpecialOfferID 
WHERE 
  p.Name LIKE '%Mountain-100%' --and p.DiscontinuedDate IS NOT NULL
GROUP BY 
  p.Name, 
  sop.SpecialOfferID 
ORDER BY 
  StartDateSO desc;
--d.
SELECT 
  p.ProductID, 
  sop.SpecialOfferID, 
  p.Name, 
  p.ListPrice, 
  sod.UnitPrice, 
  soh.CustomerID, 
  soh.OrderDate 
FROM 
  Production.Product p 
  INNER JOIN Sales.SpecialOfferProduct sop on p.ProductID = sop.ProductID 
  INNER JOIN Sales.SalesOrderDetail sod on sop.ProductID = sod.ProductID 
  INNER JOIN Sales.SalesOrderHeader soh on sod.SalesOrderID = soh.SalesOrderID 
WHERE 
  p.Name LIKE '%Mountain-100%'


/*
Question 27

We learned in Question 26 that the 8 bicycles that fall under the 19 ProductModelID
don't have a discontinued  date. However, this model hasn't been ordered since  May 29, 2012.
The most recent purchase (any item) was June 30, 2014. Which means this product either
has been discounted and there isn't a discontinued date. Or the product is still being sold,
but hasn't been purchased in 2 years. Which is it?

Hint
Determine whether this product model is still in stock. 
*/
    
SELECT 
  p.Name, 
  SUM(i.quantity) as Inventory 
FROM 
  Production.Product p 
  INNER JOIN Production.ProductInventory I on i.ProductID = p.ProductID 
WHERE 
  ProductModelID = '19' 
GROUP BY 
  p.Name

-- it is neither discontinued nor being sold

/*
Question 28

a. Using Sales.SalesReason pull a distinct list of every sales reason.
b. Add a count of SalesOrderID's to the sales reason.
c. Which Sales Reason is most common?

Hint
A single OrderID can have zero sales reasons, a single reason or multiple reasons
*/

--a.
SELECT 
  distinct(sr.Name) 
FROM 
  Sales.SalesReason sr;
--b, c
SELECT 
  sr.Name, 
  count(soh.SalesOrderID) as salesCNT 
FROM 
  Sales.SalesReason sr 
  INNER JOIN Sales.SalesOrderHeaderSalesReason sor on sr.SalesReasonID = sor.SalesReasonID 
  INNER JOIN Sales.SalesOrderHeader soh on sor.SalesOrderID = soh.SalesOrderID 
GROUP BY 
  sr.Name 
ORDER BY 
  salesCNT desc;


/*
Based on the results in question 28, there are 27,647 rows in the SalesOrderHeaderSalesReason table.
Which means these 27,647 are assigned to a SalesReason. However, there are 31,465 unique SalesOrderIDs in the SalesOrderHeader table.
This is due to the fact that a SalesOrder can have zero, one, or multiple sales reasons listed.
For Example, SalesOrderID 44044 has "Manufacturer" and "Quality" listed as reasons why the customer purchased.
The most reasons listed for a single SalesOrderID is 3. 

Using a CTE (Common Table Expression) find the number of SalesOrderIDs that have zero, one, two, and three sales reasons.

Hint
With CTE_Name as (Statement) 
*/
WITH CTE AS (
  SELECT 
    soh.SalesOrderID, 
    COUNT(hsr.SalesOrderID) as ReasonsCNT 
  FROM 
    Sales.SalesOrderHeader soh 
    LEFT JOIN Sales.SalesOrderHeaderSalesReason hsr on hsr.SalesOrderID = soh.SalesOrderID 
    LEFT JOIN Sales.SalesReason sr on sr.SalesReasonID = hsr.SalesReasonID 
  GROUP BY 
    soh.SalesOrderID
) 
SELECT 
  ReasonsCNT, 
  COUNT(ReasonsCNT) as CntOfSalesOrderIDs 
FROM 
  CTE 
GROUP BY 
  ReasonsCNT;

/*
Question 30

Assume the sales team wants to reach out to folks who left a review (ProductReview).
Is it possible to find the customers that left a review in the Person table?
Make your best attempt at finding these customers. 
*/

Select 
  * 
From 
  Production.ProductReview 
Select 
  pr.*, 
  p.Name 
from 
  Production.ProductReview pr 
  Inner Join Production.Product p on p.ProductID = pr.ProductID 
Select 
  * 
From 
  Person.EmailAddress 
Where 
  EmailAddress in (
    Select 
      EmailAddress 
    from 
      Production.ProductReview pr
  ) 
Select 
  * 
From 
  Production.ProductReview 
Select 
  * 
From 
  Sales.SalesOrderHeader soh 
  Inner Join Person.Person p on p.BusinessEntityID = soh.CustomerID 
  Inner Join Sales.SalesOrderDetail sod on sod.SalesOrderID = soh.SalesOrderID 
  Inner Join Production.Product pr on pr.ProductID = sod.ProductID 
Where 
  FirstName like '%John%' 
  and LastName like '%Smith%' 
Select 
  * 
From 
  HumanResources.Employee 
  Inner Join Person.Person on Person.BusinessEntityID = Employee.BusinessEntityID 
Where 
  FirstName like '%Laura%' 
  and LastName like '%Norman%'
