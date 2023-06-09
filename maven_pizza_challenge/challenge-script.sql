/*
For the Maven Pizza Challenge, you’ll be playing the role of a BI Consultant hired by Plato's Pizza, 
a Greek-inspired pizza place in New Jersey. You've been hired to help the restaurant use data to improve operations, 
and just received the following note:

	## Welcome aboard, we're glad you're here to help! ##

	Things are going OK here at Plato's, but there's room for improvement. 
	We've been collecting transactional data for the past year, but really haven't been able to put it to good use. 
	Hoping you can analyze the data and put together a report to help us find opportunities to drive more sales and work more efficiently.

	Here are some questions that we'd like to be able to answer:

		a. What days and times do we tend to be busiest?
		b. How many pizzas are we making during peak periods?
		c. What are our best and worst selling pizzas?
		d. What's our average order value?

	That's all I can think of for now, but if you have any other ideas I'd love to hear them – you're the expert!
	
## About the dataset

    - This dataset contains 4 tables in CSV format
    - The Orders table contains the date & time that all 5,238 table orders were placed
    - The Order Details table contains the different pizzas served with each order in the Orders table, and their quantities
    - The Pizzas table contains the size and price for each distinct pizza in the Order Details table, as well as its broader pizza type
    - The Pizza Types table contains details on the pizza types in the Pizzas table, including their name as it appears on the menu, 
	  the category it falls under, and its list of ingredients

*/

-- ## THIS IS MY SOLUTION TO THIS CHALLENGE ## --

-- The database was created within the PgAdmin 4 interface, but it can also be created as a query

/*

	CREATE DATABASE	maven_pizza_challenge;

*/

-- First step is to create the database and import data about Plato's from provided CSV files
-- Orders table:
CREATE TABLE orders (
	order_id SERIAL PRIMARY KEY
	, order_date DATE NOT NULL
	, order_time TIME NOT NULL
);

COPY orders FROM 'C:\file_path\orders.csv'
CSV header;

SELECT * FROM orders;

-- Order details table:
CREATE TABLE order_details (
	order_details_id SERIAL PRIMARY KEY
	, order_id SERIAL NOT NULL
	, pizza_id VARCHAR NOT NULL
	, quantity INT NOT NULL
);


COPY order_details FROM 'C:\file_path\order_details.csv'
CSV header;

SELECT * FROM order_details;

-- Pizza types table:
CREATE TABLE pizza_types (
	pizza_type_id VARCHAR
	, name VARCHAR
	, category VARCHAR
	, ingredients TEXT
);

COPY pizza_types FROM 'C:\file_path\pizza_types.csv'
CSV header encoding 'windows-1251';
-- without encoding part there occured an error: invalid byte sequence for encoding "UTF8": 0xc92c

SELECT * FROM pizza_types;

-- Pizzas table
CREATE TABLE pizzas (
	pizza_id VARCHAR NOT NULL
	, pizza_type_id VARCHAR
	, size VARCHAR
	, price NUMERIC
);

COPY pizzas FROM 'C:\file_path\pizzas.csv'
CSV header;

SELECT * FROM pizzas;

-- Selecting distinct years in the table
SELECT
	DATE_PART('year', order_date::date) AS year
	, COUNT(*)
FROM orders
GROUP BY year
;
-- the data spans only one year


-- ## What are our best and worst selling pizzas? ## -- 
-- best-selling pizzas
SELECT
	pizza_id
	, COUNT(quantity) AS quantity
FROM order_details
GROUP BY pizza_id
ORDER BY quantity DESC, pizza_id
;
/*
	top 10 pizzas at Plato's
	"big_meat_s"	1811
	"thai_ckn_l"	1365
	"five_cheese_l"	1359
	"four_cheese_l"	1273
	"classic_dlx_m"	1159
	"spicy_ital_l"	1088
	"hawaiian_s"	1001
	"southw_ckn_l"	993
	"bbq_ckn_l"		967
	"bbq_ckn_m"		926
*/

-- least-selling pizzas
SELECT
	pizza_id
	, COUNT(quantity) AS quantity
FROM order_details
GROUP BY pizza_id
ORDER BY quantity ASC, pizza_id
;
/*
	top 10 least popular pizzas at Plato's
	"the_greek_xxl"		28
	"green_garden_l"	94
	"ckn_alfredo_s"		96
	"calabrese_s"		99
	"mexicana_s"		160
	"ckn_alfredo_l"		187
	"ital_veggie_l"		190
	"ital_supr_s"		194
	"the_greek_l"		255
	"spinach_supr_m"	266
*/

-- calculating total number of pizzas sold
SELECT
	DISTINCT COUNT(order_id)
FROM order_details
;
-- Plato's has sold 48620 pizzas


-- ## TOP 5 Pizzas with most revenue based on orders table ## --
SELECT
	pt.name
	, '$ ' || SUM(p.price) AS total_revenue
FROM orders o
	JOIN order_details od
		ON o.order_id = od.order_id
	JOIN pizzas p
		ON p.pizza_id = od.pizza_id
	JOIN pizza_types pt
		ON pt.pizza_type_id = p.pizza_type_id
GROUP BY
	pt.name, pt.category
ORDER BY total_revenue DESC
LIMIT 5;

/*
	"The Thai Chicken Pizza"		"$ 42332.25"
	"The Barbecue Chicken Pizza"	"$ 41683.00"
	"The California Chicken Pizza"	"$ 40166.50"
	"The Classic Deluxe Pizza"		"$ 37631.5"
	"The Spicy Italian Pizza"		"$ 34163.50"
*/

-- ## % for each category by quantity order ## --
SELECT
	COUNT(CASE WHEN pt.category = 'Classic' THEN od.quantity ELSE NULL END) AS classic
	, COUNT(CASE WHEN pt.category = 'Supreme' THEN od.quantity ELSE NULL END) AS supreme
	, COUNT(CASE WHEN pt.category = 'Chicken' THEN od.quantity ELSE NULL END) AS chicken
	, COUNT(CASE WHEN pt.category = 'Veggie' THEN od.quantity ELSE NULL END) AS veggie
FROM orders o
	JOIN order_details od
		ON o.order_id = od.order_id
	JOIN pizzas p
		ON p.pizza_id = od.pizza_id
	JOIN pizza_types pt
		ON pt.pizza_type_id = p.pizza_type_id
;
-- classic pizzas seem to be the most popular, whereas chicken pizzas get the least love from customers

-- ## Checking for busiest months ## --
SELECT
	DATE_PART('month', order_date::date) AS month
	, SUM(od.quantity) AS quantity
FROM orders o 
	JOIN order_details od
		ON o.order_id = od.order_id
GROUP BY month
ORDER BY quantity DESC
;
/*
	7th, 5th and 11th months are the busiest.
	10th, 9th and 12th are the least busy
	overall, the spread of orders is rather even:
	between the most and least busy month there's a difference of only 446 orders
*/



/*
	CODING ASSUMPTIONS:
	
	In order to achieve the following results, as far as my understanding
	of querying techniques goes, there are few possible ways to go.
	
	One of them would be to use CREATE TABLE based on joins and casts
	and then query newly created table in separate queries. This, however,
	is not a very optimal solution, as it creates a separate data object
	(locally or in cloud) and increases the transaction costs within a database.
	The other reason, is that CREATE TABLE would create a snapshot of the data
	as is, at the moment of creation. This means, that if the data changes, 
	the table is not be updated automatically. 
	
	Other solution would be to use WITH statement and create a temporaray table.
	This way, a separate data object is not created, lowering the storage cost, 
	but on the other hand, it is focused on a single query. 
	
	The most optimal solution, in my opinion, would be to create a MATERIALIZED VIEW 
	as it provides an opportunity for reusability of the code and is more dynamic 
	in contrast to the two aforementioned solutions. 
	
	If the data is updated REFRESH MATERIALIZED VIEW command comes in very handy.
	
*/

-- ## Average Order value ## --

CREATE MATERIALIZED VIEW mv_order_values AS (
	SELECT
		od.order_id
		, SUM(od.quantity * p.price) AS order_value
	FROM order_details od
		JOIN pizzas p
			ON p.pizza_id = od.pizza_id
	GROUP BY od.order_id
	ORDER BY order_value DESC
)
;

-- REFRESH MATERAILIZED VIEW mv_order_values

SELECT
	ROUND(AVG(order_value), 2)
FROM mv_order_values
;

-- average order value is 38.31


-- ## Busiest day of the week ## --

CREATE MATERIALIZED VIEW mv_number_of_order_by_weekdays AS (	
	SELECT
		COUNT(DISTINCT od.order_id) AS number_of_orders
		, o.order_date
		, EXTRACT(isodow FROM order_date) AS no_of_weekday
	FROM orders o
		FULL JOIN order_details od
			ON od.order_id = o.order_id
	GROUP BY o.order_date
	)
;

-- REFRESH MATERAILIZED VIEW mv_number_of_order_by_weekdays

SELECT 
	SUM(number_of_orders) total_orders_on_weekday
	, CASE
		WHEN no_of_weekday = 1 THEN 'Monday'
		WHEN no_of_weekday = 2 THEN 'Tuesday'
		WHEN no_of_weekday = 3 THEN 'Wednsday'
		WHEN no_of_weekday = 4 THEN 'Thursday'
		WHEN no_of_weekday = 5 THEN 'Friday'
		WHEN no_of_weekday = 6 THEN 'Saturday'
		ELSE 'Sunday'
	  END day_of_the_week
FROM mv_number_of_order_by_weekdays
GROUP BY day_of_the_week
ORDER BY total_orders_on_weekday DESC
;
-- Top busiest days are Friday, Thursday and Saturday

-- ## Busiest time of the week ## --
CREATE MATERIALIZED VIEW mv_orders_qty_time AS (
	SELECT
		o.order_id
		, o.order_date
		, od.order_details_id
		, od.pizza_id
		, od.quantity
		, EXTRACT(isodow FROM order_date) AS no_of_weekday
		, CASE
			WHEN order_time BETWEEN '07:00:00' AND '11:59:59' THEN 'Morning'
			WHEN order_time BETWEEN '12:00:00' AND '14:59:59' THEN 'Afternoon'
			WHEN order_time BETWEEN '15:00:00' AND '17:59:59' THEN 'Late afternoon'
			WHEN order_time BETWEEN '18:00:00' AND '21:59:59' THEN 'Evening'
			ELSE 'Night'
		  END part_of_day
	FROM orders o
		JOIN order_details od 
			ON od.order_id = o.order_id
)
;

-- REFRESH MATERAILIZED VIEW mv_orders_qty_time

/*
Overall Saturday and Friday evenings are the busiest times of day + weekdays
when Plato's makes 3051 and 3003 pizzas respectively.

Least busy are Monday and Thursday nights with just 116 orders each.
*/