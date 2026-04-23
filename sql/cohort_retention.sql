-- ============================================================
-- Customer Cohort Retention & Cumulative Revenue
-- ============================================================
-- Generic ANSI SQL tutorial pattern demonstrating:
--   • Self-join pattern for cohort bucketing
--   • DATEDIFF for period indexing
--   • Cumulative window aggregation
--   • Retention rate calculation
--
-- This is an illustrative pattern based on publicly documented
-- cohort analysis techniques. Table names (orders) are generic
-- placeholders and do not reference any real dataset or system.
-- ============================================================

WITH customer_first_order AS (
    SELECT
        customer_id,
        DATE_TRUNC('MONTH', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE order_status NOT IN ('Cancelled', 'Voided')
    GROUP BY customer_id
),

cohort_activity AS (
    SELECT
        c.cohort_month,
        DATEDIFF(
            'MONTH',
            c.cohort_month,
            DATE_TRUNC('MONTH', o.order_date)
        ) AS periods_since_first,
        COUNT(DISTINCT o.customer_id) AS active_customers,
        SUM(o.net_revenue)            AS cohort_revenue,
        COUNT(DISTINCT o.order_id)    AS cohort_orders
    FROM orders o
    JOIN customer_first_order c
      ON o.customer_id = c.customer_id
    WHERE o.order_status NOT IN ('Cancelled', 'Voided')
    GROUP BY
        c.cohort_month,
        DATEDIFF(
            'MONTH',
            c.cohort_month,
            DATE_TRUNC('MONTH', o.order_date)
        )
),

cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS cohort_customers
    FROM customer_first_order
    GROUP BY cohort_month
)

SELECT
    a.cohort_month,
    s.cohort_customers AS original_cohort_size,
    a.periods_since_first,
    a.active_customers,
    a.cohort_revenue,
    a.cohort_orders,

    -- Retention rate vs. original cohort size
    CASE
        WHEN s.cohort_customers > 0
        THEN a.active_customers * 1.0 / s.cohort_customers
    END AS retention_rate,

    -- Revenue per retained customer in the period
    CASE
        WHEN a.active_customers > 0
        THEN a.cohort_revenue * 1.0 / a.active_customers
    END AS revenue_per_active_customer,

    -- Cumulative revenue per cohort over time
    SUM(a.cohort_revenue) OVER (
        PARTITION BY a.cohort_month
        ORDER BY a.periods_since_first
    ) AS cumulative_cohort_revenue

FROM cohort_activity a
JOIN cohort_size s
  ON a.cohort_month = s.cohort_month
ORDER BY
    a.cohort_month,
    a.periods_since_first;
