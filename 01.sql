-- 1) Overall performance
SELECT
	COUNT(*) AS total_transactions,
	SUM(amount) AS total_revenue,
	ROUND(AVG(amount), 2) AS avg_transaction
FROM
	payment;

-- 2) Performance over time
SELECT
  DATE_TRUNC('month', payment_date) AS month,
  SUM(amount)                       AS revenue,
  COUNT(*)                          AS transactions
FROM payment
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY DATE_TRUNC('month', payment_date);

-- 3) Revenue per Category
SELECT
	cat.name AS category,
	SUM(p.amount) AS revenue
FROM
	payment p
	JOIN rental r ON p.rental_id = r.rental_id
	JOIN inventory i ON r.inventory_id = i.inventory_id
	JOIN film_category fc ON i.film_id = fc.film_id
	JOIN category cat ON fc.category_id = cat.category_id
GROUP BY
	cat.name
ORDER BY
	revenue DESC;

-- 4) Top 10 Customers by Sales
SELECT
	c.customer_id,
	CONCAT_WS(' ', c.first_name, c.last_name) AS full_name,
	SUM(p.amount) AS revenue
FROM
	customer c
	JOIN payment p ON p.customer_id = c.customer_id
GROUP BY
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY
	revenue DESC
LIMIT
	10;

-- 5) Top 5 Customers per Store
WITH
	customer_store_rev AS (
		SELECT
			s.store_id,
			c.customer_id,
			SUM(p.amount) AS revenue
		FROM
			payment p
			JOIN customer c ON p.customer_id = c.customer_id
			JOIN staff st ON p.staff_id = st.staff_id
			JOIN store s ON st.store_id = s.store_id
		GROUP BY
			s.store_id,
			c.customer_id
	),
	ranked AS (
		SELECT
			*,
			RANK() OVER (
				PARTITION BY
					store_id
				ORDER BY
					revenue DESC
			) AS rnk
		FROM
			customer_store_rev
	)
SELECT
	*
FROM
	ranked
WHERE
	rnk <= 5
ORDER BY
	store_id,
	rnk;

-- 6) Percent of Total Revenue by Category
SELECT
  cat.name AS category,
  SUM(p.amount) AS revenue,
  ROUND(
    100.0 * SUM(p.amount)
    / SUM(SUM(p.amount)) OVER (),
    2
  ) AS pct_of_total
FROM payment p
JOIN rental r        ON p.rental_id = r.rental_id
JOIN inventory i     ON r.inventory_id = i.inventory_id
JOIN film_category fc ON i.film_id = fc.film_id
JOIN category cat     ON fc.category_id = cat.category_id
GROUP BY cat.name
ORDER BY revenue DESC;

-- 7) Total, open, and closed rentals
SELECT
  COUNT(*)                                      AS total_rentals,
  SUM(CASE WHEN return_date IS NULL THEN 1 ELSE 0 END) AS open_rentals,
  SUM(CASE WHEN return_date IS NOT NULL THEN 1 ELSE 0 END) AS closed_rentals
FROM rental;

-- 8) MoM change of revenue.
WITH
	monthly AS (
		SELECT
			DATE_TRUNC('month', payment_date) AS MONTH,
			SUM(amount) AS revenue
		FROM
			payment
		GROUP BY
			1
	)
SELECT
	MONTH,
	revenue,
	revenue - LAG(revenue) OVER (
		ORDER BY
			MONTH
	) AS mom_change
FROM
	monthly
ORDER BY
	MONTH;