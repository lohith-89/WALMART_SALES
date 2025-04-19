SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT
    payment_method,
    COUNT(*) AS total
FROM walmart
GROUP BY payment_method;


SELECT
	COUNT(DISTINCT branch)
FROM walmart;


SELECT MAX(quantity) FROM walmart;

--1  Find difference payment method and number of transaction and quantity sold
SELECT
    payment_method,
    COUNT(*) AS no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Identify the highest-rated category in each branch,displaying the branch,category
-- Avg Rating


SELECT *
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
) AS ranked_data
WHERE rank = 1;


--Q3 Identify the busiest day for each branch based on the number of transaction 
SELECT *
FROM (
    SELECT 
        branch,
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'DAY')
) AS ranked_days
WHERE rank = 1;

--Q4 Calculate the total quantity of items sold per payment method
SELECT
    payment_method,
    COUNT(*) AS no_payments,
	SUM(quantity) as no_qty_sold 
FROM walmart
GROUP BY payment_method;


--Q5
-- Determine the average,minimum and maximum rating of product for each city.
-- List the city,average_rating ,min_rating and max_rating.
SELECT
	branch,
	city,
	min(rating) as min_rating,
	max(rating) as max_rating,
	avg(rating) as avg_rating
FROM walmart
GROUP BY 1,2;

--Q6
--Calculate the total profit for each category 
SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin)as profit
	
FROM walmart
GROUP BY 1;

--Q7 Determine the most common payment method for each branch
WITH cte
AS
(SELECT
	branch,
	payment_method,
	COUNT(*) AS total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC)
FROM WALMART
GROUP BY 1,2
)
SELECT *
FROM CTE
WHERE RANK =1;

--Q8 CATTEGORIZE SALES INTO 3GROUPS MORNING, AFTERNOON,EVENING

SELECT
	branch,
    CASE
        WHEN EXTRACT(HOUR FROM time::time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM time::time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS num_transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;



-- Q9 IDENTIFY 5 BRANCH WITH HIGHEST DECRESE RATIO IN REVENVUE COMPARE TO LAST YEAR 
-- Query 1: Add formatted date
SELECT *,
    TO_DATE(date, 'DD/MM/YY') AS formatted_date
FROM walmart;

-- Query 2: Top 5 branches with highest revenue drop from 2022 to 2023
WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue_2022
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue_2023
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
),
revenue_change AS (
    SELECT
        r22.branch,
        r22.revenue_2022,
        r23.revenue_2023,
        ROUND(
    ((r22.revenue_2022 - r23.revenue_2023) / NULLIF(r22.revenue_2022, 0) * 100)::numeric,
    2
) AS revenue_drop_percent

    FROM revenue_2022 r22
    JOIN revenue_2023 r23 ON r22.branch = r23.branch
)

SELECT *
FROM revenue_change
ORDER BY revenue_drop_percent DESC
LIMIT  5

