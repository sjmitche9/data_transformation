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
	DISTINCT(orderid),
	calc_total_price(orderid)
FROM order_details;