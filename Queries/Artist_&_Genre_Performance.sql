-------------------------------------- Artist & Genre Performance ------------------------------------------

-- 1. Who are the top 5 highest-grossing artists?

SELECT ar.name AS artist_name, 
	   SUM(il.unit_price * il.quantity) AS total_revenue
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


-- 2. Which music genres are most popular in terms of tracks sold and revenue?

SELECT 
    g.name AS genre, 
    SUM(il.quantity) AS tracks_sold, 
    SUM(il.unit_price * il.quantity) AS total_revenue
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY 1
ORDER BY total_revenue DESC;


-- 3. Are certain genres more popular in specific countries?

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

