
------------------------------------- Operational Optimization ---------------------------------------------

-- 1. What are the most common combinations of tracks purchased together?

SELECT a.track_id as item_1, 
	   b.track_id as item_2, 
	   COUNT(*) as frequency
FROM invoice_line a
JOIN invoice_line b ON a.invoice_id = b.invoice_id AND a.track_id < b.track_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;


-- 2. Which media types (e.g., MPEG, AAC) are declining or increasing in usage?

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

  