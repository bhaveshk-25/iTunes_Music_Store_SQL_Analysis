
-------------------------------- Customer Retention & Purchase Patterns ---------------------------------------

-- 1. What is the distribution of purchase frequency per customer?

SELECT purchase_count, COUNT(customer_id) AS customer_tally
FROM (
    SELECT customer_id, COUNT(invoice_id) AS purchase_count
    FROM invoice
    GROUP BY customer_id
)
GROUP BY 1
ORDER BY 1;


-- 2. How long is the average time between customer purchases?

WITH date_diffs AS (
    SELECT customer_id, 
           invoice_date - LAG(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) as diff
    FROM invoice
)
SELECT AVG(diff) as average_cycle_duration
FROM date_diffs
WHERE diff IS NOT NULL;


-- 3. What percentage of customers purchase tracks from more than one genre?

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

