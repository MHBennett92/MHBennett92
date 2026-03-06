view: portfolio_epicor_logic {
  sql_table_name: `your_project.your_dataset.epicor_order_summary` ;;

  # ────────────────────────────
  # PRIMARY KEY
  # ────────────────────────────

  dimension: order_line_pk {
    type: string
    primary_key: yes
    hidden: yes
    sql: CONCAT(${order_num}, '_', ${order_line}) ;;
    description: "Composite key to ensure uniqueness at the line-item level."
  }

  # ────────────────────────────
  # FLAGS & STATUS
  # ────────────────────────────

  dimension: is_open_order {
    type: yesno
    sql: ${TABLE}.Order_Open_Flag = 'True' ;;
    label: "Is Open Order"
    description: "Indicates if the order is still active/open."
    group_label: "Status"
  }

  dimension: is_void_order {
    type: yesno
    sql: ${TABLE}.Order_Void_Flag = 'True' ;;
    label: "Is Voided"
    description: "Indicates if the order has been voided."
    group_label: "Status"
  }

  # ────────────────────────────
  # CUSTOMER & GEOGRAPHY
  # ────────────────────────────

  dimension: customer_id {
    type: string
    sql: ${TABLE}.Customer_ID ;;
    label: "Customer Identifier"
    group_label: "Customer"
  }

  dimension: customer_region {
    type: string
    sql: ${TABLE}.Customer_State ;;
    map_layer_name: us_states
    label: "Customer Region (State)"
    group_label: "Customer"
  }

  # ────────────────────────────
  # TEMPORAL DIMENSIONS
  # ────────────────────────────

  dimension_group: order_date {
    type: time
    sql: CAST(${TABLE}.Order_Date AS date) ;;
    timeframes: [raw, date, week, month, quarter, year, month_name]
    label: "Order"
    description: "The date the transaction was finalized in the ERP system."
  }

  # ────────────────────────────
  # PRODUCT LOGIC (Advanced Patterns)
  # ────────────────────────────

  dimension: product_model {
    type: string
    sql: ${TABLE}.Model_Name ;;
    label: "Core Product Model"
    group_label: "Product"
  }

  dimension: tier_classification {
    type: string
    sql:
      CASE
        WHEN ${TABLE}.Line_Description LIKE '%TIER 1%' THEN 'Standard'
        WHEN ${TABLE}.Line_Description LIKE '%TIER 2%' THEN 'Professional'
        WHEN ${TABLE}.Line_Description LIKE '%TIER 3%' THEN 'Enterprise'
        ELSE 'Bespoke/Other'
      END ;;
    label: "Product Tier"
    description: "Logic-based classification derived from line item descriptions."
    group_label: "Product"
  }

  dimension: strategic_product_group {
    type: string
    sql:
      CASE
        WHEN ${TABLE}.Category_Description LIKE '%Main Line%' THEN 'Core Product'
        WHEN ${TABLE}.Category_Description LIKE '%Support%' OR ${TABLE}.Category_Description LIKE '%Service%' THEN 'Recurring/Service'
        ELSE 'Ancillary'
      END ;;
    label: "Strategic Grouping"
    description: "High-level categorization for executive reporting."
    group_label: "Product"
  }

  # ────────────────────────────
  # QUANTITY & REVENUE LOGIC
  # ────────────────────────────

  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}.Qty_Ordered ;;
    label: "Quantity Ordered"
    group_label: "Financials"
  }

  dimension: gross_revenue {
    type: number
    sql: ${TABLE}.Unit_Price * ${TABLE}.Qty_Ordered ;;
    label: "Gross Transaction Value"
    description: "Value before discounts (Price × Qty)."
    value_format_name: usd
    group_label: "Financials"
  }

  dimension: net_revenue {
    type: number
    sql: (${TABLE}.Unit_Price * ${TABLE}.Qty_Ordered) - COALESCE(${TABLE}.Discount_Amount, 0) ;;
    label: "Net Transaction Value"
    description: "Gross value minus applied discounts."
    value_format_name: usd
    group_label: "Financials"
  }

  # ────────────────────────────
  # MEASURES (Executive KPIs)
  # ────────────────────────────

  measure: total_orders {
    type: count_distinct
    sql: ${order_num} ;;
    label: "Total Orders"
    description: "Unique count of order identifiers."
  }

  measure: total_gross_revenue {
    type: sum
    sql: ${gross_revenue} ;;
    label: "Total Gross Revenue"
    value_format_name: usd_0
  }

  measure: total_net_revenue {
    type: sum
    sql: ${net_revenue} ;;
    label: "Total Net Revenue"
    value_format_name: usd_0
  }

  measure: average_order_value {
    type: number
    sql: ${total_net_revenue} / NULLIF(${total_orders}, 0) ;;
    label: "Average Order Value (AOV)"
    value_format_name: usd
  }

  # Helper dimensions for measures
  dimension: order_num { type: string sql: ${TABLE}.Order_Number ;; hidden: yes }
  dimension: order_line { type: string sql: ${TABLE}.Order_Line_Number ;; hidden: yes }
}
