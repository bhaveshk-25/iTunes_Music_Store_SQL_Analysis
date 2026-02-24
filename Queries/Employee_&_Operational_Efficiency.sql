
------------------------------------ Employee & Operational Efficiency -------------------------------------------

-- 1. Which employees (support representatives) are managing the highest-spending customers?

SELECT 
    e.employee_name, 
    SUM(i.total) AS total_managed_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1
ORDER BY 2 DESC;


-- 2. What is the average number of customers per employee?

SELECT 
    AVG(customer_count) AS avg_customers_per_rep
FROM (
    SELECT support_rep_id, COUNT(customer_id) AS customer_count
    FROM customer
    GROUP BY support_rep_id
) AS rep_counts;


-- 3. Which employee regions bring in the most revenue?

SELECT 
    e.city, 
    e.country, 
    SUM(i.total) AS regional_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC;

