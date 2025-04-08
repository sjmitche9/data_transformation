-- EXERCISES
-------------------------------------------------------------------------------------------

-- Exercise 1
-- Assign a 'Low', 'Medium', or 'High' price label to each product based on its unit price. 
SELECT
	productname,
	unitprice,
	CASE
		WHEN unitprice <= 20 THEN 'Low'
		WHEN unitprice > 50 THEN 'High'
		ELSE 'Medium'
	END AS price_group
FROM products;


-- Exercise 2
-- Classify customers as 'Local' or 'International' based on their country.
SELECT
	companyname,
	country,
	CASE
		WHEN country = 'Canada' THEN 'Local'
		ELSE 'International'
	END AS region
FROM customers;


-- Exercise 3
-- Assign a discount category to each order based on the average discount applied to its order details.
SELECT
	orderid,
	discount,
	AVG(discount) OVER(
		PARTITION BY orderid),
	CASE
		WHEN AVG(discount) OVER(PARTITION BY orderid) = 0 THEN 'No discount'
		WHEN AVG(discount) OVER(PARTITION BY orderid) <= 0.1 THEN 'Small discount'
		WHEN AVG(discount) OVER(PARTITION BY orderid) <= 0.2 THEN 'Medium discount'
		ELSE 'Large discount'
	END AS discount_group
FROM order_details;


-- Exercise 4
-- Convert the order date to a string.
SELECT
	orderdate,
	CAST(orderdate AS VARCHAR(10)) AS orderdate_string
-- 	orderdate::VARCHAR(10) AS orderdate_string
FROM orders;


-- Exercise 5
-- Calculate the VAT (Value Added Tax) for each product's unit price assuming a VAT rate of 20%. (HARD)
SELECT
	p.productname,
	o.unitprice,
	o.unitprice * 0.2 AS vat
FROM products p
JOIN order_details o USING (productid);


-- BONUS: Round the result to 2 decimal places.
SELECT
	p.productname,
	o.unitprice,
	ROUND(CAST(o.unitprice * 0.2 AS NUMERIC), 2) AS vat
FROM products p
JOIN order_details o USING (productid);


-- Exercise 6
-- Calculate the total price of each order, including VAT, and format the result as a string with a currency symbol. (HARD)
SELECT
	DISTINCT orderid,
	CONCAT('$', ROUND(SUM(CAST(unitprice * quantity * 1.2 AS NUMERIC)) OVER(PARTITION BY orderid), 2)) AS total_price
-- 	'$' || ROUND(SUM(CAST(unitprice * quantity * 1.2 AS NUMERIC)) OVER(PARTITION BY orderid), 2) AS total_price
FROM order_details
ORDER BY 1;


-- Exercise 7
-- Assign a row number to each product based on its unit price in ascending order.
SELECT
	productname,
	unitprice,
	ROW_NUMBER() OVER(ORDER BY unitprice)
FROM products;


-- Exercise 8
-- Rank employees by the total number of orders they have managed. (HARD)
SELECT
	DISTINCT CONCAT(firstname, ' ', lastname) AS employee,
	COUNT(o.orderid) AS num_orders_managed,
	RANK() OVER(ORDER BY COUNT(o.orderid) DESC NULLS LAST) AS employee_rank
FROM employees e
LEFT JOIN orders o USING (employeeid)
GROUP BY e.employeeid
ORDER BY num_orders_managed DESC;
-- Using an inner join will only include employees who have managed orders
-- Using a left join will include ALL employees, even ones with no orders managed
-- NULLS LAST will put all NULL values last (by default, they appear first)


-- Exercise 9
-- Assign a dense rank to customers based on the total revenue they have generated. (HARD)
SELECT
	c.companyname,
	ROUND(CAST(SUM(od.unitprice * od.quantity * (1 - od.discount)) AS NUMERIC), 2) AS total_revenue,
	DENSE_RANK() OVER(
		ORDER BY SUM(od.unitprice * od.quantity * (1 - od.discount)) DESC) AS revenue_rank
	FROM order_details od
JOIN orders o USING (orderid)
JOIN customers c USING (customerid)
GROUP BY companyname;


-- Exercise 10
-- Assign a row number to each product within its category based on its unit price in ascending order. 
SELECT
	productname,
	categoryid,
	unitprice,
	ROW_NUMBER() OVER(
		PARTITION BY categoryid
		ORDER BY unitprice) AS row_no
FROM products;