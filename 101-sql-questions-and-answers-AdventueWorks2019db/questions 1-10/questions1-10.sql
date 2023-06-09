--Question 1:
--Write a SQL Statement that will give you a count of each object type in the AdventureWorks database. Order by count descending.

select 
  type_desc, 
  count(*) as cnt 
from 
  AdventureWorks2019.sys.objects so 
group by 
  type_desc 
order by 
  cnt desc;


/*Question 2:

a. Write a SQL Statement that will show a count of 
	schemas, tables, and columns (do not include views) in the AdventureWorks database.
b. Write a similar statement as part a but list each 
	schema, table, and column (do not include views). This table can be used later in the course.
*/

--a
SELECT 
  count(DISTINCT ss.name) as schemas_cnt, 
  count(DISTINCT st.name) as table_cnt, 
  count(sc.name) as col_cnt 
FROM 
  sys.tables st 
  JOIN sys.schemas ss ON ss.schema_id = st.schema_id 
  JOIN sys.columns sc ON sc.object_id = st.object_id;
SELECT 
  count(distinct TABLE_SCHEMA) as TableSchema, 
  count(distinct TABLE_NAME) as TableName, 
  count(distinct COLUMN_NAME) as ColumnName 
FROM 
  INFORMATION_SCHEMA.COLUMNS 
WHERE 
  TABLE_NAME NOT IN (
    SELECT 
      TABLE_NAME 
    FROM 
      INFORMATION_SCHEMA.views
  );
-- b
SELECT 
  ss.name as schemas_cnt, 
  st.name as table_cnt, 
  sc.name as col_cnt 
FROM 
  sys.tables st 
  JOIN sys.schemas ss ON ss.schema_id = st.schema_id 
  JOIN sys.columns sc ON sc.object_id = st.object_id;
SELECT 
  TABLE_SCHEMA as schema_nm, 
  TABLE_NAME as table_nm, 
  COLUMN_NAME as col_nm 
FROM 
  INFORMATION_SCHEMA.COLUMNS 
WHERE 
  TABLE_NAME NOT IN (
    SELECT 
      TABLE_NAME 
    FROM 
      INFORMATION_SCHEMA.views
  );


/*Question 3:

We learned in question 1 that 89 check constraints exist in the AdventureWorks Database. 
In this question we are going to determine what the check constraints are doing while creating a new database and table.

a. Create a new database called "Edited_AdventureWorks"
	(we are creating another database so we don't   overwrite or change the AdventureWorks database).
*/
CREATE DATABASE Edited_AdventureWorks;
/*  Then write a USE statement to connect to the new database. */
USE Edited_AdventureWorks;
/*
b. Using the following tables - sys.check_constraints, sys.tables, 
  and sys.columns to write a query that will give you 
  TableName, ColumnName, CheckConstraintName, and CheckConstraintDefinition */
Select 
  Distinct T.name as TableName, 
  C.name as ColumnName, 
  CC.name as CheckConstraint, 
  CC.definition as [Definition] 
from 
  AdventureWorks2019.sys.check_constraints CC 
  INNER JOIN AdventureWorks2019.sys.tables T on T.object_id = CC.parent_object_id 
  Left JOIN AdventureWorks2019.sys.columns C on C.column_id = CC.parent_column_id 
  and C.object_id = CC.parent_object_id;

/*
c. Create a table named "tbl_CheckConstraint" in the "Edited_AdventureWorks" database with the following  columns and data types:
        TableName varchar(100)
        ColumnName varchar(100)
        CheckConsraint varchar(250)
        Definition varchar(500)
        ConstraintLevel varchar(100)
*/

CREATE TABLE tbl_CheckConstraints (
  TableName VARCHAR(100), 
  ColumnName VARCHAR(100), 
  CheckConstraint VARCHAR(250), 
  [Definition] VARCHAR(500), 
  ConstraintLevel VARCHAR(100)
);


/*
d. Using the query in part b insert the data into "tbl_CheckConstraint" */
Insert Into tbl_CheckConstraints (
  TableName, ColumnName, CheckConstraint, 
  Definition
) 
Select 
  Distinct T.name as TableName, 
  C.name as ColumnName, 
  CC.name as CheckConstraint, 
  CC.definition as [Definition] 
from 
  AdventureWorks2019.sys.check_constraints CC 
  INNER JOIN AdventureWorks2019.sys.tables T on T.object_id = CC.parent_object_id 
  Left JOIN AdventureWorks2019.sys.columns C on C.column_id = CC.parent_column_id 
  and C.object_id = CC.parent_object_id;


SELECT * FROM tbl_CheckConstraints;

/*
e. Using a case statement write an update statement (update ConstraintLevel) 
	that will specify whether the constraint is assigned to the column or the table. */
Update 
  tbl_CheckConstraints 
Set 
  ConstraintLevel = Case When ColumnName is null Then 'TableLevel' Else 'ColumnLevel' End

/*
f. What does this mean?
g. Once you're done interpreting the results drop the tbl_CheckConstraint table
*/
DROP TABLE tbl_CheckConstraints;

/*
Question 4:
We learned in Question 1 that there are 71 tables in the AdventureWorks Database.
We can also see these tables in  our entity relationship diagram (ERD).
These tables are connected via primary keys and foreign keys.
For example, in the Sales.SalesOrderHeader table there  is a foreign key on the CurrencyRateID.
This Foreign key is connected to the primary key in the Sales.CurrencyRate  table.
Therefore, when we connect these two tables together we will use the CurrencyRateID from both tables.
The name of this Foreign Key in the AdventureWorks database is  "FK_SalesOrderHeader_CurrencyRate_CurrencyRateID". 
We also  know which Schema, Table, and Column join to the referenced Schema, referenced Table, and referenced column.
(See Below)

    ForeignKeyName: FK_SalesOrderHeader_CurrencyRate_CurrencyRateID

    SchemaName: Sales

    TableName: SalesOrderHeader

    ColumnName: CurrencyRateID

    ReferencedSchema: Sales

    ReferencedTable: CurrencyRate

    ReferencedColumn: CurrencyRateID 

In this question you will replicate the 7 columns above 
(ForeignKeyName, SchemaName, TableName, ColumnName,
ReferencedSchema, ReferencedTable, Referenced Column) for every Foreign Key in the AdventureWorks database.  
*/
Select 
  O.name as FK_Name, 
  S1.name as SchemaName, 
  T1.name as TableName, 
  C1.name as ColumnName, 
  S2.name as ReferencedSchemaName, 
  T2.name as ReferencedTableName, 
  C2.name as ReferencedColumnName 
From 
  sys.foreign_key_columns FKC 
  INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id 
  INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id 
  INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id 
  INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
  AND C1.object_id = T1.object_id 
  INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
  AND C2.object_id = T2.object_id 
  INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id 
  INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id;


SELECT * from sys.default_constraints dc
inner join sys.tables t on t.object_id = dc.parent_object_id;

    --a.
    Create Database Edited_AdventureWorks --if necessary--
     
    --b. 
Select 
  O.name as FK_Name, 
  S1.name as SchemaName, 
  T1.name as TableName, 
  C1.name as ColumnName, 
  S2.name as ReferencedSchemaName, 
  T2.name as ReferencedTableName, 
  C2.name as ReferencedColumnName Into Edited_AdventureWorks.dbo.Table_Relationships 
From 
  sys.foreign_key_columns FKC 
  INNER JOIN sys.objects O ON O.object_id = FKC.constraint_object_id 
  INNER JOIN sys.tables T1 ON T1.object_id = FKC.parent_object_id 
  INNER JOIN sys.tables T2 ON T2.object_id = FKC.referenced_object_id 
  INNER JOIN sys.columns C1 ON C1.column_id = parent_column_id 
  AND C1.object_id = T1.object_id 
  INNER JOIN sys.columns C2 ON C2.column_id = referenced_column_id 
  AND C2.object_id = T2.object_id 
  INNER JOIN sys.schemas S1 ON T1.schema_id = S1.schema_id 
  INNER JOIN sys.schemas S2 ON T2.schema_id = S2.schema_id

     
    --c. See Video Explanation
     
    --d. 
Select 
  FK_NAME, 
  Count(*) as CNT 
From 
  Edited_AdventureWorks.dbo.Table_Relationships 
Group by 
  FK_NAME 
Order by 
  2 desc --e. 
Select 
  Count(Distinct FK_Name) 
From 
  Edited_AdventureWorks.dbo.Table_Relationships 
Where 
  ColumnName = 'BusinessEntityID' 
  or ReferencedColumnName = 'BusinessEntityID' 
Select 
  * 
From 
  Edited_AdventureWorks.dbo.Table_Relationships 
Where 
  ColumnName = 'BusinessEntityID' 
  or ReferencedColumnName = 'BusinessEntityID'

/*
Question 7:
a. Write a script that you can use to find 
every column in the database that includes "rate" in the column name.

b. Write a script that you can use to find 
every table in the database that includes "History" in the table name. 
*/

    --a.
Select 
  t.name as TableName, 
  c.name as ColumnName 
From 
  sys.tables t 
  Inner Join sys.columns c on t.object_id = c.object_id 
Where 
  c.name like '%rate%';
--b. 
Select 
  t.name as TableName, 
  c.name as ColumnName 
From 
  sys.tables t 
  Inner Join sys.columns c on t.object_id = c.object_id 
Where 
  t.name like '%History%';
