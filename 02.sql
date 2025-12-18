-- 1) Absolute and percentage changes of revenue over months.
--    Cumulative revenue over months.
WITH
	monthly AS (
		SELECT
			DATE_TRUNC('month', payment_date) AS month,
			SUM(amount) AS total
		FROM
			payment
		GROUP BY
			1
	),
	calc AS (
		SELECT
			month,
			total,
			LAG(total) OVER (
				ORDER BY
					month
			) AS prev_total
		FROM
			monthly
	)
SELECT
	month,
	total,
	total - prev_total AS mom_abs_change,
	ROUND(100.0 * (total - prev_total) / NULLIF(prev_total, 0), 2) AS mom_pct_change,
	SUM(total) OVER (
		ORDER BY
			month
	) AS cumulative_total
FROM
	calc
ORDER BY
	month;

-- 2) Customer Growth over Months.
WITH
	monthly_active_customers AS (
		SELECT
			DATE_TRUNC('month', payment_date) AS month,
			COUNT(DISTINCT customer_id) AS active_customers
		FROM
			payment
		GROUP BY
			1
	),
	calc AS (
		SELECT
			month,
			active_customers,
			LAG(active_customers) OVER (
				ORDER BY
					month
			) AS prev_month
		FROM
			monthly_active_customers
	)
SELECT
	month,
	active_customers,
	active_customers - prev_month AS active_customers_change,
	ROUND(100.0 * (active_customers - prev_month) / NULLIF(prev_month, 0), 2) AS active_customers_prc_change
FROM
	calc
ORDER BY
	month;

-- 3) Average revenue per customer monthly
WITH monthly AS(
	SELECT 
		DATE_TRUNC('month', payment_date) AS month,
		SUM(amount) AS revenue,
		COUNT(DISTINCT customer_id) AS customers
	FROM payment
	GROUP BY 1
)
SELECT 
	month,
	revenue,
	customers,
	ROUND(revenue / NULLIF(customers, 0), 2) AS revenue_per_customer
FROM monthly
ORDER BY month;

-- 4) Revenue by different stores and their respective MoM changes.
WITH
	prep_table AS (
		SELECT
			s.store_id,
			DATE_TRUNC('month', p.payment_date) AS month,
			SUM(p.amount) AS revenue
		FROM
			payment p
			JOIN staff st ON p.staff_id = st.staff_id
			JOIN store s ON st.store_id = s.store_id
		GROUP BY
			1,
			2
	)
SELECT
	store_id,
	month,
	revenue,
	revenue - LAG(revenue) OVER (
		PARTITION BY
			store_id
		ORDER BY
			month
	) AS MoM_change,
	ROUND(
		100.0 * (
			revenue - LAG(revenue) OVER (
				PARTITION BY
					store_id
				ORDER BY
					month
			)
		) / NULLIF(
			LAG(revenue) OVER (
				PARTITION BY
					store_id
				ORDER BY
					month
			),
			0
		),
		2
	) AS mom_pct_change
FROM
	prep_table
ORDER BY
	store_id,
	month;