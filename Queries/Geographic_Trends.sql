
---------------------------------------- Geographic Trends -------------------------------------------------

-- 1. Which countries or cities have the highest number of customers?

SELECT country, city, COUNT(customer_id) AS customer_count
FROM customer
GROUP BY 1, 2
ORDER BY 3 DESC;


-- 2. How does revenue vary by region?

SELECT billing_country, billing_state, SUM(total) AS total_revenue
FROM invoice
GROUP BY 1, 2
ORDER BY 3 DESC;

