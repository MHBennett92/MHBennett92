
view: portfolio_finance_logic {
  # Sanitized example of enterprise finance logic derived from staccatodw_finance
  # Demonstrates: P&L structures, EBITDA, Gross Margin %, GL Account categorization, and KPI HTML formatting

  sql_table_name: financial_transactions_sanitized ;;

  # ========================================
  # DIMENSIONS
  # ========================================

  dimension: transaction_id {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}.transaction_id ;;
  }

  dimension: accounting_period {
    type: string
    sql: ${TABLE}.accounting_period ;;
    description: "Fiscal period (e.g., 2025-Q1, 2025-01) for P&L time-series analysis"
  }

  dimension_group: transaction_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.transaction_date ;;
  }

  dimension: gl_account_name {
    type: string
    sql: ${TABLE}.gl_account_name ;;
    description: "General Ledger account name (e.g., 'Sales Revenue - Product', 'COGS - Materials')"
  }

  dimension: gl_account_number {
    type: string
    sql: ${TABLE}.gl_account_number ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: financial_category {
    type: string
    sql:
      CASE
        WHEN ${gl_account_name} LIKE '%Sales%' OR ${gl_account_name} LIKE '%Revenue%' THEN 'Revenue'
        WHEN ${gl_account_name} LIKE '%COGS%' OR ${gl_account_name} LIKE '%Cost of Goods%' THEN 'COGS'
        WHEN ${gl_account_name} LIKE '%Operating%' OR ${gl_account_name} LIKE '%OpEx%' THEN 'OpEx'
        WHEN ${gl_account_name} LIKE '%Tax%' THEN 'Tax'
        WHEN ${gl_account_name} LIKE '%Depreciation%' OR ${gl_account_name} LIKE '%Amortization%' THEN 'D&A'
        WHEN ${gl_account_name} LIKE '%Interest%' THEN 'Interest'
        ELSE 'Other'
      END ;;
    description: "Dynamically categorizes GL accounts into P&L line items"
  }

  # ========================================
  # BASE MEASURES
  # ========================================

  measure: total_amount {
    type: sum
    sql: ${TABLE}.amount ;;
    value_format_name: usd
    description: "Total transaction amount (unfiltered)"
  }

  measure: transaction_count {
    type: count
    description: "Number of financial transactions"
  }

  # ========================================
  # P&L METRICS (Income Statement)
  # ========================================

  measure: sales_revenue {
    type: sum
    sql: ${TABLE}.amount ;;
    filters: [financial_category: "Revenue"]
    value_format_name: usd
    description: "Total sales revenue"
    drill_fields: [accounting_period, department, gl_account_name, sales_revenue]
  }

  measure: cogs {
    type: sum
    sql: ${TABLE}.amount ;;
    filters: [financial_category: "COGS"]
    value_format_name: usd
    description: "Cost of Goods Sold"
    drill_fields: [accounting_period, gl_account_name, cogs]
  }

  measure: gross_margin {
    type: number
    sql: ${sales_revenue} - ${cogs} ;;
    value_format_name: usd
    description: "Gross Profit = Revenue - COGS"
  }

  measure: gross_margin_percentage {
    type: number
    sql: CASE WHEN ${sales_revenue} = 0 THEN NULL ELSE (${gross_margin} / NULLIF(${sales_revenue}, 0)) END ;;
    value_format_name: percent_1
    description: "Gross Margin % = Gross Profit / Revenue"
  }

  measure: operating_expenses {
    type: sum
    sql: ${TABLE}.amount ;;
    filters: [financial_category: "OpEx"]
    value_format_name: usd
    description: "Operating Expenses (excluding COGS, D&A, Interest, Tax)"
    drill_fields: [department, gl_account_name, operating_expenses]
  }

  measure: depreciation_amortization {
    type: sum
    sql: ${TABLE}.amount ;;
    filters: [financial_category: "D&A"]
    value_format_name: usd
    description: "Depreciation & Amortization"
  }

  measure: ebitda {
    label: "EBITDA"
    type: number
    sql: ${gross_margin} - ${operating_expenses} ;;
    value_format_name: usd
    description: "Earnings Before Interest, Taxes, Depreciation, and Amortization = Gross Margin - OpEx"
  }

  measure: ebit {
    label: "EBIT"
    type: number
    sql: ${ebitda} - ${depreciation_amortization} ;;
    value_format_name: usd
    description: "Earnings Before Interest and Taxes = EBITDA - D&A"
  }

  measure: interest_expense {
    type: sum
    sql: ${TABLE}.amount ;;
    filters: [financial_category: "Interest"]
    value_format_name: usd
  }

  measure: tax_expense {
    type: sum
    sql: ${TABLE}.amount ;;
    filters: [financial_category: "Tax"]
    value_format_name: usd
  }

  measure: net_income {
    type: number
    sql: ${ebit} - ${interest_expense} - ${tax_expense} ;;
    value_format_name: usd
    description: "Net Income = EBIT - Interest - Tax"
  }

  # ========================================
  # KPIs & ANALYTICS
  # ========================================

  measure: revenue_per_transaction {
    type: number
    sql: ${sales_revenue} / NULLIF(${transaction_count}, 0) ;;
    value_format_name: usd
  }

  measure: ebitda_margin {
    type: number
    sql: CASE WHEN ${sales_revenue} = 0 THEN NULL ELSE (${ebitda} / NULLIF(${sales_revenue}, 0)) END ;;
    value_format_name: percent_1
    description: "EBITDA Margin % = EBITDA / Revenue"
  }

  measure: net_profit_margin {
    type: number
    sql: CASE WHEN ${sales_revenue} = 0 THEN NULL ELSE (${net_income} / NULLIF(${sales_revenue}, 0)) END ;;
    value_format_name: percent_1
  }

  measure: revenue_target_attainment {
    type: number
    sql: ${sales_revenue} / NULLIF(10000000, 0) ;; # Sanitized $10M annual target placeholder
    value_format_name: percent_0
    html:
      {% if value >= 1 %}
        <span style="color: #008000; font-weight: bold;">✅ {{ rendered_value }}</span>
      {% elsif value >= 0.75 %}
        <span style="color: #FFA500; font-weight: bold;">⚠️ {{ rendered_value }}</span>
      {% else %}
        <span style="color: #FF0000;">❌ {{ rendered_value }}</span>
      {% endif %} ;;
    description: "Revenue vs. annual budget target with green/yellow/red thresholds"
  }
}
