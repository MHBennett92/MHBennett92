# =============================================================================
# Generic Membership Performance vs. Goals View
# =============================================================================
# Illustrative LookML pattern for tracking membership sales performance
# against annual and monthly goals in any subscription or membership-based
# business.
#
# Demonstrates:
#   - Per-tier filtered measures for goal tracking
#   - Annual-to-monthly goal derivation
#   - Tier-specific forecast revenue using rate tables
#   - Remaining-to-goal gap calculation
#
# All tier names, rates, and table references are generic placeholders.
# No proprietary data, tier structure, pricing, or goals from any employer
# are included.
# =============================================================================

view: membership_vs_goals {
  sql_table_name: analytics.membership_vs_goals ;;

  # ---------------------------------------------------------------------------
  # KEYS & TIME
  # ---------------------------------------------------------------------------

  dimension: period_month {
    primary_key: yes
    type: date_month
    sql: ${TABLE}.period_month ;;
    label: "Month"
    description: "The month of the goal."
    hidden: yes
  }

  # ---------------------------------------------------------------------------
  # MEMBERSHIP DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: membership_category {
    group_label: "Membership Information"
    type: string
    sql: ${TABLE}.membership_category ;;
    label: "Membership Category"
    description: "Membership roll-up category."
  }

  dimension: membership_tier {
    group_label: "Membership Information"
    type: string
    sql: ${TABLE}.membership_tier ;;
    label: "Membership Tier"
    description: "Atomic membership tier (e.g., Basic, Standard, Premium, Enterprise)."
  }

  dimension: current_active_primary_members {
    group_label: "Membership Information"
    type: number
    sql: ${TABLE}.current_active_primary_members ;;
    value_format_name: decimal_0
    label: "Current Active Primary Members"
    description: "Current count of active primary members for this category."
  }

  # ---------------------------------------------------------------------------
  # GOAL DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: annual_goal {
    group_label: "Goal Information"
    type: number
    sql: ${TABLE}.annual_goal ;;
    value_format_name: decimal_0
    label: "Annual Goal"
    description: "Annual member-count goal for the tier."
  }

  dimension: monthly_goal {
    group_label: "Goal Information"
    type: number
    sql: ${TABLE}.monthly_goal ;;
    value_format_name: decimal_0
    label: "Monthly Goal"
    description: "Monthly goal derived from annual goal."
  }

  dimension: remaining_memberships_to_goal {
    group_label: "Goal Information"
    type: number
    sql: ${TABLE}.remaining_memberships_to_goal ;;
    value_format_name: decimal_0
    label: "Remaining Memberships to Goal"
    description: "Gap between current count and monthly goal."
  }

  # ---------------------------------------------------------------------------
  # TIER-FILTERED KPI MEASURES
  # Generic example tiers — replace with actual tiers when deploying
  # ---------------------------------------------------------------------------

  measure: basic_tier_count {
    group_label: "Membership KPIs"
    type: sum
    sql: ${current_active_primary_members} ;;
    filters: [membership_tier: "Basic"]
    value_format_name: decimal_0
    label: "Basic Tier Members"
    description: "Active primary members on the Basic tier."
  }

  measure: standard_tier_count {
    group_label: "Membership KPIs"
    type: sum
    sql: ${current_active_primary_members} ;;
    filters: [membership_tier: "Standard"]
    value_format_name: decimal_0
    label: "Standard Tier Members"
    description: "Active primary members on the Standard tier."
  }

  measure: premium_tier_count {
    group_label: "Membership KPIs"
    type: sum
    sql: ${current_active_primary_members} ;;
    filters: [membership_tier: "Premium"]
    value_format_name: decimal_0
    label: "Premium Tier Members"
    description: "Active primary members on the Premium tier."
  }

  measure: enterprise_tier_count {
    group_label: "Membership KPIs"
    type: sum
    sql: ${current_active_primary_members} ;;
    filters: [membership_tier: "Enterprise"]
    value_format_name: decimal_0
    label: "Enterprise Tier Members"
    description: "Active primary members on the Enterprise tier."
  }

  # ---------------------------------------------------------------------------
  # FORECAST REVENUE BY TIER RATE
  # Rates shown are illustrative placeholders only
  # ---------------------------------------------------------------------------

  measure: membership_forecast_revenue {
    group_label: "Financial KPIs"
    type: sum
    sql:
      CASE
        WHEN ${membership_category} = 'Basic'       THEN ${current_active_primary_members} * 100
        WHEN ${membership_category} = 'Standard'    THEN ${current_active_primary_members} * 250
        WHEN ${membership_category} = 'Premium'     THEN ${current_active_primary_members} * 500
        WHEN ${membership_category} = 'Enterprise'  THEN ${current_active_primary_members} * 1500
        ELSE 0
      END / 4 ;;
    value_format_name: usd_0
    label: "Membership Forecast Revenue"
    description: "Forecast revenue using category-specific placeholder rates, divided by 4 (quarterly view)."
  }

  # ---------------------------------------------------------------------------
  # ROLLUP KEY METRICS
  # ---------------------------------------------------------------------------

  measure: count {
    group_label: "Key Metrics"
    type: count
    label: "Count of Rows"
    description: "Total number of rows."
  }

  measure: total_current_active_primary_members {
    group_label: "Key Metrics"
    type: sum
    sql: ${current_active_primary_members} ;;
    value_format_name: decimal_0
    label: "Total Current Active Primary Members"
    description: "Total active primary members across all categories."
  }

  measure: total_annual_goal {
    group_label: "Key Metrics"
    type: sum
    sql: ${annual_goal} ;;
    value_format_name: decimal_0
    label: "Total Annual Goal"
    description: "Total annual goal across all membership categories."
  }

  measure: total_monthly_goal {
    group_label: "Key Metrics"
    type: sum
    sql: ${monthly_goal} ;;
    value_format_name: decimal_0
    label: "Total Monthly Goal"
    description: "Total monthly goal across all membership categories."
  }

  measure: goal_attainment_pct {
    group_label: "Key Metrics"
    type: number
    sql:
      CASE
        WHEN ${total_monthly_goal} > 0
        THEN ${total_current_active_primary_members} * 1.0 / ${total_monthly_goal}
        ELSE NULL
      END ;;
    value_format_name: percent_1
    label: "Goal Attainment %"
    description: "Current members as a percentage of total monthly goal."
  }
}
