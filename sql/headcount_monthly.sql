-- ============================================================
-- Point-in-Time Monthly Headcount
-- ============================================================
-- Generic ANSI SQL tutorial pattern demonstrating:
--   • Month-end calendar generation with a date dimension
--   • Point-in-time active-employee calculation
--   • Month-over-month delta using LAG
--
-- This is an illustrative pattern for headcount reporting
-- using generic placeholder tables (dim_date, dim_employee).
-- It does not reference any real HR dataset, HRIS system,
-- or employer data.
-- ============================================================

WITH month_ends AS (
    SELECT DISTINCT
        -- Take the last calendar date of each month
        LAST_DAY(calendar_date) AS month_end
    FROM dim_date
    WHERE calendar_date >= DATEADD(YEAR, -2, CURRENT_DATE)
      AND calendar_date <= CURRENT_DATE
),

active_at_month_end AS (
    SELECT
        m.month_end,
        COUNT(DISTINCT e.employee_id) AS active_headcount
    FROM month_ends m
    LEFT JOIN dim_employee e
      ON e.hire_date <= m.month_end
     AND (e.termination_date IS NULL
          OR e.termination_date > m.month_end)
    GROUP BY m.month_end
),

with_mom_delta AS (
    SELECT
        month_end,
        active_headcount,
        LAG(active_headcount) OVER (ORDER BY month_end)
            AS prior_month_headcount,
        active_headcount
            - LAG(active_headcount) OVER (ORDER BY month_end)
            AS mom_change,
        CASE
            WHEN LAG(active_headcount) OVER (ORDER BY month_end) > 0
            THEN (active_headcount
                  - LAG(active_headcount) OVER (ORDER BY month_end))
                 * 1.0
                 / LAG(active_headcount) OVER (ORDER BY month_end)
        END AS mom_change_pct
    FROM active_at_month_end
)

SELECT
    month_end,
    active_headcount,
    prior_month_headcount,
    mom_change,
    mom_change_pct
FROM with_mom_delta
ORDER BY month_end DESC;
