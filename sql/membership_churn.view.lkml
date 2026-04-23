# =============================================================================
# Generic Membership Churn View
# =============================================================================
# Illustrative LookML pattern for tracking membership churn in any
# subscription or membership-based business (gyms, clubs, SaaS, co-working,
# streaming services, etc.).
#
# Demonstrates:
#   - Snapshot-based churn tracking (daily/monthly point-in-time counts)
#   - Active vs. inactive membership dimensions
#   - Gross and net adds, cancellations, and churn rate measures
#   - Rolling year-to-date cancellation totals
#   - Location/site normalization via CASE statement
#
# All table, column, and category names are generic placeholders. No
# proprietary schemas, data, or business logic from any employer included.
# =============================================================================

view: membership_churn {
  sql_table_name: analytics.membership_churn_snapshot ;;

  # ---------------------------------------------------------------------------
  # KEYS & TIME
  # ---------------------------------------------------------------------------

  dimension: snapshot_date {
    primary_key: yes
    type: date
    sql: ${TABLE}.snapshot_date ;;
    label: "Snapshot Date"
    description: "The date of the churn snapshot."
    hidden: yes
  }

  dimension_group: snapshot {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.snapshot_date ;;
    convert_tz: no
    label: "Snapshot"
  }

  # ---------------------------------------------------------------------------
  # MEMBERSHIP DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: membership_tier {
    group_label: "Membership Information"
    type: string
    sql: ${TABLE}.membership_tier ;;
    label: "Membership Tier"
    description: "Membership tier or plan name (e.g., Basic, Standard, Premium)."
  }

  dimension: active_count {
    group_label: "Membership Information"
    type: number
    sql: ${TABLE}.active_count ;;
    label: "Active Count"
    description: "Number of active memberships at snapshot date."
  }

  dimension: inactive_count {
    group_label: "Membership Information"
    type: number
    sql: ${TABLE}.inactive_count ;;
    label: "Inactive Count"
    description: "Number of inactive memberships at snapshot date."
  }

  dimension: added_count {
    group_label: "Membership Information"
    type: number
    sql: ${TABLE}.added_count ;;
    label: "Added Count"
    description: "New memberships added in the snapshot period."
  }

  # ---------------------------------------------------------------------------
  # LOCATION / SITE NORMALIZATION
  # ---------------------------------------------------------------------------

  dimension: home_location {
    group_label: "Location Information"
    type: string
    sql:
      CASE
        WHEN ${TABLE}.home_location LIKE '%North%' THEN 'North Location'
        WHEN ${TABLE}.home_location LIKE '%South%' THEN 'South Location'
        ELSE 'Other'
      END ;;
    label: "Home Location"
    description: "Normalized home location of the membership."
  }

  # ---------------------------------------------------------------------------
  # CHURN DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: removed_count {
    group_label: "Churn Information"
    type: number
    sql: ${TABLE}.removed_count ;;
    label: "Removed Count"
    description: "Memberships cancelled or removed in the snapshot period."
  }

  dimension: removed_count_year_total {
    group_label: "Churn Information"
    type: number
    sql: ${TABLE}.removed_count_ytd ;;
    label: "Removed Count (YTD)"
    description: "Year-to-date total memberships removed."
  }

  dimension: churn_rate_percentage {
    group_label: "Churn Information"
    type: number
    sql: ${TABLE}.churn_rate_percentage ;;
    value_format_name: percent_2
    label: "Churn Rate Percentage"
    description: "Percentage of memberships that have churned in the period."
  }

  # ---------------------------------------------------------------------------
  # KEY METRICS
  # ---------------------------------------------------------------------------

  measure: count {
    group_label: "Key Metrics"
    type: count
    label: "Count of Records"
    description: "Total count of snapshot records."
  }

  measure: total_active_memberships {
    group_label: "Key Metrics"
    type: sum
    sql: ${active_count} ;;
    label: "Total Active Memberships"
    description: "Total number of active memberships."
  }

  measure: total_added_memberships {
    group_label: "Key Metrics"
    type: sum
    sql: ${added_count} ;;
    label: "Total Added Memberships"
    description: "Gross new memberships added."
  }

  measure: total_removed_memberships {
    group_label: "Key Metrics"
    type: sum
    sql: ${removed_count} ;;
    label: "Total Removed Memberships"
    description: "Gross memberships cancelled or removed."
  }

  measure: net_adds {
    group_label: "Key Metrics"
    type: number
    sql: ${total_added_memberships} - ${total_removed_memberships} ;;
    label: "Net Adds"
    description: "Net change in memberships (adds minus removals)."
  }

  measure: average_churn_rate {
    group_label: "Key Metrics"
    type: average
    sql: ${churn_rate_percentage} ;;
    value_format_name: percent_2
    label: "Average Churn Rate"
    description: "Average churn rate across the selected period."
  }
}
