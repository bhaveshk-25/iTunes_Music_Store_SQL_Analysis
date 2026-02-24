
------------------------------------ SALES & REVENUE ANALYSIS ----------------------------------------

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

SELECT e.employee_id, 
	   e.employee_name, 
	   SUM(i.total) AS total_revenue_contribution
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

