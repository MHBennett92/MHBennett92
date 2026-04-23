# =============================================================================
# Generic POS Sales Order Transaction View (Finance-Facing)
# =============================================================================
# Illustrative LookML pattern for a Point-of-Sale (POS) sales-order
# transaction report used by a finance team to reconcile daily activity
# at an on-site retail location associated with a membership business
# (e.g., a pro shop, club boutique, or gym retail counter).
#
# The model is designed to support a "POS Sales for Finance" style
# dashboard with:
#   - A daily Sales Order Transaction Report (previous day by default)
#   - KPI single-value tiles: Total SO count, Grand Total, Total Invoice Amount
#   - Filters / listeners for Location, Order Status, and Date
#   - Separate views of Invoices vs. Refunds, and Open / Deposit weekly orders
#
# Demonstrates:
#   - Line-item sales modeling (quantity, list price, extended price)
#   - Invoice total, tax, grand total, and discount calculations
#   - Transaction-type classification (sale / refund / deposit)
#   - Location, station, and sales-rep dimensions
#   - Order-status flags (open, closed, refund, cancelled)
#   - Finance-ready measures (gross revenue, tax collected, discount %)
#
# All product IDs, station names, locations, and schemas are generic
# placeholders. No proprietary POS catalog, pricing, or transaction
# data from any employer is included.
# =============================================================================

view: pos_sales_order_transaction_report {
  sql_table_name: analytics.pos_sales_order_transaction_report ;;

  # ---------------------------------------------------------------------------
  # KEYS & TIME
  # ---------------------------------------------------------------------------

  dimension: sales_order_line_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.sales_order_line_id ;;
    label: "Sales Order Line ID"
  }

  dimension: sales_order_id {
    type: string
    sql: ${TABLE}.sales_order_id ;;
    label: "Sales Order ID"
  }

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, day_of_week, day_of_month, month, month_name, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.created_date ;;
    label: "Order Created"
  }

  # ---------------------------------------------------------------------------
  # CUSTOMER / MEMBERSHIP DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: customer_name {
    type: string
    sql: ${TABLE}.customer_name ;;
    label: "Customer Name"
  }

  dimension: membership_number {
    type: string
    sql: ${TABLE}.membership_number ;;
    label: "Membership Number"
    description: "Membership identifier on the order, if the customer is a member."
  }

  dimension: membership_type {
    type: string
    sql: ${TABLE}.membership_type ;;
    label: "Membership Type"
  }

  dimension_group: membership_start {
    type: time
    timeframes: [raw, date, month, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.membership_start_date ;;
    label: "Membership Start"
  }

  # ---------------------------------------------------------------------------
  # ORDER / TRANSACTION DIMENSIONS
  # ---------------------------------------------------------------------------

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
    label: "Location"
    description: "Physical retail / pro-shop location (e.g., North, South)."
  }

  dimension: station {
    type: string
    sql: ${TABLE}.station ;;
    label: "Station"
    description: "POS terminal or station where the order was rung up."
  }

  dimension: sales_rep {
    type: string
    sql: ${TABLE}.sales_rep ;;
    label: "Sales Rep"
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}.transaction_type ;;
    label: "Transaction Type"
    description: "Sale, Refund, Deposit, or Adjustment."
  }

  dimension: status {
    type: string
    sql: ${TABLE}.order_status ;;
    label: "Order Status"
    description: "Open, Closed, Refunded, Cancelled, etc."
  }

  dimension: product_id {
    type: string
    sql: ${TABLE}.product_id ;;
    label: "Product ID"
  }

  # ---------------------------------------------------------------------------
  # PRICING DIMENSIONS (line-level)
  # ---------------------------------------------------------------------------

  dimension: list_price {
    type: number
    sql: ${TABLE}.list_price ;;
    value_format_name: usd
    label: "List Price"
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}.unit_price ;;
    value_format_name: usd
    label: "Unit Price"
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
    label: "Quantity"
  }

  dimension: extended_price {
    type: number
    sql: ${TABLE}.extended_price ;;
    value_format_name: usd
    label: "Extended Price"
    description: "Unit price × quantity (line-level)."
  }

  dimension: line_tax_amount {
    type: number
    sql: ${TABLE}.line_tax_amount ;;
    value_format_name: usd
    label: "Line Tax Amount"
  }

  # ---------------------------------------------------------------------------
  # FLAGS
  # ---------------------------------------------------------------------------

  dimension: is_refund {
    type: yesno
    sql: UPPER(COALESCE(${TABLE}.transaction_type, '')) = 'REFUND' ;;
    label: "Is Refund"
  }

  dimension: is_cancelled {
    type: yesno
    sql: UPPER(COALESCE(${TABLE}.order_status, '')) IN ('CANCELLED', 'VOIDED') ;;
    label: "Is Cancelled"
  }

  dimension: is_open {
    type: yesno
    sql: UPPER(COALESCE(${TABLE}.order_status, '')) = 'OPEN' ;;
    label: "Is Open"
  }

  dimension: is_deposit {
    type: yesno
    sql: UPPER(COALESCE(${TABLE}.transaction_type, '')) = 'DEPOSIT' ;;
    label: "Is Deposit"
  }

  # ---------------------------------------------------------------------------
  # FINANCE-FACING MEASURES
  # Mirrors KPI tiles used on a daily POS-for-Finance dashboard:
  # Total SO Count, Grand Total, Total Invoice Amount, Total Sales Tax.
  # ---------------------------------------------------------------------------

  measure: count {
    type: count
    label: "Line Count"
    description: "Total number of order lines (not distinct orders)."
  }

  measure: distinct_so {
    type: count_distinct
    sql: ${sales_order_id} ;;
    label: "Total Sales Order Number"
    description: "Distinct sales orders. Headline KPI on the finance dashboard."
  }

  measure: total_total_listprice {
    type: sum
    sql: ${list_price} * ${quantity} ;;
    value_format_name: usd_0
    label: "Total List Price"
  }

  measure: total_total_discount {
    type: sum
    sql: (${list_price} - ${unit_price}) * ${quantity} ;;
    value_format_name: usd_0
    label: "Total Discount"
  }

  measure: total_invoice_amt {
    type: sum
    sql: ${extended_price} ;;
    value_format_name: usd_0
    label: "Total Invoice Amount"
    description: "Sum of extended price across all lines, pre-tax."
  }

  measure: total_sales_tax {
    type: sum
    sql: ${line_tax_amount} ;;
    value_format_name: usd_0
    label: "Total Sales Tax"
  }

  measure: grand_total {
    type: number
    sql: COALESCE(${total_invoice_amt}, 0) + COALESCE(${total_sales_tax}, 0) ;;
    value_format_name: usd_0
    label: "Grand Total"
    description: "Invoice amount + sales tax. Reconciled daily against POS batch totals."
  }

  measure: total_refunds {
    type: sum
    sql: ${extended_price} ;;
    filters: [is_refund: "yes"]
    value_format_name: usd_0
    label: "Total Refunds"
  }

  measure: net_revenue {
    type: number
    sql: ${total_invoice_amt} - COALESCE(${total_refunds}, 0) ;;
    value_format_name: usd_0
    label: "Net Revenue (Invoice − Refunds)"
  }

  measure: discount_percent {
    type: number
    sql:
      CASE
        WHEN ${total_total_listprice} > 0
        THEN ${total_total_discount} * 1.0 / ${total_total_listprice}
      END ;;
    value_format_name: percent_2
    label: "Discount %"
    description: "Total discount as a percentage of list-price gross."
  }

  measure: average_order_value {
    type: number
    sql:
      CASE
        WHEN ${distinct_so} > 0
        THEN ${total_invoice_amt} * 1.0 / ${distinct_so}
      END ;;
    value_format_name: usd_0
    label: "Average Order Value (AOV)"
  }
}
