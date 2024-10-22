-- W04L1 - Data Transformation


-- CASE
-------------------------------------------------------------------------------------------

-- Example 1
-- In the order_details table, classify each row based on their quantity:
-- 'large' (>40), 'medium' (<=40 and >20), or 'small' (<=20)
SELECT
	quantity,
	CASE
		WHEN quantity > 40 THEN 'large'
		WHEN quantity <= 20 THEN 'small'
		ELSE 'medium'
	END AS quantity_class
FROM order_details;


SELECT
	quantity,
	CASE
		WHEN quantity > 40 THEN 'large'
		WHEN quantity > 20 THEN 'medium'
		ELSE 'small'
	END AS quantity_class
FROM order_details;

-- Example 2
-- Show every row from order_details that has no discount and quantity <10 or
-- if there is a discount, the quantity must be between 10 and 20
SELECT  quantity,
	    discount
FROM order_details
WHERE
	CASE
		WHEN discount = 0 THEN quantity < 10
		ELSE quantity BETWEEN 10 AND 20
	END;


SELECT quantity, discount
FROM order_details
WHERE 
	(discount = 0 AND quantity < 10) OR 
	(discount != 0 AND quantity BETWEEN 10 AND 20);


-- CAST
-------------------------------------------------------------------------------------------

-- Example 1
-- In the orders table, convert orderdate to string
-- Try casting as VARCHAR(9)
SELECT
	orderdate,
	CAST(orderdate AS VARCHAR(10)) AS orderdate_string
	-- orderdate::VARCHAR(10) AS orderdate_string
FROM orders;


-- Example 2
-- In the products table, show unitsinstock as a percentage of the grand total unitsinstock
SELECT
	unitsinstock,
	(SELECT SUM(unitsinstock) FROM products),
	-- unitsinstock / (SELECT SUM(unitsinstock) FROM products) * 100 AS perc_unitsinstock -- results not as expected
	CAST(unitsinstock AS FLOAT) / (SELECT SUM(unitsinstock) FROM products) * 100 AS perc_unitsinstock
	-- 100.0 * unitsinstock / (SELECT SUM(unitsinstock) FROM products) AS perc_unitsinstock
FROM products;



-- WINDOW FUNCTIONS
-------------------------------------------------------------------------------------------

-- ROW_NUMBER(), RANK(), DENSE_RANK(), PERCENT_RANK() example
-- Assign a row number(rank, dense rank, percent rank) to each order based on its order date in ascending order by shipper.
SELECT
	o.orderid,
	s.companyname,
	o.orderdate,
    --o.shipvia,
	ROW_NUMBER() OVER( -- same syntax as RANK(), DENSE_RANK(), PERCENT_RANK()
		PARTITION BY o.shipvia
		ORDER BY o.orderdate) AS row_no
FROM orders o
JOIN shippers s ON o.shipvia = s.shipperid;



-- SUM(), AVG(), MIN(), MAX(), COUNT() example
-- Total (average, minimum, maximum, count) shipping weight by each shipper based on order date in ascending order.
SELECT
	s.companyname,
	o.orderdate,
	o.freight,
    --o.shipvia,
	SUM(o.freight) OVER( --same syntax as AVG(), MIN(), MAX(), COUNT()
		PARTITION BY o.shipvia
		ORDER BY o.orderdate) AS running_total 
FROM orders o
JOIN shippers s
ON o.shipvia = s.shipperid;


-- FIRST_VALUE(), LAST_VALUE() example
-- What was the weight of the first (last, nth) shipment of each shipping company?
SELECT
	s.companyname,
	o.orderdate,
	o.freight,
    --o.shipvia,
	FIRST_VALUE(o.freight) OVER( --same syntax as LAST_VALUE()
		PARTITION BY o.shipvia
		ORDER BY o.orderdate) 
FROM orders o
JOIN shippers s ON o.shipvia = s.shipperid;


-- NTH_VALUE example (3rd)
-- What was the weight of the 3rd shipment of each shipping company?
SELECT
	s.companyname,
	o.orderdate,
	o.freight,
    -- o.shipvia,
	NTH_VALUE(o.freight, 3) OVER(
		PARTITION BY o.shipvia
		ORDER BY o.orderdate) 
FROM orders o
JOIN shippers s ON o.shipvia = s.shipperid;


-- LEAD(), LAG() example
-- Find the weight of the subsequent (previous) freight of a shipping company by order date (ascending).
SELECT
	s.companyname,
	o.orderdate,
	o.freight,
	LEAD(o.freight) OVER( --same syntax as LAG() --try different offsets
		PARTITION BY o.shipvia
		ORDER BY o.orderdate) AS subsequent_freight
FROM
	orders o
JOIN
	shippers s
ON 
	o.shipvia = s.shipperid;


-- CUME_DIST example
-- Find the cumulative distribution of the weights of the freight by each shipper.
SELECT
	s.companyname,
	o.freight,
    o.shipvia,
	CUME_DIST() OVER(
		PARTITION BY o.shipvia
		ORDER BY o.freight)
FROM orders o
JOIN shippers s ON o.shipvia = s.shipperid;


-- NTILE example
-- Find the decile of the weights of the freight of each shipper.
SELECT
	s.companyname,
	o.freight,
    o.shipvia,
	NTILE(10) OVER(
		PARTITION BY o.shipvia
		ORDER BY o.freight) AS tiles
FROM orders o
JOIN shippers s ON o.shipvia = s.shipperid;


-- USER DEFINED FINCTIONS
-------------------------------------------------------------------------------------------

-- user defined function example
CREATE OR REPLACE FUNCTION calc_total_price(input_orderid INTEGER)
RETURNS NUMERIC AS $$
DECLARE
	total_price NUMERIC := 0;
BEGIN
	SELECT SUM(unitprice * quantity * (1 - discount))
	INTO total_price
	FROM order_details
	WHERE orderid = input_orderid;

	RETURN total_price;
END;

$$ LANGUAGE plpgsql;

-- function execution
SELECT
	orderid,
	calc_total_price(orderid)
FROM orders;