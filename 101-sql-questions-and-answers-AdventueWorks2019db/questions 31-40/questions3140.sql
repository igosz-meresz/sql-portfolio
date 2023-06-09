USE AdventureWorks2019;

/*
Question 31:

Ken Sánchez, the CEO of AdventureWorks, has recently changed his email address.

a. What is Ken's current email address?
b. Update his email address to 'Ken.Sánchez@adventure-works.com'
*/

--a.
SELECT 
  e.BusinessEntityID, 
  e.JobTitle, 
  p.FirstName, 
  p.LastName, 
  ea.EmailAddress 
FROM 
  HumanResources.Employee e 
  JOIN Person.Person p on e.BusinessEntityID = p.BusinessEntityID 
  JOIN Person.EmailAddress ea on p.BusinessEntityID = ea.BusinessEntityID 
WHERE 
  e.BusinessEntityID = 1


--b.
UPDATE 
  ea 
SET 
  ea.EmailAddress = 'Ken.Sánchez@adventure-works.com' 
FROM 
  Person.EmailAddress ea 
  JOIN Person.Person p ON p.BusinessEntityID = ea.BusinessEntityID 
  JOIN HumanResources.Employee e ON e.BusinessEntityID = p.BusinessEntityID 
WHERE 
  e.BusinessEntityID = 1;


/*
Question 32:

As we learned in Question 31 there are two individuals in the AdventureWorks Database named Ken Sánchez.
One is the CEO of the Company the other is a retail customer. Lets assume for this question that you used the following script to update the email address:

            Update Person.EmailAddress
    	Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
    	Where p.FirstName ='Ken'
    	  and p.LastName = 'Sánchez'

The script above is not correct and would update both records.
One of which is not the Ken Sánchez we are wanting to update. In this question we are going to set Ken's (the CEO)
email back to the original email (assuming it has been updated from question 31). Then we are going to use 
BEGIN TRANSACTION, ROLLBACK, and COMMIT to fix/correct a mistake.


a. Update Ken's Email Address to the orginial address using the script below:

            Update Person.EmailAddress
    	Set EmailAddress = 'ken0@adventure-works.com'
    	Where BusinessEntityID = 1

b. Check the number of open transactions by running: Select @@TranCount
c. Start the transaction with the BEGIN TRAN statement. You can use BEGIN TRANSACTION or BEGIN TRAN. Then check the number of open transactions again.
d. Run our incorrect update statement

            Update Person.EmailAddress
    	Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
    	From Person.EmailAddress ea
    	    Inner Join Person.Person p on p.BusinessEntityID = ea.BusinessEntityID
    	Where p.FirstName ='Ken'
    	  and p.LastName = 'Sánchez'

e. Correct the mistake/error by running the ROLLBACK statement
f. Check to see if the mistake has been fixed.
g. Start the transaction, run the correct update statement, COMMIT the transaction
h. Question 33 we will automate whether the Transaction commits or rollsback.

If you need to update both records to the original email address then run the two scripts below.

        Update Person.EmailAddress
    	Set EmailAddress = 'ken0@adventure-works.com'
    	Where BusinessEntityID = 1
     
        Update Person.EmailAddress
    	Set EmailAddress = 'ken3@adventure-works.com'
    	Where BusinessEntityID = 1726
*/
--a.
Update 
  Person.EmailAddress 
Set 
  EmailAddress = 'ken0@adventure-works.com' 
Where 
  BusinessEntityID = 1 
Select 
  * 
From 
  Person.EmailAddress 
Where 
  EmailAddress = 'Ken.Sánchez@adventure-works.com' --b. 
Select 
  @@TranCount as OpenTransactions --c. 
  BEGIN TRAN --d. 
Update 
  Person.EmailAddress 
Set 
  EmailAddress = 'Ken.Sánchez@adventure-works.com' 
From 
  Person.EmailAddress ea 
  Inner Join Person.Person p on p.BusinessEntityID = ea.BusinessEntityID 
Where 
  p.FirstName = 'Ken' 
  and p.LastName = 'Sánchez' --e. 
  ROLLBACK --f. 
Select 
  * 
From 
  Person.EmailAddress 
Where 
  EmailAddress = 'Ken.Sánchez@adventure-works.com' --g. 
  BEGIN TRAN 
Update 
  Person.EmailAddress 
Set 
  EmailAddress = 'Ken.Sánchez@adventure-works.com' 
Where 
  BusinessEntityID = 1 COMMIT


/*
Question 33:
Complete questions 31 and 32 before attempting this question.

Before starting this question be sure the email address for both Ken Sánchez's
are updated to their original emails. Run the statements below to be sure:

        Update Person.EmailAddress
    	Set EmailAddress = 'ken0@adventure-works.com'
    	Where BusinessEntityID = 1
     
    	Update Person.EmailAddress
    	Set EmailAddress = 'ken3@adventure-works.com'
    	Where BusinessEntityID = 1726

In Question 32 we used BEGIN TRAN, ROLLBACK, and COMMIT to be sure that our updates work properly.
Write a script that will commit if the update is correct. If the update is not correct then rollback.
For example, If we know how many rows need to be updated then we can use a @@ROWCOUNT
and if that number doesn't meet the condition then rollsback. If it does meet the condition then it commits.

Use the same update statement used in Question 32 (see below):

        Update Person.EmailAddress
    	Set EmailAddress = 'Ken.Sánchez@adventure-works.com'
    	Where BusinessEntityID = 1 

**There are many ways to accomplish this. Again, find a solution that works for you.**

Hint:
1. Begin Tran
2. Update Statement
3. If Condition
4. Rollback
5. Else
6. Commit
*/
BEGIN TRANSACTION 
UPDATE 
  Person.EmailAddress 
SET 
  EmailAddress = 'Ken.Sánchez@adventure-works.com' 
WHERE 
  BusinessEntityID = 1 IF @@ROWCOUNT = 1 BEGIN COMMIT TRANSACTION 
SELECT 
  'Update successful - changes committed' END ELSE BEGIN ROLLBACK TRANSACTION 
SELECT 
  'Update failed - changes rolled back' END --select * from Person.EmailAddress;
  -- SCALABLE SOLUTION 
  DECLARE @RowCNT INT = (
    SELECT 
      COUNT(*) 
    FROM 
      Person.EmailAddress 
    WHERE 
      BusinessEntityID = 1
  ) BEGIN TRANSACTION 
UPDATE 
  Person.EmailAddress 
SET 
  EmailAddress = 'Ken.Sánchez@adventure-works.com' --WHERE BusinessEntityID = 1
  IF @@ROWCOUNT = @RowCNT COMMIT ELSE ROLLBACK


/*
Question 34:

a. Using the RANK function rank the employees in the Employee table by the hiredate. Label the column as 'Seniority'
b. Assuming Today is March 3, 2014, add 3 columns for the number of days, months, and years the employee has been employed. 

Hint:
Rank() Over (Order by ColumnName asc/desc) 
*/
--a.
SELECT 
  e.BusinessEntityID, 
  e.HireDate, 
  RANK() OVER(
    ORDER BY 
      e.HireDate
  ) as Seniority 
FROM 
  HumanResources.Employee e;
--b.
-- DECLARE @CurrentDate date = '2014-03-03'
-- to pull dinamically the current date:
-- DECLARE @CurrentDate date = GETDATE()
SELECT 
  e.BusinessEntityID, 
  e.HireDate, 
  RANK() OVER(
    ORDER BY 
      e.HireDate
  ) as Seniority, 
  DATEDIFF(day, e.HireDate, '2014-03-03') as DaysEmployed, 
  DATEDIFF(MONTH, e.HireDate, '2014-03-03') as MonthsEmployed, 
  DATEDIFF(YEAR, e.HireDate, '2014-03-03') as YearEmployed 
FROM 
  HumanResources.Employee e;

/*
Question 35:

a. Using a Select Into Statement put this table into a Temporary Table. Name the table '#Temp1'
b. Run this statement:

    Select * 
    From #Temp1
    Where BusinessEntityID in ('288','286')

Notice that these two Employees have worked for AdventureWorks for 10 months; however,
the YearsEmployed says "1." The DateDiff Function I used in our statement above does simple math:(2014 - 2013 = 1).

Update the YearsEmployed to "0" for these two Employees.

c. Using the Temp table, how many employees have worked for AdventureWorks over 5 years and 6 months?
d. Create a YearsEmployed Grouping like below:

    Employed Less Than 1 Year
    Employed 1-3 Years
    Employed 4-6
    Employed Over 6 Years

Show a count of Employees in each group

e. Show the average VacationHours and SickLeaveHours by the YearsEmployed Group. Which Group has the highest average Vacation and SickLeave Hours?

Hint:
a.

    Select *
    Into NewTablename
    From TableName

c.
    Case When 'condition' then 'value'
    		      Else 'value'
    		      End
*/
--a.
SELECT 
  RANK() OVER (
    ORDER BY 
      HireDate ASC
  ) AS 'Seniority', 
  DATEDIFF(DAY, HireDate, '2014-03-03') AS 'DaysEmployed', 
  DATEDIFF(MONTH, HireDate, '2014-03-03') AS 'MonthsEmployed', 
  DATEDIFF(YEAR, HireDate, '2014-03-03') AS 'YearsEmployed', 
  * INTO #Temp1
FROM 
  HumanResources.Employee;
--b.
Select 
  * 
From 
  #Temp1
Where 
  BusinessEntityID in ('288', '286');
UPDATE 
  #Temp1
SET 
  YearsEmployed = 0 
WHERE 
  BusinessEntityID in (286, 288);
--c.
SELECT 
  COUNT(*) 
FROM 
  #Temp1
WHERE 
  MonthsEmployed >= 66;
--d.
SELECT 
  CASE WHEN YearsEmployed = 0 THEN 'Employed Less Than 1 Year' WHEN YearsEmployed BETWEEN 1 
  AND 3 THEN 'Employed 1-3 Years' WHEN YearsEmployed BETWEEN 4 
  AND 6 THEN 'Employed 4-6' ELSE 'Employed Over 6 Years' END AS 'Category', 
  COUNT(*) as empCNT 
FROM 
  #Temp1
GROUP BY 
  CASE WHEN YearsEmployed = 0 THEN 'Employed Less Than 1 Year' WHEN YearsEmployed BETWEEN 1 
  AND 3 THEN 'Employed 1-3 Years' WHEN YearsEmployed BETWEEN 4 
  AND 6 THEN 'Employed 4-6' ELSE 'Employed Over 6 Years' END;

--e.
SELECT 
  CASE WHEN YearsEmployed = 0 THEN 'Employed Less Than 1 Year' WHEN YearsEmployed BETWEEN 1 
  AND 3 THEN 'Employed 1-3 Years' WHEN YearsEmployed BETWEEN 4 
  AND 6 THEN 'Employed 4-6' ELSE 'Employed Over 6 Years' END AS 'Category', 
  COUNT(*) as empCNT, 
  AVG(VacationHours) as VacationHrsAVG, 
  AVG(SickLeaveHours) as SickAVG 
FROM 
  #Temp1
GROUP BY 
  CASE WHEN YearsEmployed = 0 THEN 'Employed Less Than 1 Year' WHEN YearsEmployed BETWEEN 1 
  AND 3 THEN 'Employed 1-3 Years' WHEN YearsEmployed BETWEEN 4 
  AND 6 THEN 'Employed 4-6' ELSE 'Employed Over 6 Years' END;

/*
Question 36:

AdventureWorks leadership has asked you to put together a report. Follow the steps below to build the report.

a. Pull a distinct list of every region. Use the SalesTerritory as the region.
b. Add the Sum(TotalDue) to the list of regions
c. Add each customer name. Concatenate First and Last Names
d. Using ROW_NUMBER and a partition rank each customer by region. 
   For example, Australia is a region and we want to rank each customer by the Sum(TotalDue).  

Hint:
ROW_NUMBER() Over(Partition by ColumnName Order by Value desc/asc)
*/
SELECT 
  st.Name as RegionName, 
  FORMAT(
    SUM(TotalDue), 
    'C1'
  ) as SumTotalDue, 
  SUM(TotalDue) as Sort, 
  CONCAT(p.FirstName, ' ', p.LastName) AS FirstLastName, 
  ROW_NUMBER() OVER(
    PARTITION BY st.Name 
    ORDER BY 
      SUM(TotalDue) desc
  ) as RankPerTerritory 
FROM 
  Sales.SalesTerritory st 
  JOIN Sales.SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID 
  JOIN Sales.Customer c on c.CustomerID = soh.CustomerID 
  JOIN Person.Person p on c.PersonID = p.BusinessEntityID 
GROUP BY 
  st.Name, 
  CONCAT(p.FirstName, ' ', p.LastName) 
ORDER BY 
  5 asc;

/*
Question 37:

a. Limit the results in question 36 to only show the top 25 customers in  each region.
   There are 10 regions so you should have 250 rows.
b. What is the average TotalDue per Region? Leave the top 25 filter 
*/
--a.
WITH cte AS (
  SELECT 
    st.Name as RegionName, 
    FORMAT(
      SUM(TotalDue), 
      'C1'
    ) as SumTotalDue, 
    SUM(TotalDue) as Sort, 
    CONCAT(p.FirstName, ' ', p.LastName) AS FirstLastName, 
    ROW_NUMBER() OVER(
      PARTITION BY st.Name 
      ORDER BY 
        SUM(TotalDue) desc
    ) as RankPerTerritory 
  FROM 
    Sales.SalesTerritory st 
    JOIN Sales.SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID 
    JOIN Sales.Customer c on c.CustomerID = soh.CustomerID 
    JOIN Person.Person p on c.PersonID = p.BusinessEntityID 
  GROUP BY 
    st.Name, 
    CONCAT(p.FirstName, ' ', p.LastName)
) 
SELECT 
  * 
FROM 
  cte 
WHERE 
  RankPerTerritory <= 25 
ORDER BY 
  RegionName, 
  Sort DESC;
--b.
WITH CTE AS (
  SELECT 
    st.Name as RegionName, 
    FORMAT(
      SUM(TotalDue), 
      'C1'
    ) as SumTotalDue, 
    SUM(TotalDue) as Sort, 
    CONCAT(p.FirstName, ' ', p.LastName) AS FirstLastName, 
    ROW_NUMBER() OVER(
      PARTITION BY st.Name 
      ORDER BY 
        SUM(TotalDue) DESC
    ) as RankPerTerritory 
  FROM 
    Sales.SalesTerritory st 
    JOIN Sales.SalesOrderHeader soh on st.TerritoryID = soh.TerritoryID 
    JOIN Sales.Customer c on c.CustomerID = soh.CustomerID 
    JOIN Person.Person p on c.PersonID = p.BusinessEntityID 
  GROUP BY 
    st.Name, 
    CONCAT(p.FirstName, ' ', p.LastName)
) 
SELECT 
  RegionName, 
  AVG(Sort) AS AverageTotalDue 
FROM 
  CTE 
WHERE 
  RankPerTerritory <= 25 
GROUP BY 
  RegionName 
ORDER BY 
  RegionName ASC;


/*
Question 38:

Due to an increase in shipping cost you've been asked to pull a few figures
related to the freight column in Sales.SalesOrderHeader

a. How much has AdventureWorks spent on freight in totality?
b. Show how much has been spent on freight by year (ShipDate)
c. Add the average freight per SalesOrderID
d. Add a Cumulative/Running Total sum

Hint:
d. Use the Over clause and an Inner Query (subquery)
*/
--a.
SELECT 
  FORMAT(
    SUM(soh.Freight), 
    'C0'
  ) as totalFreight 
FROM 
  Sales.SalesOrderHeader soh;
--b.
SELECT 
  FORMAT(
    SUM(soh.Freight), 
    'C0'
  ) as totalFreight, 
  DATEPART(year, soh.ShipDate) as yearShipDate 
FROM 
  Sales.SalesOrderHeader soh 
GROUP BY 
  DATEPART(year, soh.ShipDate) 
ORDER BY 
  2 DESC;
--c.
SELECT 
  DATEPART(year, soh.ShipDate) as yearShipDate, 
  FORMAT(
    SUM(soh.Freight), 
    'C0'
  ) as totalFreight, 
  FORMAT(
    AVG(soh.Freight), 
    'C0'
  ) as avgFreightPerOrder 
FROM 
  Sales.SalesOrderHeader soh 
GROUP BY 
  DATEPART(year, soh.ShipDate);
--d.
SELECT 
  *, 
  FORMAT(
    SUM(totalFreight) OVER(
      ORDER BY 
        yearShipDate
    ), 
    'C0'
  ) as runningTotal 
FROM 
  (
    SELECT 
      DATEPART(year, soh.ShipDate) as yearShipDate, 
      SUM(soh.Freight) as totalFreight, 
      AVG(soh.Freight) as avgFreightPerOrder 
    FROM 
      Sales.SalesOrderHeader soh 
    GROUP BY 
      DATEPART(year, soh.ShipDate)
  ) A;


/*
Question 39:

a. How many months were completed in each Year. Obviously a full year has 12 months, but some of these years
   could be partial. Leave all of the columns, just add the count of completed months in each Year.
b. Calculate the average Total Freight by completed month

Hint:
a. You will need to edit the Inner Query
*/

SELECT 
  *, 
  FORMAT(
    SUM(totalFreight) OVER(
      ORDER BY 
        yearShipDate
    ), 
    'C0'
  ) as runningTotal 
FROM 
  (
    SELECT 
      YEAR(soh.ShipDate) as yearShipDate, 
      SUM(soh.Freight) as totalFreight, 
      AVG(soh.Freight) as avgFreightPerOrder, 
      COUNT(
        DISTINCT MONTH(soh.ShipDate)
      ) as CompleteMonths 
    FROM 
      Sales.SalesOrderHeader soh 
    GROUP BY 
      YEAR(soh.ShipDate)
  ) A;
--b.
SELECT 
  *, 
  FORMAT(
    SUM(totalFreight) OVER(
      ORDER BY 
        yearShipDate
    ), 
    'C0'
  ) as runningTotal, 
  FORMAT(
    totalFreight / CompleteMonths, 'C0'
  ) as avgFreightPerMonth 
FROM 
  (
    SELECT 
      YEAR(soh.ShipDate) as yearShipDate, 
      SUM(soh.Freight) as totalFreight, 
      AVG(soh.Freight) as avgFreightPerOrder, 
      COUNT(
        DISTINCT MONTH(soh.ShipDate)
      ) as CompleteMonths 
    FROM 
      Sales.SalesOrderHeader soh 
    GROUP BY 
      YEAR(soh.ShipDate)
  ) A;


/*
Question 40:

In Question 38 and 39 we analyzed the Freight costs by Year.
In Question 39 we adjusted some of those calculations by accounting for incomplete years.
In this question we are going to analyze freight costs at the Monthly level.

a. Start by writing a query that shows freight costs by Month (use ShipDate).
   Be sure to include year. Include two Month columns one where month is 1-12
   and another with the full month written out (i.e. January)
b. Add an average
c. Add a cumulative sum start with June 2011 and go to July 2014.
   July 2014 should reconile to the Freight in totality ($3,183,430)
d. Add a yearly cumulative Sum, which means every January will start over. 

Hint:
a. Use the DateName function
c. Use the Over clause and an Inner Query (subquery)
d. Add a partition to the Over Clause
*/
--a, b, c
SELECT 
  *, 
  FORMAT(
    SUM(totalFreight) OVER (
      ORDER BY 
        yearShipDate, 
        monthShipDate
    ), 
    'C0'
  ) as cumSum 
FROM 
  (
    SELECT 
      DATEPART(YEAR, soh.ShipDate) as yearShipDate, 
      DATEPART(month, soh.ShipDate) as monthShipDate, 
      DATENAME(MONTH, soh.ShipDate) as monthShipDateName, 
      SUM(soh.Freight) as totalFreight, 
      AVG(soh.Freight) as avgFreight 
    FROM 
      Sales.SalesOrderHeader soh 
    WHERE 
      soh.ShipDate >= '2011-06-01' 
    GROUP BY 
      DATEPART(YEAR, soh.ShipDate), 
      DATEPART(month, soh.ShipDate), 
      DATENAME(MONTH, soh.ShipDate)
  ) A 
ORDER BY 
  yearShipDate, 
  monthShipDate;
--d
SELECT 
  *, 
  FORMAT(
    SUM(totalFreight) OVER (
      ORDER BY 
        yearShipDate, 
        monthShipDate
    ), 
    'C0'
  ) as cumSum, 
  FORMAT(
    SUM(totalFreight) OVER (
      PARTITION BY yearShipDate 
      ORDER BY 
        yearShipDate, 
        monthShipDate
    ), 
    'C0'
  ) as ytdRunningTotal 
FROM 
  (
    SELECT 
      DATEPART(YEAR, soh.ShipDate) as yearShipDate, 
      DATEPART(month, soh.ShipDate) as monthShipDate, 
      DATENAME(MONTH, soh.ShipDate) as monthShipDateName, 
      SUM(soh.Freight) as totalFreight, 
      AVG(soh.Freight) as avgFreight 
    FROM 
      Sales.SalesOrderHeader soh 
    WHERE 
      soh.ShipDate >= '2011-06-01' 
    GROUP BY 
      DATEPART(YEAR, soh.ShipDate), 
      DATEPART(month, soh.ShipDate), 
      DATENAME(MONTH, soh.ShipDate)
  ) A 
ORDER BY 
  yearShipDate, 
  monthShipDate;
