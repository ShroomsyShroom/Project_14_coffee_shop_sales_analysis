# Coffee Shop Sales Analysis

## Project Overview
This project presents a comprehensive analysis of coffee shop operational data using **SQL** for robust data transformation and **Power BI** for interactive visualization. The objective is to track critical Key Performance Indicators (KPIs) and uncover consumer behavior patterns to optimize inventory and staffing.

---

## Technical Stack
* **Database:** PostgreSQL / pgAdmin
* **Visualization:** Power BI
* **Data Processing:** SQL (CTEs, Window Functions, Aggregate Functions)

---

## Analysis Requirements

### 1. KPI Metrics
The following metrics are calculated to track growth and performance trends:
* **Total Sales Analysis:** Monthly revenue, Month-on-Month (MoM) growth/decline, and absolute revenue variance.
* **Order Analysis:** Total transaction counts and volume fluctuations between periods.
* **Quantity Analysis:** Total units sold with comparative analysis against previous months.

### 2. Visualization Modules
* **Calendar Heat Map:** Color-coded frequency map to identify peak sales days.
* **Weekday vs. Weekend Segmentation:** Insights into variations in customer behavior.
* **Store Location Performance:** Comparative revenue analysis across different branches.
* **Top 10 Products:** Identifying high-revenue items to drive inventory decisions.
* **Peak Hour Analysis:** Analyzing sales by day and hour for optimized scheduling.

---

## SQL Implementation

### Database Schema
```sql

<code> CREATE TABLE coffee_shop (
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
) </code>

2. Comprehensive Analytical Queries
A. Total Sales Analysis (Monthly & MoM) 

## Now that we've created the table and imported the data in it, lets see the table using the following query:

Code:

SELECT * FROM coffee_shop;

## Now that we've done everything needed, lets move onto some analysis:

A. Total Sales Analysis:

a. Total sales for each month

Code:

SELECT 
	ROUND(SUM(transaction_qty::NUMERIC*unit_price::NUMERIC), 2)AS total_sales
FROM coffee_shop;

--Based on Month

Code:

SELECT 
	ROUND(SUM(transaction_qty::NUMERIC*unit_price::NUMERIC), 2)AS total_sales_for_may
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date) = 3;

b. Month on Month increase or decrease in sales

Code: 

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

c. Diff btwn sales btwn selected and prev month

Code:

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

B. Total Order Analysis:

a. Total no. of orders per mnth

Code:

SELECT COUNT(*) AS total_orders
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date) = 3;

b. MoM increase or Decrease in no. of orders

Code:

WITH monthly_orders AS
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
FROM monthly_orders
ORDER BY month;

c. Diff in no. of orders btwn selected and prev month

Code:

WITH monthly_orders AS
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
	(total_orders - LAG(total_orders) OVER (ORDER BY month)) AS Orders_diff
FROM monthly_orders
ORDER BY month;

C. Total Qty sold analysis:

a. Total qty

Code:

SELECT SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop;

--Total qty based on month

Code:

SELECT SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5;


b. MoM increase or decrease

Code:

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

c. Diff in total qty in selected and prev month

Code:


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

D. Analysis of Total Qty, Sales and Revenue by day

Code:

SELECT
	CONCAT(ROUND(SUM(transaction_qty::NUMERIC * unit_price::NUMERIC)/1000,1), 'K') AS total_revenue,
	CONCAT(COUNT(transaction_id),'K') AS total_orders,
	CONCAT(SUM(transaction_qty),'K') AS total_qty_sold
FROM coffee_shop
WHERE transaction_date = '2023-01-01';

E. Sales analysis by weekdays and weekends

Code:

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

F. Sales analysis by location

Code:

SELECT
	SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_revenue,
	COUNT(transaction_id) AS total_orders,
	SUM(transaction_qty) AS total_qty_sold
FROM coffee_shop
GROUP BY store_location;

G. Daily sales analysis by Average line(below avg above avg)

Code:

--Avg by month

Code:

SELECT 
	CONCAT(ROUND(AVG(total_sales)/1000,1),'K') AS Average_sales
FROM(
	SELECT SUM(transaction_qty::NUMERIC * unit_price::NUMERIC) AS total_sales
	FROM coffee_shop
	WHERE EXTRACT(MONTH FROM transaction_date)=5
	GROUP BY transaction_date);

--Avg line based daily sales analysis

Code:

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

--USING CTE

Code:

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


H. Sales by product category analysis

Code:

SELECT 
	product_category,
	SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales
FROM coffee_shop
GROUP BY 1;

I. Top 10 products in terms of sales in each month

Code:

SELECT 
	product_type,
	SUM(unit_price::NUMERIC * transaction_qty::NUMERIC) AS total_sales
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

J. Sales analysis by Days and Hours

Code:

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

--Peak hour Analysis

Code:

SELECT 
	EXTRACT(HOUR FROM transaction_time),
	SUM(unit_price*transaction_qty)
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
GROUP BY 1
ORDER BY 2;

--Peak Day of the week analysis

Code:

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

#AlternateCode:

SELECT
	TO_CHAR(transaction_date, 'Day') AS day_name,
	ROUND(SUM(unit_price::NUMERIC * transaction_qty::NUMERIC),2) AS total_sales
FROM coffee_shop
WHERE EXTRACT(MONTH FROM transaction_date)=5
GROUP BY 1
ORDER BY 2;

## Now that we've analysed the data using SQL, we'll make a visualisation using Power BI in form of a dashboard.
