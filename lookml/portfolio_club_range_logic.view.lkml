view: portfolio_club_range_logic {
  # Sanitized example of complex range usage logic for a portfolio
  # Demonstrates: Derived Tables, Liquid Logic, Tiering, and Measures with Filters

  derived_table: {
    sql:
      SELECT
        member_id,
        MIN(visit_date) as first_visit_date,
        COUNT(visit_id) as total_visits,
        SUM(case when activity_type = 'Range' then 1 else 0 end) as range_visits,
        SUM(case when activity_type = 'Training' then 1 else 0 end) as training_sessions
      FROM membership_activity_sanitized
      GROUP BY 1
    ;;
  }

  dimension: member_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.member_id ;;
  }

  parameter: activity_tier_selection {
    type: unquoted
    allowed_value: { label: "Standard" value: "standard" }
    allowed_value: { label: "Premium" value: "premium" }
    allowed_value: { label: "Elite" value: "elite" }
  }

  dimension: activity_tier {
    type: string
    sql:
      CASE
        WHEN ${TABLE}.total_visits > 50 THEN 'Elite'
        WHEN ${TABLE}.total_visits > 20 THEN 'Premium'
        ELSE 'Standard'
      END ;;
    html:
      {% if value == 'Elite' %}
        <span style="color: #FFD700; font-weight: bold;">{{ value }}</span>
      {% elsif value == 'Premium' %}
        <span style="color: #C0C0C0; font-weight: bold;">{{ value }}</span>
      {% else %}
        <span style="color: #CD7F32;">{{ value }}</span>
      {% endif %} ;;
  }

  dimension: years_since_first_visit {
    type: number
    sql: DATEDIFF('year', ${TABLE}.first_visit_date, CURRENT_DATE) ;;
  }

  dimension: is_active_member {
    type: yesno
    sql: ${TABLE}.total_visits > 0 AND ${years_since_first_visit} < 2 ;;
  }

  measure: total_member_count {
    type: count
    drill_fields: [member_id, activity_tier, total_visits]
  }

  measure: average_visits_per_member {
    type: average
    sql: ${TABLE}.total_visits ;;
    value_format_name: decimal_1
  }

  measure: elite_member_count {
    type: count
    filters: [activity_tier: "Elite"]
    description: "Counts members who have exceeded the Elite visit threshold (sanitized logic)"
  }
}
