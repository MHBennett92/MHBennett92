# =============================================================================
# Generic Membership Renewals View
# =============================================================================
# Illustrative LookML pattern for tracking subscription/membership renewal
# transactions, payment processing outcomes, and billing data from a
# recurring-payments platform.
#
# Demonstrates:
#   - Subscription transaction modeling (renewals, first-bills, retries)
#   - Payment gateway response tracking (authorization, AVS, CVV codes)
#   - Bill-to address and contact info as dimensions
#   - Revenue fields (subtotal, tax, total, subscription amount)
#   - Subscription lifecycle timestamps (creation, end date, payment date)
#
# All table, column, and payment-processor field names use generic
# placeholders. No proprietary data or system specifics from any employer
# are included.
# =============================================================================

view: membership_renewals {
  sql_table_name: analytics.membership_renewals ;;

  # ---------------------------------------------------------------------------
  # KEYS
  # ---------------------------------------------------------------------------

  dimension: subscription_transaction_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.subscription_transaction_id ;;
    label: "Subscription Transaction ID"
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}.account_number ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}.account_type ;;
  }

  dimension: active_flag {
    type: string
    sql: ${TABLE}.active_flag ;;
  }

  dimension: member_record_id {
    type: number
    sql: ${TABLE}.member_record_id ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.invoice_number ;;
  }

  # ---------------------------------------------------------------------------
  # PAYMENT GATEWAY FIELDS (generic placeholder names)
  # ---------------------------------------------------------------------------

  dimension: gateway_customer_profile_id {
    type: string
    sql: ${TABLE}.gateway_customer_profile_id ;;
  }

  dimension: gateway_payment_profile_id {
    type: string
    sql: ${TABLE}.gateway_payment_profile_id ;;
  }

  dimension: authorization_code {
    type: string
    sql: ${TABLE}.authorization_code ;;
  }

  dimension: avs_result_code {
    type: string
    sql: ${TABLE}.avs_result_code ;;
    label: "AVS Result Code"
  }

  dimension: cvv_result_code {
    type: string
    sql: ${TABLE}.cvv_result_code ;;
    label: "CVV Result Code"
  }

  dimension: cavv_result_code {
    type: string
    sql: ${TABLE}.cavv_result_code ;;
    label: "CAVV Result Code"
  }

  dimension: response_code {
    type: string
    sql: ${TABLE}.response_code ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}.transaction_id ;;
  }

  # ---------------------------------------------------------------------------
  # BILL-TO DETAILS
  # ---------------------------------------------------------------------------

  dimension: bill_to_first_name {
    type: string
    sql: ${TABLE}.bill_to_first_name ;;
  }

  dimension: bill_to_last_name {
    type: string
    sql: ${TABLE}.bill_to_last_name ;;
  }

  dimension: bill_to_address {
    type: string
    sql: ${TABLE}.bill_to_address ;;
  }

  dimension: bill_to_city {
    type: string
    sql: ${TABLE}.bill_to_city ;;
  }

  dimension: bill_to_state {
    type: string
    sql: ${TABLE}.bill_to_state ;;
  }

  dimension: bill_to_zip {
    type: string
    sql: ${TABLE}.bill_to_zip ;;
  }

  dimension: bill_to_phone {
    type: string
    sql: ${TABLE}.bill_to_phone ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}.user_email ;;
  }

  # ---------------------------------------------------------------------------
  # SUBSCRIPTION / PLAN
  # ---------------------------------------------------------------------------

  dimension: plan_name {
    type: string
    sql: ${TABLE}.plan_name ;;
  }

  dimension: pay_frequency {
    type: string
    sql: ${TABLE}.pay_frequency ;;
  }

  dimension: subscription_id {
    type: number
    sql: ${TABLE}.subscription_id ;;
  }

  dimension: completed_subscription {
    type: number
    sql: ${TABLE}.completed_subscription ;;
  }

  # ---------------------------------------------------------------------------
  # FINANCIAL FIELDS
  # ---------------------------------------------------------------------------

  dimension: subscription_amount {
    type: number
    sql: ${TABLE}.subscription_amount ;;
    value_format_name: usd
  }

  dimension: subtotal {
    type: number
    sql: ${TABLE}.subtotal ;;
    value_format_name: usd
  }

  dimension: tax {
    type: number
    sql: ${TABLE}.tax ;;
    value_format_name: usd
  }

  dimension: total {
    type: number
    sql: ${TABLE}.total ;;
    value_format_name: usd
  }

  # ---------------------------------------------------------------------------
  # TIMESTAMPS
  # ---------------------------------------------------------------------------

  dimension_group: creation {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.creation_date ;;
    convert_tz: no
  }

  dimension_group: modification {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.modification_date ;;
    convert_tz: no
  }

  dimension_group: payment_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.payment_datetime ;;
    convert_tz: no
  }

  dimension_group: subscription_start {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.subscription_start_date ;;
  }

  dimension_group: subscription_end {
    type: time
    timeframes: [date, week, month, quarter, year]
    sql: ${TABLE}.subscription_end_date ;;
  }

  # ---------------------------------------------------------------------------
  # KEY MEASURES
  # ---------------------------------------------------------------------------

  measure: count {
    type: count
    drill_fields: [bill_to_first_name, bill_to_last_name, plan_name]
    label: "Count of Renewals"
  }

  measure: total_renewal_revenue {
    type: sum
    sql: ${total} ;;
    value_format_name: usd_0
    label: "Total Renewal Revenue"
    description: "Sum of total renewal transaction amounts."
  }

  measure: total_subscription_amount {
    type: sum
    sql: ${subscription_amount} ;;
    value_format_name: usd_0
    label: "Total Subscription Amount"
    description: "Sum of gross subscription amounts."
  }

  measure: average_subscription_amount {
    type: average
    sql: ${subscription_amount} ;;
    value_format_name: usd_0
    label: "Average Subscription Amount"
  }

  measure: successful_renewal_count {
    type: count
    filters: [response_code: "1"]
    label: "Successful Renewal Count"
    description: "Count of renewals where the gateway response indicates success."
  }

  measure: failed_renewal_count {
    type: count
    filters: [response_code: "-1,2,3"]
    label: "Failed Renewal Count"
    description: "Count of renewals where the gateway response indicates failure."
  }

  measure: renewal_success_rate {
    type: number
    sql:
      CASE
        WHEN ${count} > 0
        THEN ${successful_renewal_count} * 1.0 / ${count}
        ELSE NULL
      END ;;
    value_format_name: percent_2
    label: "Renewal Success Rate"
    description: "Percentage of renewal attempts that succeeded."
  }
}
