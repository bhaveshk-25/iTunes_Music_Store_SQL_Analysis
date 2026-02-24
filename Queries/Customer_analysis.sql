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



