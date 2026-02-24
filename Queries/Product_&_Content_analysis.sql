
-------------------------------------- PRODUCT & CONTET ANALYSIS -----------------------------------------

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

