-- CREATE TABLE master_sales (
--     order_id VARCHAR(50),
--     customer_id VARCHAR(50),
--     order_status VARCHAR(20),
--     order_purchase_timestamp TIMESTAMP,
--     order_approved_at TIMESTAMP,
--     order_delivered_carrier_date TIMESTAMP,
--     order_delivered_customer_date TIMESTAMP,
--     order_estimated_delivery_date TIMESTAMP,
--     order_item_id INTEGER,
--     product_id VARCHAR(50),
--     seller_id VARCHAR(50),
--     shipping_limit_date TIMESTAMP,
--     price NUMERIC(10, 2),
--     freight_value NUMERIC(10, 2),
--     product_category_name VARCHAR(100),
--     product_name_lenght NUMERIC,
--     product_description_lenght NUMERIC,
--     product_photos_qty NUMERIC,
--     product_weight_g NUMERIC,
--     product_length_cm NUMERIC,
--     product_height_cm NUMERIC,
--     product_width_cm NUMERIC,
--     product_category_name_english VARCHAR(100),
--     customer_unique_id VARCHAR(50),
--     customer_zip_code_prefix VARCHAR(20),
--     customer_city VARCHAR(100),
--     customer_state VARCHAR(10),
--     seller_zip_code_prefix VARCHAR(20),
--     seller_city VARCHAR(100),
--     seller_state VARCHAR(10),
--     review_id VARCHAR(50),
--     review_score NUMERIC,
--     review_comment_title TEXT,
--     review_comment_message TEXT,
--     review_creation_date TIMESTAMP,
--     review_answer_timestamp TIMESTAMP,
--     total_order_value NUMERIC(10, 2)
-- );

-- select * from master_sales

-- ## Q1. Calculate the Total Revenue generated, Total number of Orders, 
-- and the Average Order Value (AOV) for the entire dataset.

-- SELECT 
--     ROUND(SUM(total_order_value), 2) AS total_revenue,
--     COUNT(DISTINCT order_id) AS total_orders,
--     ROUND(SUM(total_order_value) / COUNT(DISTINCT order_id), 2) AS average_order_value
-- FROM master_sales;

-- ## Q2. Find the Total Revenue generated in each month and year. Sort the output chronologically.

-- SELECT 
--     Date_TRUNC('month', order_purchase_timestamp) AS month_year,
--     round(SUM(total_order_value), 2) AS total_amount_sum
-- FROM master_sales
-- GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
-- ORDER BY month_year;

-- ## Q3. Find out which day of the week (Monday, Tuesday, etc.) 
--      generates the highest total revenue and the highest number of orders.

-- SELECT 
--     TRIM(TO_CHAR(order_purchase_timestamp, 'Day')) AS day_of_week,
--     COUNT(DISTINCT order_id) AS total_orders,
--     ROUND(SUM(total_order_value), 2) AS total_revenue
-- FROM master_sales
-- GROUP BY TRIM(TO_CHAR(order_purchase_timestamp, 'Day'))
-- ORDER BY total_revenue DESC;
	 
-- ## Q4. Find the Top 10 Product Categories (in English) that generated the highest total revenue. 
--       Also, show how many units (items) were sold in each of those categories.

-- select product_category_name_english, COUNT(product_id) AS total_units_sold,
-- round(sum(total_order_value), 2) as Total_Revenue from master_sales
-- group by product_category_name_english
-- order by Total_Revenue desc
-- limit 10

-- ## Q5. Identify the Top 5 specific products (using product_id) that were sold 
--      the most number of times (High Volume). Are they the same products that generated the most revenue?

-- SELECT 
--     product_id, COUNT(product_id) AS total_sold_product, 
--     ROUND(SUM(total_order_value), 2) AS total_revenue FROM master_sales
-- GROUP BY product_id
-- ORDER BY total_sold_product DESC
-- LIMIT 5;

-- ## Q6. Calculate the average product price and average freight (shipping) value for each product category (in English).
--       Which top 5 categories have the highest average freight value?

-- SELECT 
--     product_category_name_english, 
--     ROUND(AVG(price), 2) AS avg_product_price,
--     ROUND(AVG(freight_value), 2) AS avg_freight_value
-- FROM master_sales
-- GROUP BY product_category_name_english
-- ORDER BY avg_freight_value DESC
-- LIMIT 5;

-- ## Q7. Find the Top 5 customer states (customer_state) that have the highest number of orders. 
--      Also, show the total revenue generated from each of these states.

-- select 
-- 	   customer_state, 
-- 	   count(distinct order_id) as Total_orders,
-- 	   round(sum(total_order_value), 2) as Total_revenue 
-- from master_sales
-- group by customer_state
-- order by Total_orders desc
-- limit 5

-- ## Q8. Calculate the average delivery time (in days) for each customer state. 
-- 	  Which 5 states have the fastest average delivery time?

-- SELECT 
--     customer_state,
--     ROUND(AVG(order_delivered_customer_date::DATE - order_purchase_timestamp::DATE), 2) AS avg_delivery_days 
-- FROM master_sales
-- GROUP BY customer_state
-- ORDER BY avg_delivery_days ASC
-- LIMIT 5;

-- ## Q9. Find out how many total orders were delivered late (i.e., delivered after the estimated delivery date). 
-- 	  Also, which 3 customer states have the highest number of late deliveries

-- SELECT 
--     customer_state, 
--     COUNT(DISTINCT order_id) AS total_late_deliveries
-- FROM master_sales
-- WHERE order_delivered_customer_date > order_estimated_delivery_date
-- GROUP BY customer_state
-- ORDER BY total_late_deliveries DESC
-- LIMIT 3;

-- ## Q10. Find the 5 worst-performing product categories (in English) based on their average customer review score. 
-- 	   Only include categories that have been reviewed.

-- select 	
-- 	product_category_name_english, 
-- 	round(avg(review_score),2) as Avg_review 
-- from master_sales
-- group by product_category_name_english
-- order by Avg_review asc
-- limit 5

-- ## Q11. Calculate the average review score for orders that were delivered LATE. 
-- 	   Is it significantly lower than the overall average review score

-- SELECT 
--     ROUND(AVG(review_score), 2) AS overall_avg_score,
--     ROUND(AVG(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN review_score END), 2) AS late_delivery_avg_score
-- FROM master_sales;

-- ## Q12. Calculate the Total Revenue (Monetary) and Total Number of Orders (Frequency) for each unique customer (customer_unique_id). 
-- 	  Identify the Top 5 best customers based on their Total Revenue.

-- SELECT 
--     customer_unique_id, 
--     COUNT(DISTINCT order_id) AS total_orders_frequency, 
--     ROUND(SUM(total_order_value), 2) AS total_spent_monetary
-- FROM master_sales
-- GROUP BY customer_unique_id
-- ORDER BY total_spent_monetary DESC
-- LIMIT 5;

-- ## Q13. The Pareto Principle (80/20 Rule for Sellers)

-- WITH SellerRevenue AS (
--     SELECT 
--         seller_id, 
--         SUM(total_order_value) AS total_revenue
--     FROM master_sales
--     GROUP BY seller_id
-- ),
-- RankedSellers AS (
--     SELECT 
--         seller_id,
--         total_revenue,
--         NTILE(5) OVER(ORDER BY total_revenue DESC) AS seller_tier
--     FROM SellerRevenue
-- )
-- SELECT 
--     seller_tier,
--     COUNT(seller_id) AS total_sellers_in_tier,
--     ROUND(SUM(total_revenue), 2) AS tier_total_revenue,
--     ROUND((SUM(total_revenue) / (SELECT SUM(total_revenue) FROM SellerRevenue)) * 100, 2) AS revenue_percentage
-- FROM RankedSellers
-- WHERE seller_tier = 1
-- GROUP BY seller_tier;

-- ## Q14. VIP Customer Identification

-- SELECT 
--     customer_unique_id, 
--     COUNT(DISTINCT order_id) AS total_orders_placed,
--     ROUND(SUM(total_order_value), 2) AS total_amount_spent
-- FROM master_sales
-- GROUP BY customer_unique_id
-- ORDER BY total_orders_placed DESC, total_amount_spent DESC
-- LIMIT 5;
