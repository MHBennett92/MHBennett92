-- ============================================================
-- Budget vs. Actual Variance Analysis
-- ============================================================
-- Generic ANSI SQL tutorial pattern demonstrating:
--   • Full outer join between budget and actuals
--   • Absolute and percentage variance calculation
--   • Favorable / Unfavorable variance flagging by account type
--   • Threshold-based exception classification
--
-- This is an illustrative pattern for FP&A variance reporting
-- using generic placeholder table names (budget, actuals,
-- chart_of_accounts). It does not reference any real dataset,
-- GL structure, or production system.
-- ============================================================

WITH budget_actuals AS (
    SELECT
        COALESCE(b.account_id, a.account_id)         AS account_id,
        COALESCE(b.fiscal_period, a.fiscal_period)   AS fiscal_period,
        COALESCE(b.cost_center, a.cost_center)       AS cost_center,
        COALESCE(b.budget_amount, 0)                 AS budget_amount,
        COALESCE(a.actual_amount, 0)                 AS actual_amount
    FROM budget b
    FULL OUTER JOIN actuals a
      ON  b.account_id    = a.account_id
      AND b.fiscal_period = a.fiscal_period
      AND b.cost_center   = a.cost_center
),

with_variance AS (
    SELECT
        ba.account_id,
        coa.account_name,
        coa.account_type,       -- 'Revenue' or 'Expense'
        ba.fiscal_period,
        ba.cost_center,
        ba.budget_amount,
        ba.actual_amount,

        -- Absolute variance (actual − budget)
        (ba.actual_amount - ba.budget_amount) AS variance_amount,

        -- Percentage variance with safe division
        CASE
            WHEN ba.budget_amount <> 0
            THEN (ba.actual_amount - ba.budget_amount) * 1.0 / ba.budget_amount
        END AS variance_pct,

        -- Favorable / Unfavorable flag:
        --   Revenue: actual > budget is favorable
        --   Expense: actual < budget is favorable
        CASE
            WHEN coa.account_type = 'Revenue'
                 AND ba.actual_amount >= ba.budget_amount THEN 'Favorable'
            WHEN coa.account_type = 'Revenue'
                 AND ba.actual_amount <  ba.budget_amount THEN 'Unfavorable'
            WHEN coa.account_type = 'Expense'
                 AND ba.actual_amount <= ba.budget_amount THEN 'Favorable'
            WHEN coa.account_type = 'Expense'
                 AND ba.actual_amount >  ba.budget_amount THEN 'Unfavorable'
            ELSE 'Neutral'
        END AS variance_flag

    FROM budget_actuals ba
    JOIN chart_of_accounts coa
      ON ba.account_id = coa.account_id
)

SELECT
    account_id,
    account_name,
    account_type,
    fiscal_period,
    cost_center,
    budget_amount,
    actual_amount,
    variance_amount,
    variance_pct,
    variance_flag,

    -- Exception classification using a 10% / 25% threshold
    CASE
        WHEN variance_pct IS NULL THEN 'No Budget'
        WHEN ABS(variance_pct) < 0.10 THEN 'On Track'
        WHEN ABS(variance_pct) < 0.25 THEN 'Review'
        ELSE 'Investigate'
    END AS exception_status

FROM with_variance
ORDER BY
    fiscal_period DESC,
    ABS(variance_amount) DESC;
