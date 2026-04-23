-- ============================================================
-- Rolling 12-Month Revenue with Year-over-Year Comparison
-- ============================================================
-- Generic ANSI SQL tutorial pattern demonstrating:
--   • DATE_TRUNC for monthly grouping
--   • LAG window function for prior-year comparison
--   • ROWS BETWEEN ... PRECEDING for rolling aggregates
--   • SAFE division to avoid divide-by-zero errors
--
-- This is an illustrative pattern based on publicly documented
-- SQL techniques. It uses placeholder table and column names
-- (orders, net_revenue, etc.) and does not reference any real
-- dataset, warehouse schema, or production system.
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('MONTH', order_date) AS revenue_month,
        SUM(net_revenue)                AS monthly_revenue,
        COUNT(DISTINCT order_id)        AS order_count,
        COUNT(DISTINCT customer_id)     AS unique_customers
    FROM orders
    WHERE order_date >= DATEADD(MONTH, -24, CURRENT_DATE)
      AND order_status NOT IN ('Cancelled', 'Voided')
    GROUP BY DATE_TRUNC('MONTH', order_date)
),

with_yoy AS (
    SELECT
        revenue_month,
        monthly_revenue,
        order_count,
        unique_customers,

        -- Prior-year same-month using a 12-period LAG
        LAG(monthly_revenue, 12) OVER (ORDER BY revenue_month)
            AS prior_year_revenue,

        -- Year-over-year growth percentage with safe division
        CASE
            WHEN LAG(monthly_revenue, 12) OVER (ORDER BY revenue_month) > 0
            THEN (monthly_revenue
                  - LAG(monthly_revenue, 12) OVER (ORDER BY revenue_month))
                 * 1.0
                 / LAG(monthly_revenue, 12) OVER (ORDER BY revenue_month)
        END AS yoy_growth_pct,

        -- Rolling 12-month aggregate for smoothed trend analysis
        SUM(monthly_revenue) OVER (
            ORDER BY revenue_month
            ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
        ) AS rolling_12m_revenue
    FROM monthly_revenue
)

SELECT
    revenue_month,
    monthly_revenue,
    prior_year_revenue,
    yoy_growth_pct,
    rolling_12m_revenue,
    order_count,
    unique_customers,
    CASE
        WHEN unique_customers > 0
        THEN monthly_revenue * 1.0 / unique_customers
    END AS revenue_per_customer
FROM with_yoy
WHERE revenue_month >= DATEADD(MONTH, -12, CURRENT_DATE)
ORDER BY revenue_month DESC;
