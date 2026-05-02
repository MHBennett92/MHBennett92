# =============================================================================
# Generic Membership Analytics Dashboard
# =============================================================================
# Illustrative LookML dashboard pattern for a subscription / membership business.
# Demonstrates ARR tracking, churn analysis, renewals performance, and goal
# attainment across membership tiers.
#
# Maps to:
#   - membership_vs_goals.view.lkml   (ARR, goals, tier performance)
#   - membership_churn.view.lkml      (active counts, churn, net adds)
#   - membership_renewals.view.lkml   (renewal revenue, success rate)
#
# All tier names, rates, targets, and table references are generic placeholders.
# No proprietary data or business logic from any employer is included.
# =============================================================================

- dashboard: membership_analytics
  title: Membership Analytics
  description: "Subscription membership ARR, churn, renewals, and goal attainment"
  refresh: 1 hour
  filters_bar_collapsed: true
  filters_location: top
  preferred_slug: membership_analytics_dashboard
  layout: newspaper

  tabs:
  - name: ''
    label: ''

  elements:

  # ---------------------------------------------------------------------------
  # HEADER BANNER
  # ---------------------------------------------------------------------------
  - name: dashboard_header
    type: text
    title_text: ''
    subtitle_text: ''
    body_text: |
      <div style="position:relative; display:flex; align-items:center;
                  justify-content:space-between; padding:20px;
                  background:linear-gradient(to bottom, #002856, #001f42);
                  border-radius:4px; overflow:hidden;">
        <div style="position:relative; z-index:2;">
          <p style="font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;
                    font-size:32px; font-weight:700; color:#FFFFFF;
                    margin:0; line-height:1;">MEMBERSHIP ANALYTICS</p>
          <p style="font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;
                    font-size:16px; font-weight:400; color:rgba(255,255,255,0.85);
                    margin:8px 0 0 0; letter-spacing:1px;">
            Subscription Performance Dashboard</p>
        </div>
        <div style="position:absolute; right:20px; top:50%;
                    transform:translateY(-50%);
                    font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;
                    font-size:90px; font-weight:800;
                    color:rgba(255,255,255,0.08); white-space:nowrap;
                    user-select:none; pointer-events:none;">
          MEMBERSHIP</div>
      </div>
    row: 0
    col: 0
    width: 24
    height: 3

  # ---------------------------------------------------------------------------
  # SECTION LABEL — ARR & GOALS
  # ---------------------------------------------------------------------------
  - name: section_arr_goals
    type: text
    title_text: ''
    subtitle_text: ''
    body_text: |
      <div style="background-color:#001740; color:#FFFFFF; padding:12px;
                  border-radius:4px; text-align:left;
                  font-family:'Open Sans','Helvetica Neue',Helvetica,Arial,sans-serif;
                  font-size:16px; font-weight:bold;">
        Membership ARR &amp; Goal Attainment
      </div>
    row: 3
    col: 0
    width: 24
    height: 2

  # ---------------------------------------------------------------------------
  # TILE 1 — Total Members & ARR Summary Table
  # Replaces: "Total Members ARR" tile (vwtrimemberships explore)
  # Source: membership_vs_goals (ARR, tier counts, goal attainment)
  # ---------------------------------------------------------------------------
  - title: Total Members & ARR by Tier
    name: total_members_arr
    model: membership_analytics
    explore: membership_vs_goals
    type: looker_grid
    fields:
      - membership_vs_goals.membership_tier
      - membership_vs_goals.total_current_active_primary_members
      - membership_vs_goals.membership_forecast_revenue
      - membership_vs_goals.goal_attainment_pct
    filters:
      membership_vs_goals.membership_category: "Standard,Premium,Enterprise,Basic"
    sorts:
      - membership_vs_goals.total_current_active_primary_members desc
    limit: 500
    total: true
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    size_to_fit: true
    table_theme: unstyled
    header_text_alignment: center
    header_font_size: 12
    rows_font_size: 12
    show_totals: true
    show_row_totals: true
    series_labels:
      membership_vs_goals.membership_tier: Tier
      membership_vs_goals.total_current_active_primary_members: Paying Members
      membership_vs_goals.membership_forecast_revenue: Estimated ARR
      membership_vs_goals.goal_attainment_pct: Goal Attainment %
    series_value_format:
      membership_vs_goals.membership_forecast_revenue:
        name: usd0
        decimals: 0
        format_string: "$#,##0"
        label: U.S. Dollars (0 decimals)
      membership_vs_goals.goal_attainment_pct:
        name: percent_1
        decimals: 1
        format_string: "0.0%"
    series_text_format:
      membership_vs_goals.total_current_active_primary_members:
        align: center
      membership_vs_goals.membership_forecast_revenue:
        align: right
    show_comparison: true
    comparison_type: change
    comparison_reverse_colors: false
    custom_color_enabled: true
    defaults_version: 1
    title_hidden: true
    listen:
      Tier Filter: membership_vs_goals.membership_tier
      Location Filter: membership_vs_goals.membership_category
    row: 5
    col: 0
    width: 12
    height: 4

  # ---------------------------------------------------------------------------
  # TILE 2 — Current ARR vs Annual Target
  # Replaces: "Current ARR vs Target" tile
  # Source: membership_vs_goals (total_annual_goal, membership_forecast_revenue)
  # ---------------------------------------------------------------------------
  - title: Current ARR vs Annual Target
    name: current_arr_vs_target
    model: membership_analytics
    explore: membership_vs_goals
    type: looker_grid
    fields:
      - membership_vs_goals.membership_forecast_revenue
      - membership_vs_goals.total_annual_goal
      - membership_vs_goals.goal_attainment_pct
    filters:
      membership_vs_goals.membership_category: "Standard,Premium,Enterprise,Basic"
    limit: 500
    dynamic_fields:
      - category: table_calculation
        expression: "${membership_vs_goals.total_annual_goal} - ${membership_vs_goals.membership_forecast_revenue}"
        label: Remaining to Goal
        value_format_name: usd0
        _kind_hint: measure
        table_calculation: remaining_to_goal
        type_hint: number
    hidden_fields:
      - membership_vs_goals.membership_forecast_revenue
    show_view_names: false
    theme: contemporary
    layout: fixed
    header_font_size: 12
    body_font_size: 12
    show_tooltip: true
    show_highlight: true
    transpose: true
    series_labels:
      membership_vs_goals.membership_forecast_revenue: Current ARR
      membership_vs_goals.total_annual_goal: Annual Target ARR
      remaining_to_goal: Remaining to Goal
      membership_vs_goals.goal_attainment_pct: Goal Attainment %
    series_value_format:
      membership_vs_goals.membership_forecast_revenue:
        name: usd0
        decimals: 0
        format_string: "$#,##0"
      membership_vs_goals.total_annual_goal:
        name: usd0
        decimals: 0
        format_string: "$#,##0"
      remaining_to_goal:
        name: usd0
        decimals: 0
        format_string: "$#,##0"
    show_comparison: true
    comparison_type: change
    custom_color_enabled: true
    defaults_version: 1
    title_hidden: true
    listen:
      Tier Filter: membership_vs_goals.membership_tier
    row: 5
    col: 12
    width: 8
    height: 3

  # ---------------------------------------------------------------------------
  # TILE 3 — Monthly ARR Target Pacing
  # Replaces: "Monthly Target Copy" / "AVG New ARR Month" tiles
  # Source: membership_vs_goals (total_monthly_goal, membership_forecast_revenue)
  # ---------------------------------------------------------------------------
  - title: Monthly ARR Target Pacing
    name: monthly_arr_pacing
    model: membership_analytics
    explore: membership_vs_goals
    type: marketplace_viz_report_table::report_table_visualization
    fields:
      - membership_vs_goals.membership_forecast_revenue
      - membership_vs_goals.total_monthly_goal
    filters:
      membership_vs_goals.membership_category: "Standard,Premium,Enterprise,Basic"
    limit: 500
    dynamic_fields:
      - category: table_calculation
        expression: "${membership_vs_goals.total_monthly_goal} - ${membership_vs_goals.membership_forecast_revenue}"
        label: Additional ARR Needed This Month
        value_format_name: usd0
        _kind_hint: measure
        table_calculation: monthly_gap
        type_hint: number
      - category: table_calculation
        expression: "${membership_vs_goals.membership_forecast_revenue} / extract_months(now())"
        label: YTD Avg Additional ARR / Month
        value_format_name: usd0
        _kind_hint: measure
        table_calculation: ytd_avg_arr_month
        type_hint: number
    hidden_fields:
      - membership_vs_goals.membership_forecast_revenue
    show_view_names: false
    theme: traditional
    layout: fixed
    header_font_size: 12
    body_font_size: 12
    show_tooltip: true
    show_highlight: true
    label_monthly_gap: Additional ARR Needed This Month
    label_ytd_avg_arr_month: YTD Avg ARR / Month
    label_membership_vs_goals_total_monthly_goal: Monthly Target
    show_comparison: true
    comparison_type: change
    comparison_label: vs. Monthly Target
    custom_color_enabled: true
    single_value_title: Monthly ARR Pacing
    defaults_version: 0
    title_hidden: true
    listen:
      Tier Filter: membership_vs_goals.membership_tier
      Location Filter: membership_vs_goals.membership_category
    row: 5
    col: 20
    width: 4
    height: 3

  # ---------------------------------------------------------------------------
  # TILE 4 — Total Estimated ARR by Tier (Bar Chart)
  # Replaces: "Total Est ARR by Type" bar chart tile
  # Source: membership_vs_goals (membership_forecast_revenue, membership_tier)
  # ---------------------------------------------------------------------------
  - title: Total Estimated ARR by Tier
    name: total_arr_by_tier
    model: membership_analytics
    explore: membership_vs_goals
    type: looker_bar
    fields:
      - membership_vs_goals.membership_tier
      - membership_vs_goals.membership_forecast_revenue
    filters:
      membership_vs_goals.membership_category: "Standard,Premium,Enterprise,Basic"
    sorts:
      - membership_vs_goals.membership_forecast_revenue desc
    limit: 500
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    legend_position: center
    point_style: none
    show_value_labels: true
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    ordering: none
    show_null_labels: false
    show_totals_labels: false
    font_size: 14
    series_colors:
      membership_vs_goals.membership_forecast_revenue: '#002856'
    series_labels:
      membership_vs_goals.membership_tier: Tier
      membership_vs_goals.membership_forecast_revenue: Estimated ARR
    series_value_format:
      membership_vs_goals.membership_forecast_revenue:
        name: usd0
        decimals: 0
        format_string: "$#,##0"
    y_axes:
      - label: ''
        orientation: top
        series:
          - id: membership_vs_goals.membership_forecast_revenue
            name: Estimated ARR
            show_labels: false
            show_values: true
        tick_density: custom
        tick_density_custom: 8
        type: linear
    x_axis_zoom: false
    y_axis_zoom: false
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    defaults_version: 1
    title_hidden: true
    listen:
      Tier Filter: membership_vs_goals.membership_tier
      Location Filter: membership_vs_goals.membership_category
    row: 8
    col: 12
    width: 12
    height: 5

  # ---------------------------------------------------------------------------
  # SECTION LABEL — CHURN & NET ADDS
  # ---------------------------------------------------------------------------
  - name: section_churn
    type: text
    title_text: ''
    subtitle_text: ''
    body_text: |
      <div style="background-color:#001740; color:#FFFFFF; padding:12px;
                  border-radius:4px; text-align:left;
                  font-family:'Open Sans','Helvetica Neue',Helvetica,Arial,sans-serif;
                  font-size:16px; font-weight:bold;">
        Membership Churn &amp; Net Adds
      </div>
    row: 13
    col: 0
    width: 24
    height: 2

  # ---------------------------------------------------------------------------
  # TILE 5 — Active Members by Month & Tier (Pivoted Bar/Grid)
  # Replaces: "Added Club Members by Month" tile
  # Source: membership_churn (total_active_memberships, snapshot_month, membership_tier)
  # ---------------------------------------------------------------------------
  - title: Active Members by Month & Tier
    name: active_members_by_month
    model: membership_analytics
    explore: membership_churn
    type: looker_grid
    fields:
      - membership_churn.snapshot_month
      - membership_churn.membership_tier
      - membership_churn.total_active_memberships
      - membership_churn.total_added_memberships
    pivots:
      - membership_churn.snapshot_month
    fill_fields:
      - membership_churn.snapshot_month
    filters:
      membership_churn.snapshot_date: this year
    sorts:
      - membership_churn.snapshot_month
      - membership_churn.membership_tier desc
    limit: 500
    total: true
    dynamic_fields:
      - _kind_hint: measure
        _type_hint: number
        based_on: membership_churn.total_active_memberships
        calculation_type: running_total
        category: table_calculation
        label: Running Total Active Memberships
        source_field: membership_churn.total_active_memberships
        table_calculation: running_total_active
        value_format_name: ''
        is_disabled: true
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    size_to_fit: true
    table_theme: transparent
    header_text_alignment: center
    header_font_size: 12
    rows_font_size: 12
    show_totals: true
    show_row_totals: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    show_x_axis_label: false
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    stacking: normal
    legend_position: center
    point_style: circle
    show_value_labels: true
    label_density: 25
    show_null_labels: true
    show_totals_labels: true
    label_color: white
    interpolation: linear
    series_labels:
      membership_churn.total_active_memberships: Active Members
      membership_churn.total_added_memberships: New Members
      membership_churn.snapshot_month: Month
      membership_churn.membership_tier: Tier
    series_cell_visualizations:
      membership_churn.total_active_memberships:
        is_active: false
    series_text_format:
      membership_churn.total_active_memberships:
        align: right
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    defaults_version: 1
    title_hidden: true
    listen:
      Tier Filter: membership_churn.membership_tier
      Location Filter: membership_churn.home_location
    row: 15
    col: 0
    width: 24
    height: 4

  # ---------------------------------------------------------------------------
  # TILE 6 — Churn Rate & Net Adds Summary
  # Replaces: "Added Club Members by Month Active" tile
  # Source: membership_churn (average_churn_rate, net_adds, total_removed_memberships)
  # ---------------------------------------------------------------------------
  - title: Churn Rate & Net Adds by Tier
    name: churn_net_adds
    model: membership_analytics
    explore: membership_churn
    type: looker_grid
    fields:
      - membership_churn.membership_tier
      - membership_churn.total_active_memberships
      - membership_churn.total_added_memberships
      - membership_churn.total_removed_memberships
      - membership_churn.net_adds
      - membership_churn.average_churn_rate
    filters:
      membership_churn.snapshot_date: this year
    sorts:
      - membership_churn.membership_tier asc
    limit: 500
    total: true
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    size_to_fit: true
    table_theme: unstyled
    header_text_alignment: center
    header_font_size: 12
    rows_font_size: 12
    show_totals: true
    show_row_totals: true
    series_labels:
      membership_churn.membership_tier: Tier
      membership_churn.total_active_memberships: Active Members
      membership_churn.total_added_memberships: Gross Adds
      membership_churn.total_removed_memberships: Cancellations
      membership_churn.net_adds: Net Adds
      membership_churn.average_churn_rate: Avg Churn Rate
    series_value_format:
      membership_churn.average_churn_rate:
        name: percent_1
        decimals: 1
        format_string: "0.0%"
    series_text_format:
      membership_churn.net_adds:
        align: center
      membership_churn.average_churn_rate:
        align: center
    enable_conditional_formatting: true
    conditional_formatting:
      - type: greater than
        value: 0
        background_color: ''
        font_color: '#1E8A44'
        color_application:
          collection_id: default
          palette_id: default-diverging-0
        bold: false
        italic: false
        strikethrough: false
        fields:
          - membership_churn.net_adds
      - type: less than
        value: 0
        background_color: ''
        font_color: '#E02926'
        bold: false
        italic: false
        strikethrough: false
        fields:
          - membership_churn.net_adds
    custom_color_enabled: true
    show_single_value_title: true
    show_comparison: false
    defaults_version: 1
    title_hidden: true
    listen:
      Tier Filter: membership_churn.membership_tier
      Location Filter: membership_churn.home_location
    row: 19
    col: 0
    width: 24
    height: 5

  # ---------------------------------------------------------------------------
  # SECTION LABEL — RENEWALS & REVENUE
  # ---------------------------------------------------------------------------
  - name: section_renewals
    type: text
    title_text: ''
    subtitle_text: ''
    body_text: |
      <div style="background-color:#001740; color:#FFFFFF; padding:12px;
                  border-radius:4px; text-align:left;
                  font-family:'Open Sans','Helvetica Neue',Helvetica,Arial,sans-serif;
                  font-size:16px; font-weight:bold;">
        Membership Renewals &amp; Revenue
      </div>
    row: 24
    col: 0
    width: 24
    height: 2

  # ---------------------------------------------------------------------------
  # TILE 7 — New Month Renewals ARR
  # Replaces: "New Month Memberships ARR" tile
  # Source: membership_renewals (total_renewal_revenue, count, renewal_success_rate)
  # ---------------------------------------------------------------------------
  - title: New Month Renewals ARR
    name: new_month_renewals_arr
    model: membership_analytics
    explore: membership_renewals
    type: marketplace_viz_report_table::report_table_visualization
    fields:
      - membership_renewals.total_renewal_revenue
      - membership_renewals.count
      - membership_renewals.renewal_success_rate
    filters:
      membership_renewals.payment_date: this month
    limit: 500
    dynamic_fields:
      - category: table_calculation
        expression: "${membership_renewals.total_renewal_revenue} / ${membership_renewals.count}"
        label: Avg ARR per Renewal
        value_format_name: usd0
        _kind_hint: measure
        table_calculation: avg_arr_per_renewal
        type_hint: number
    hidden_fields:
      - membership_renewals.count
    show_view_names: false
    theme: traditional
    layout: fixed
    header_font_size: 12
    body_font_size: 12
    show_tooltip: true
    show_highlight: true
    label_membership_renewals_total_renewal_revenue: New Renewal Revenue (MTD)
    label_avg_arr_per_renewal: Avg ARR per Renewal
    label_membership_renewals_renewal_success_rate: Renewal Success Rate
    show_comparison: false
    comparison
