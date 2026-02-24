-------------------------------------- CUSTOMER ANALYSIS ----------------------------------------------

-- 1.Which customer spent the most money on music?

SELECT c.customer_id, c.name, SUM(i.total) as total
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC;


-- 2.What is the average customer lifetime value?

SELECT ROUND(AVG(customer_total),3) AS avg_lifetime_value
FROM ( SELECT customer_id, SUM(total) AS customer_total
       FROM invoice
       GROUP BY customer_id );


-- 3.How many customers have made repeat purchases vs one-time purchase?

SELECT CASE 
          WHEN no_of_purchases > 1 THEN 'Repeat'
		  ELSE 'One-time'
		  END AS customer_type,
	   COUNT(*) AS total_customers
FROM ( SELECT c.customer_id, c.name, COUNT(i.invoice_id) AS no_of_purchases
         FROM customer c
         LEFT JOIN invoice i
         ON c.customer_id = i.customer_id
         GROUP BY c.customer_id
) GROUP BY customer_type;



-- 4.Which country generates the most revenue per customers?

SELECT billing_country, 
       ROUND(SUM(total)/COUNT(DISTINCT customer_id),2) AS total_revenue_per_customer
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue_per_customer DESC;


-- 5.Which customers haven't made a purchase in last 6 months

SELECT c.customer_id, c.name
FROM customer c
LEFT JOIN (
   		 SELECT customer_id, MAX(invoice_date) AS last_purchase
   		 FROM invoice
   		 GROUP BY customer_id ) i
ON c.customer_id = i.customer_id
WHERE i.last_purchase IS NULL 
   OR i.last_purchase < CURRENT_DATE - INTERVAL '6 months';



-------------------------------------- Artist & Genre Performance ------------------------------------------

-- 15. Who are the top 5 highest-grossing artists?

SELECT ar.name AS artist_name, 
	   SUM(il.unit_price * il.quantity) AS total_revenue
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 16. Which music genres are most popular in terms of tracks sold and revenue?

SELECT 
    g.name AS genre, 
    SUM(il.quantity) AS tracks_sold, 
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY 1
ORDER BY total_revenue DESC;


-- 17. Are certain genres more popular in specific countries?

WITH genre_country_sales AS (
    SELECT 
        i.billing_country, 
        g.name AS genre, 
        SUM(il.quantity) AS tracks_sold,
        RANK() OVER (PARTITION BY i.billing_country ORDER BY SUM(il.quantity) DESC) as popularity_rank
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY 1, 2
)
SELECT billing_country, genre, tracks_sold
FROM genre_country_sales
WHERE popularity_rank = 1
ORDER BY tracks_sold DESC;


------------------------------------ Employee & Operational Efficiency -------------------------------------------

-- 18. Which employees (support representatives) are managing the highest-spending customers?

SELECT 
    e.employee_name, 
    SUM(i.total) AS total_managed_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1
ORDER BY 2 DESC;


-- 19. What is the average number of customers per employee?

SELECT 
    AVG(customer_count) AS avg_customers_per_rep
FROM (
    SELECT support_rep_id, COUNT(customer_id) AS customer_count
    FROM customer
    GROUP BY support_rep_id
) AS rep_counts;


-- 20. Which employee regions bring in the most revenue?

SELECT 
    e.city, 
    e.country, 
    SUM(i.total) AS regional_revenue
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1, 2
ORDER BY 3 DESC;


---------------------------------------- Geographic Trends -------------------------------------------------

-- 21. Which countries or cities have the highest number of customers?

SELECT country, city, COUNT(customer_id) AS customer_count
FROM customer
GROUP BY 1, 2
ORDER BY 3 DESC;


-- 22. How does revenue vary by region?

SELECT billing_country, billing_state, SUM(total) AS total_revenue
FROM invoice
GROUP BY 1, 2
ORDER BY 3 DESC;


-- 23. Are there any underserved geographic regions (high users, low sales)?


-------------------------------- Customer Retention & Purchase Patterns ---------------------------------------

-- 24. What is the distribution of purchase frequency per customer?

SELECT purchase_count, COUNT(customer_id) AS customer_tally
FROM (
    SELECT customer_id, COUNT(invoice_id) AS purchase_count
    FROM invoice
    GROUP BY customer_id
)
GROUP BY 1
ORDER BY 1;


-- 25. How long is the average time between customer purchases?

WITH date_diffs AS (
    SELECT customer_id, 
           invoice_date - LAG(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) as diff
    FROM invoice
)
SELECT AVG(diff) as average_cycle_duration
FROM date_diffs
WHERE diff IS NOT NULL;


-- 26. What percentage of customers purchase tracks from more than one genre?

WITH genre_counts AS (
    SELECT i.customer_id, COUNT(DISTINCT t.genre_id) as genre_variety
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    GROUP BY 1
)
SELECT 
    ROUND(COUNT(CASE WHEN genre_variety > 1 THEN 1 END) * 100.0 / COUNT(*), 2) as percent_multi_genre_fans
FROM genre_counts;


------------------------------------- Operational Optimization ---------------------------------------------

-- 27. What are the most common combinations of tracks purchased together?

SELECT a.track_id as item_1, 
	   b.track_id as item_2, 
	   COUNT(*) as frequency
FROM invoice_line a
JOIN invoice_line b ON a.invoice_id = b.invoice_id AND a.track_id < b.track_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;


-- 28. Which media types (e.g., MPEG, AAC) are declining or increasing in usage?

SELECT 
    m.name as format, 
    EXTRACT(YEAR FROM i.invoice_date) as sale_year,
    SUM(il.quantity) as units_sold
FROM media_type m
JOIN track t ON m.media_type_id = t.media_type_id
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
GROUP BY 1, 2
ORDER BY 1, 2;

  