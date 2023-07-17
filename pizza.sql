/* Case study Pizza Runners */
-- Author: Mohamed Elmasry
-- MY SQL was used to carry out that project

-- First Section.. Pizza Metrics
-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id) Total_pizza_ordered
FROM customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT(ORDER_ID)) Total_unique_customers
FROM customer_orders;

-- 3. How many successful orders were delivered by each runner?
/*  IMPORTANT NOTICE THE ( NULL VALUE ) IN THAT TABLE IS NOT ACTUAL NULL
	once YOU COUNT THE TABLE IT WILL GIVE THE TOTAL NUMBER OF ROWS ( INCLUDING NULLS )!! */
    
SELECT runner_id, COUNT(ORDER_ID) AS total_orders
FROM runner_orders 
WHERE PICKUP_TIME !=0
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?

SELECT pizza_name, COUNT(co.pizza_id) TOTAL_COUNT
FROM runner_orders RO
INNER JOIN customer_orders CO
	ON RO.order_id = CO.order_id
INNER JOIN pizza_names PN
		ON PN.pizza_id = CO.pizza_id
WHERE RO.DISTANCE != 0
GROUP BY pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT customer_id, pizza_name, COUNT(pizza_name) AS pizza_count
FROM customer_orders CO
INNER JOIN pizza_names PN
	ON CO.pizza_id = PN.pizza_id
GROUP BY CUSTOMER_ID, pizza_name
ORDER BY CUSTOMER_ID;

-- 6. What was the maximum number of pizzas delivered in a single order?

SELECT RO.order_id,COUNT(pizza_id) TOTAL_PIZZA_COUNT
FROM customer_orders CO
INNER JOIN runner_orders RO
	ON CO.order_id=RO.order_id
WHERE DURATION <> 0
GROUP  BY RO.ORDER_ID
ORDER BY TOTAL_PIZZA_COUNT DESC
LIMIT 1;


 /* there are written null which is considered as "Value"  and in the counting process it will be counted 
 which will give wrong data.    1st. we will replace the written null to real null then we count for customer_orders and for runner_orders */

UPDATE customer_orders
SET EXCLUSIONS = NULL
WHERE EXCLUSIONS = 'null' OR EXCLUSIONS = '';

UPDATE customer_orders
SET EXTRAS = NULL
WHERE EXTRAS = 'null' OR EXTRAS = '';
-- updating the runner_orders table from the "null" with NULL
UPDATE runner_orders
SET PICKUP_TIME = NULL
WHERE PICKUP_TIME = 'null';

UPDATE runner_orders
SET DISTANCE = NULL
WHERE DISTANCE = 'null';

UPDATE runner_orders
SET DURATION = NULL
WHERE DURATION = 'null';

UPDATE runner_orders
SET CANCELLATION = NULL
WHERE CANCELLATION ='null' OR CANCELLATION = '';

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT CUSTOMER_ID, SUM(CASE
					WHEN exclusions IS  NOT NULL OR EXTRAS IS NOT NULL THEN 1
                    ELSE 0 END ) AS HAS_CHANGES,
                    SUM(CASE 
						WHEN exclusions IS NOT NULL OR EXTRAS IS NOT NULL THEN 0
                        ELSE 1 END) NO_CHANGES
FROM customer_orders CO
INNER JOIN runner_orders RO
	ON CO.order_id = RO.order_id
WHERE DISTANCE IS NOT NULL
GROUP BY CUSTOMER_ID
ORDER BY CUSTOMER_ID;
#GROUP BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?

WITH CTE AS (SELECT CUSTOMER_ID, SUM( CASE 
				WHEN EXCLUSIONS IS NOT NULL AND EXTRAS IS NOT NULL THEN 1
                ELSE 0 END ) AS NUMBER_PIZZAS_HAVE_BOTH_CHANGES
FROM CUSTOMER_ORDERS CO
INNER JOIN runner_orders RO
	ON CO.ORDER_ID = RO.order_id
WHERE DISTANCE IS NOT NULL
GROUP BY CUSTOMER_ID)
SELECT customer_ID, NUMBER_PIZZAS_HAVE_BOTH_CHANGES
FROM CTE
WHERE NUMBER_PIZZAS_HAVE_BOTH_CHANGES > 0;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT ORDER_TIME,HOUR(ORDER_TIME), COUNT(ORDER_ID)
FROM CUSTOMER_ORDERS
GROUP BY ORDER_TIME,HOUR(ORDER_TIME)
ORDER BY ORDER_TIME;

-- 10. What was the volume of orders for each day of the week?

SELECT  DAYNAME(ORDER_TIME), COUNT(PIZZA_ID)
FROM CUSTOMER_ORDERS
GROUP BY DAYNAME(ORDER_TIME);

/* B. Runner and Customer Experience */
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

WITH CTE AS (SELECT *,WEEK(REGISTRATION_dATE,1) WEEK_NUMBER
FROM RUNNERS)
SELECT COUNT(RUNNER_ID), WEEK_NUMBER
FROM CTE
GROUP BY WEEK_NUMBER;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH CTE AS (SELECT R.runner_id,RO.ORDER_ID,TIMEDIFF(PICKUP_TIME, ORDER_TIME) AS TIME_TAKEN
FROM customer_orders CO
INNER JOIN runner_orders RO
	ON CO.ORDER_ID = RO.ORDER_ID
INNER JOIN RUNNERS R
	ON RO.RUNNER_ID = R.RUNNER_ID
WHERE distance IS NOT NULL)
SELECT RUNNER_ID, CAST(AVG(TIME_TAKEN) AS TIME) AS AVG_PICKUP_TIME
FROM CTE
GROUP BY RUNNER_ID;

-- 3.What is the successful delivery percentage for each runner?

SELECT
	runner_id,
   ROUND( SUM(CASE
		WHEN distance > 0 THEN 1
        WHEN distance IS NULL THEN 0
    END)/COUNT(*) * 100,0) AS PERCENTAGE 

FROM 
	RUNNER_ORDERS
GROUP BY RUNNER_ID;

SELECT *
FROM pizza_toppings;

SELECT *
FROM pizza_recipes;