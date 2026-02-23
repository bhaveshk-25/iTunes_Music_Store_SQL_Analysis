-------------------------- CUSTOMER ANALYSIS --------------------------------

-- 1.Which customer spent the most money on music?

SELECT c.customer_id, c.name, SUM(i.total) as total
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC;


-- 2.What is the average customer lifetime value?

SELECT ROUND(AVG(customer_total),3) AS avg_lifetime_value
FROM (
    SELECT customer_id, SUM(total) AS customer_total
    FROM invoice
    GROUP BY customer_id
);


-- 3.How many customers have made repeat purchases vs one-time purchase?

SELECT CASE 
          WHEN no_of_purchases > 1 THEN 'Repeat'
		  ELSE 'One-time'
		  END AS customer_type,
	   COUNT(*) AS total_customers
FROM (SELECT c.customer_id, c.name, COUNT(i.invoice_id) AS no_of_purchases
         FROM customer c
         LEFT JOIN invoice i
         ON c.customer_id = i.customer_id
         GROUP BY c.customer_id
) GROUP BY customer_type;



-- 4.Which country generates the most revenue per customers?
SELECT billing_country, ROUND(SUM(total)/COUNT(DISTINCT customer_id),2) AS total_revenue_per_customer
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue_per_customer DESC;


-- 5.Which customers haven't made a purchase in last 6 months

SELECT c.customer_id, c.name
FROM customer c
LEFT JOIN (
    SELECT customer_id, MAX(invoice_date) AS last_purchase
    FROM invoice
    GROUP BY customer_id
) i ON c.customer_id = i.customer_id
WHERE i.last_purchase IS NULL 
   OR i.last_purchase < CURRENT_DATE - INTERVAL '6 months';


--------------------- SALES & REVENUE ANALYSIS ------------------------------

-- 1.What are the monthy revenue trends for the last two years

SELECT 
    DATE(DATE_TRUNC('month', invoice_date)) AS month, 
    SUM(total) AS monthly_revenue
FROM invoice
WHERE invoice_date >= (SELECT MAX(invoice_date) FROM invoice) - INTERVAL '2 years'
GROUP BY month
ORDER BY month;


-- 2.What is the average value of an invoice(purchase)

SELECT ROUND(AVG(total),2) AS avg_invoice_value
FROM invoice;


-- 3.How much revenue does each sales representative contribute

SELECT e.employee_id, e.employee_name, SUM(i.total) AS total_revenue_contribution
FROM employee e
LEFT JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY 1
ORDER BY total_revenue_contribution DESC;


-- 4.which months or quarters have peak music sales

SELECT TO_CHAR(invoice_date, 'Month') AS month, SUM(total) AS total_revenue
FROM invoice
GROUP BY month
ORDER BY total_revenue DESC;

-------------------------- PRODUCT & CONTET ANALYSIS ----------------------------------

-- 1.Which tracks generated the most revenue

SELECT il.track_id, t.name AS track, SUM(il.unit_price * il.quantity) AS total_revenue
FROM invoice_line il
JOIN track t
ON il.track_id = t.track_id
GROUP BY il.track_id, t.name
ORDER BY total_revenue DESC;


-- 2. Which albums or playlists are most frequently included in purchases?

SELECT a.title AS album_title, COUNT(il.invoice_line_id) AS purchase_count
FROM album a
JOIN track t ON a.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY 1
ORDER BY purchase_count DESC;


-- 3. Are there any tracks or albums that have never been purchased?

SELECT t.track_id, t.name
FROM track t
LEFT JOIN invoice_line il ON t.track_id = il.track_id
WHERE il.invoice_line_id IS NULL;


-- 4. What is the average price per track across different genres?

SELECT g.name AS genre, ROUND(AVG(t.unit_price), 2) AS avg_price
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
GROUP BY genre
ORDER BY avg_price DESC;


-- 5. How many tracks does the store have per genre and how does it correlate with sales?

SELECT 
    g.name AS genre, 
    COUNT(DISTINCT t.track_id) AS track_count, 
    SUM(il.quantity) AS total_sold
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY genre
ORDER BY total_sold DESC;



