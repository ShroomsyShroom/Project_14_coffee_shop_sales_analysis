CREATE TABLE coffee_shop (
	transaction_id INT PRIMARY KEY,
	transaction_date DATE,
	transaction_time TIME,
	transaction_qty INT,
	store_id INT,
	store_location VARCHAR(50),
	product_id INT,
	unit_price FLOAT,
	product_category VARCHAR(50),
	product_type VARCHAR(50),
	product_detail VARCHAR(50)
	)


SELECT * FROM coffee_shop;

SELECT 
	ROUND(SUM(transaction_qty::NUMERIC*unit_price::NUMERIC), 2)AS total_sales_for_may
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date) = 3;

WITH monthly_coffee_sales AS(
	SELECT
		EXTRACT(MONTH FROM transaction_date) AS month,
		SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_sales
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date) IN (4,5)
	GROUP BY EXTRACT(MONTH FROM transaction_date)
)
SELECT 
	month,
	ROUND(total_sales, 2) AS total_sales,
	ROUND(
		 (total_sales - LAG(total_sales) OVER (ORDER BY month))/LAG(total_sales) OVER (ORDER BY month) * 100, 2
	) AS mom_increase_percentage
FROM monthly_coffee_sales
ORDER BY month;

WITH 
	monthly_coffee_sales AS
(
	SELECT
		EXTRACT(MONTH FROM transaction_date) AS month,
		SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_sales
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date) IN (4,5)
	GROUP BY EXTRACT(MONTH FROM transaction_date)
)
SELECT 
	month,
	ROUND(total_sales , 2) AS total_sales,
	ROUND(total_sales - LAG(total_sales) OVER (ORDER BY month),2) AS Sales_diff
FROM monthly_coffee_sales
ORDER BY month;

SELECT * FROM coffee_shop;

SELECT COUNT(*) AS total_orders
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date) = 3;


WITH monthly_sales AS
(
	SELECT 
		EXTRACT(MONTH FROM transaction_date) AS month,
		COUNT(*) AS total_orders
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date) IN (4,5)
	GROUP BY EXTRACT(MONTH FROM transaction_date)
)
SELECT 
	month,
	total_orders,
	ROUND(total_orders - LAG(total_orders) OVER (ORDER BY month) ,2) AS Orders_diff
FROM monthly_sales
ORDER BY month;

WITH monthly_sales AS
(
	SELECT 
		EXTRACT(MONTH FROM transaction_date) AS month,
		COUNT(*) AS total_orders
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date) IN (4,5)
	GROUP BY EXTRACT(MONTH FROM transaction_date)
)
SELECT 
	month,
	total_orders,
	ROUND(((total_orders::NUMERIC - LAG(total_orders) OVER (ORDER BY month)::NUMERIC)
	/LAG(total_orders) OVER (ORDER BY month)::NUMERIC)*100 ,2) AS MoM_Order_Change
FROM monthly_sales
ORDER BY month;


SELECT * FROM coffee_shop;

SELECT SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5;


WITH monthly_sales AS
(
	SELECT	
		EXTRACT(MONTH FROM transaction_date) AS month,
		SUM(transaction_qty) AS total_qty_sold
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date) IN (4,5)
	GROUP BY EXTRACT(MONTH FROM transaction_date)
)
SELECT 
	month,
	total_qty_sold,
	ROUND(((total_qty_sold::NUMERIC - LAG(total_qty_sold) OVER (ORDER BY month)::NUMERIC)
		/LAG(total_qty_sold) OVER (ORDER BY month)::NUMERIC)*100, 2) AS MoM_SalesQty_Change
FROM monthly_sales;

WITH monthly_sales AS
(
	SELECT	
		EXTRACT(MONTH FROM transaction_date) AS month,
		SUM(transaction_qty) AS total_qty_sold
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date) IN (4,5)
	GROUP BY EXTRACT(MONTH FROM transaction_date)
)
SELECT 
	month,
	total_qty_sold,
	((total_qty_sold::NUMERIC - LAG(total_qty_sold) OVER (ORDER BY month)::NUMERIC)) AS SalesQty_Change
FROM monthly_sales;

SELECT * FROM coffee_shop;

SELECT
	SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_revenue,
	COUNT(transaction_id) AS total_orders,
	SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop
WHERE transaction_date = '2023-01-01';

SELECT
	CONCAT(ROUND(SUM(transaction_qty::NUMERIC * unit_price::NUMERIC)/1000,1), 'K') AS total_revenue,
	CONCAT(COUNT(transaction_id),'K') AS total_orders,
	CONCAT(SUM(transaction_qty),'K') AS total_qty_sold
FROM coffee_shop
WHERE transaction_date = '2023-01-01';

SELECT
	CASE WHEN EXTRACT(DOW FROM transaction_date) IN (1,7) THEN 'Weekends'
	ELSE 'Weekdays'
	END AS Week_day_type,
	SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)= 5
GROUP BY 
	CASE WHEN EXTRACT(DOW FROM transaction_date) IN (1,7) THEN 'Weekends'
	ELSE 'Weekdays'
	END;

SELECT * FROM coffee_shop;

SELECT
	SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_revenue,
	COUNT(transaction_id) AS total_orders,
	SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop
GROUP BY store_location;

SELECT * FROM coffee_shop;

SELECT
	AVG(transaction_qty::NUMERIC * unit_price::NUMERIC) AS Average_sales
FROM coffee_shop;

SELECT 
	ROUND(AVG(total_sales),2) AS Average_sales
FROM(
	SELECT SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_sales
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date)=5
	GROUP BY transaction_date
);

SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Average_sales
FROM(
	SELECT SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_sales
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date)=5
	GROUP BY transaction_date);

SELECT 
	EXTRACT(DAY FROM transaction_date) AS day_of_month,
	SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
GROUP BY EXTRACT(DAY FROM transaction_date)
ORDER BY EXTRACT(DAY FROM transaction_date);

SELECT
	day_of_month,
	CASE
		WHEN total_sales > avg_sales THEN 'ABOVE AVERAGE'
		WHEN total_sales < avg_sales THEN 'BELOW AVERAGE'
		ELSE 'AVERAGE'
	END AS sales_status,
	total_sales
FROM (
		SELECT 
		EXTRACT(DAY FROM transaction_date) AS day_of_month,
		SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales,
		AVG(SUM(unit_price::NUMERIC * transaction_qty::NUMERIC)) OVER () AS avg_sales
		FROM coffee_shop
		WHERE EXTRACT(MONTH FROM transaction_date)=5
		GROUP BY EXTRACT(DAY FROM transaction_date)
)
ORDER BY day_of_month;

WITH daily_sales AS(
	SELECT 
		EXTRACT(DAY FROM transaction_Date) AS day_of_month,
		SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date) = 5
	GROUP BY EXTRACT(DAY FROM transaction_date)
)
SELECT 
	day_of_month,
	total_sales,
	AVG(total_sales) OVER () AS avg_sales,
	CASE
        WHEN total_sales > AVG(total_sales) OVER () THEN 'ABOVE AVERAGE'
        WHEN total_sales < AVG(total_sales) OVER () THEN 'BELOW AVERAGE'
        ELSE 'AVERAGE'
    END AS sales_status
FROM daily_sales
ORDER BY day_of_month;

SELECT * FROM coffee_shop;

SELECT 
	product_type,
	SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

SELECT 
	SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales,
	SUM(transaction_qty) AS total_qty_sold,
	COUNT(*) AS total_orders
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
	  AND
	  EXTRACT(DAY FROM transaction_date)=1
	  AND
	  EXTRACT(HOUR FROM transaction_time) = 14
;


SELECT 
	EXTRACT(HOUR FROM transaction_time),
	SUM(unit_price*transaction_qty)
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
GROUP BY 1
ORDER BY 2;

SELECT 
    EXTRACT(DOW FROM transaction_date) AS day,
    CASE EXTRACT(DOW FROM transaction_date)
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END AS day_name,
	ROUND(SUM(unit_price::NUMERIC * transaction_qty::NUMERIC),2) AS total_sales
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date) = 5
GROUP BY 1
ORDER BY total_sales DESC;

SELECT
	TO_CHAR(transaction_date, 'Day') AS day_name,
	ROUND(SUM(unit_price::NUMERIC * transaction_qty::NUMERIC),2) AS total_sales
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
GROUP BY 1
ORDER BY 2;
