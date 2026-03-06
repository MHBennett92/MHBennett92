view: portfolio_ecom_logic {
  sql_table_name: `your_project.your_dataset.ecom_sales_summary` ;;

  # ───────────────────────────────────────────────────────────
  # Core Dimensions
  # ───────────────────────────────────────────────────────────

  dimension: pk_order_product {
    primary_key: yes
    hidden: yes
    type: string
    sql: CONCAT(${TABLE}.Order_ID, '_', ${TABLE}.Sku) ;;
    description: "Composite key at Order ✕ SKU granularity"
  }

  dimension_group: order_created {
    type: time
    timeframes: [raw, date, day_of_month, week, month, quarter, year]
    convert_tz: yes
    datatype: datetime
    sql: ${TABLE}.date_created ;;
    label: "Order Date"
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}.product_category_calc ;;
    label: "Product Category"
    description: "Standardized category mapping for profitability analysis."
  }

  # ───────────────────────────────────────────────────────────
  # Advanced Measure Logic (Sanitized Patterns)
  # ───────────────────────────────────────────────────────────

  measure: total_revenue {
    type: sum
    sql: ${TABLE}.Ext_Price_After_Discount ;;
    value_format_name: usd_0
    label: "Total Revenue"
    filters: [TABLE.BC_Name: "-Shipping Charge"]
  }

  measure: gross_profit {
    type: sum
    sql: ${TABLE}.Profit_Total ;;
    value_format_name: usd_0
    label: "Gross Profit"
  }

  measure: gross_margin_pct {
    type: number
    sql: ${gross_profit} / NULLIF(${total_revenue}, 0) ;;
    value_format_name: percent_2
    label: "Gross Margin %"
  }

  # ───────────────────────────────────────────────────────────
  # Time-Series / YTD Comparison Patterns
  # ───────────────────────────────────────────────────────────

  measure: gross_profit_ytd {
    label: "Gross Profit YTD"
    type: number
    sql: SUM(CASE WHEN ${order_created_raw} >= DATE_TRUNC(CURRENT_DATE(), YEAR) AND ${order_created_raw} <= CURRENT_TIMESTAMP() THEN ${TABLE}.Profit_Total ELSE 0 END) ;;
    value_format_name: usd_0
  }

  measure: gross_profit_prior_ytd {
    label: "Gross Profit Prior YTD"
    type: number
    sql: SUM(CASE WHEN ${order_created_raw} >= DATE_ADD(DATE_TRUNC(CURRENT_DATE(), YEAR), INTERVAL -1 YEAR) AND ${order_created_raw} <= DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL -1 YEAR) THEN ${TABLE}.Profit_Total ELSE 0 END) ;;
    value_format_name: usd_0
  }

  measure: gross_profit_yoy_change_pct {
    label: "Gross Profit YoY % Change (YTD)"
    type: number
    sql: (${gross_profit_ytd} - ${gross_profit_prior_ytd}) / NULLIF(${gross_profit_prior_ytd}, 0) ;;
    value_format_name: percent_2
  }

  # ───────────────────────────────────────────────────────────
  # Filtered Metric Patterns
  # ───────────────────────────────────────────────────────────

  measure: net_profit_category_a {
    label: "Net Profit – Category A"
    type: sum
    sql: ${TABLE}.Profit_Total ;;
    filters: [product_category: "Category A"]
    value_format_name: usd_0
  }

  measure: net_profit_category_b {
    label: "Net Profit – Category B"
    type: sum
    sql: ${TABLE}.Profit_Total ;;
    filters: [product_category: "Category B"]
    value_format_name: usd_0
  }
}
