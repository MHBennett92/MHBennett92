<div align="center">

# Michael H. Bennett

**FP&A Manager · Enterprise LookML Architect · BI Dashboard Designer**  
Austin, TX · [LinkedIn](https://linkedin.com/in/mhbennett)
*M.S. Technology Management · University of Arizona*

</div>

---

## About

I build governed, high-performance analytics products at the intersection of Finance and Technology—from data modeling in LookML to executive dashboards that drive daily decisions. My production work lives in private repositories to protect proprietary business data, but this portfolio captures the **architecture, patterns, and techniques** I use in real enterprise environments.

---

## Enterprise LookML architecture

### Hub → pillars → spokes

I designed and maintain a hub-and-spoke LookML ecosystem that scales across departments, data sources, and entities. The **Housing** project acts as the shared semantic layer hub; it connects directly to core pillar projects (**ECOM, EPICOR, Club Range, HR, Finance, IT**), and the remaining spoke projects sit under those pillars.

```
                         ┌──────────────────────┐
                         │      HOUSING         │
                         │ (Hub / Semantic Layer)│
                         └───────┬─────┬────┬────┘
                                 │     │    │
           ┌────────────┬────────┴─────┼────┴────────┬────────────┐
           │            │              │            │            │
    ┌──────▼──────┐┌────▼─────┐ ┌──────▼──────┐┌────▼─────┐┌─────▼─────┐
    │    ECOM     ││  EPICOR   │ │ Club Range  ││    HR    ││  FINANCE  │
    │  (Pillar)   ││ (Pillar)  │ │  (Pillar)   ││ (Pillar) ││  (Pillar) │
    └──────┬──────┘└────┬──────┘ └──────┬──────┘└────┬─────┘└─────┬─────┘
           │            │               │            │            │
           └────────────┼───────────────┘            │      ┌─────▼─────┐
                        │                            │      │   AMMO    │
          ┌─────────────┼────────────┐               │      │(Spoke/LHA)│
          │             │            │               │      └─────┬─────┘
   ┌──────▼──────┐ ┌────▼─────┐ ┌────▼─────┐  ┌──────▼─────┐      │
   │  MARKETING  │ │    CX    │ │   CET    │  │     HR     │┌─────▼─────┐
   │   (Spoke)   │ │ (Spoke)  │ │ (Spoke)  │  │  (Spoke)   ││    LHP    │
   └──────────────┘ └──────────┘ └──────────┘  └────────────┘│(Subsidiary)│
                                                             └────────────┘
   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
   │  LEO Sales   │ │  BD Sales   │ │  Salesforce  │
   │   (Spoke)    │ │   (Spoke)   │ │   (Spoke)    │
   └──────────────┘ └──────────────┘ └──────────────┘

    ┌──────────────────────┐
    │          IT          │
    │       (Pillar)       │
    └──────────┬───────────┘
               │
        ┌──────▼──────┐
        │ IT Data Team│
        │   (Spoke)   │
        └─────────────┘

Pillar Grouping:
Marketing, CX, CET, LEO Sales, Salesforce, and BD Sales are spokes under the ECOM, EPICOR, and Club Range pillars.
```

### Cross-project reuse and governance

I use `manifest.lkml` dependencies (hub → pillars/spokes) so KPI definitions and business logic remain consistent across projects. This allows each department to iterate independently while keeping a single source of truth for metrics.

---

## BI dashboard design (LookML)

I design Looker dashboards as **analytics products**: clear information hierarchy, fast load times, consistent KPI definitions, and guided drill paths. In my private repos, dashboards are version-controlled as `.dashboard.lookml` files and organized by backend (e.g., `/dashboards` for Azure SQL and `/dashboards_bq` for BigQuery).

### Dashboard design patterns I use

I build executive KPI boards, operational scorecards, and deep-dive pages that mix narrative text tiles, KPI "cards" (single-value), trend charts, and pivot/report-table tiles. I frequently use table calculations for goal/target overlays and progress-to-goal comparisons, plus consistent theming (colors, typography, spacing) and "newspaper" layouts for predictable scanning.

### Sanitized LookML dashboard example (E-Commerce)

Below is a sanitized structure based on my production **E-Commerce Executive Overview** and **Scorecard** dashboards. It demonstrates advanced layout techniques, YoY comparison logic, sparklines, and complex HTML/CSS text tiles.

```yaml
- dashboard: ecom_executive_overview
  title: E-commerce Executive Overview (Sanitized)
  layout: newspaper
  preferred_viewer: dashboards-next
  elements:
  - name: header_banner
    type: text
    body_text: |
      <div style="position: relative; display: flex; align-items: center; justify-content: space-between; padding: 20px; background: linear-gradient(to bottom, #002856, #001f42); border-radius: 4px;">
        <div style="position: relative; z-index: 2;">
          <p style="font-family: 'Helvetica Neue', Helvetica, sans-serif; font-size: 32px; font-weight: 700; color: #FFFFFF; margin: 0;">ENTERPRISE E-COMMERCE</p>
          <p style="font-family: 'Helvetica Neue', Helvetica, sans-serif; font-size: 16px; color: rgba(255, 255, 255, 0.85); margin: 8px 0 0 0;">Executive Performance Scorecard · 🟢 Live</p>
        </div>
      </div>
    row: 0
    col: 0
    width: 24
    height: 3

  - title: Sales (YoY)
    name: sales_yoy
    model: Ecom_Model
    explore: sales_orders_profit
    type: single_value
    fields: [sales.revenue_ytd, sales.revenue_prior_ytd, sales.created_month, sales.revenue]
    fill_fields: [sales.created_month]
    show_comparison: true
    comparison_label: YoY
    comparison_type: percent
    show_sparkline: true
    sparkline_field: sales.revenue
    row: 3
    col: 0
    width: 6
    height: 3

  - title: Sales Trend (Current vs Prior Year)
    name: sales_trend
    model: Ecom_Model
    explore: sales_orders_profit
    type: looker_line
    fields: [sales.created_month_name, sales.revenue_prior_period, sales.revenue_current_period]
    series_colors:
      sales.revenue_current_period: "#002856"
      sales.revenue_prior_period: "#7b8fa7"
    series_labels:
      sales.revenue_current_period: "Current Year"
      sales.revenue_prior_period: "Prior Year"
    x_axis_zoom: true
    y_axis_zoom: true
    row: 6
    col: 0
    width: 24
    height: 7

  - title: Sales by Product Category (Top 10)
    name: sales_by_category
    model: Ecom_Model
    explore: sales_orders_products
    type: looker_column
    fields: [products.category, sales.revenue]
    sorts: [sales.revenue desc]
    limit: 10
    show_value_labels: true
    series_colors:
      sales.revenue: "#002856"
    row: 13
    col: 0
    width: 12
    height: 7

  - title: Top Products by Revenue
    name: top_products
    model: Ecom_Model
    explore: sales_orders_products
    type: looker_grid
    fields: [products.name, sales.revenue, sales.quantity, sales.orders]
    show_totals: true
    table_theme: editable
    series_text_format:
      products.name: {align: left}
      sales.revenue: {align: center}
    row: 13
    col: 12
    width: 12
    height: 7
```

### Performance + maintainability

For dashboard performance at scale, I pair aggregate-aware explores with pre-aggregations (daily/weekly/monthly grains) and PDT strategies where needed. For maintainability, I keep KPI logic centralized in shared views, and use refinements/extends patterns so dashboard-level semantics don't diverge across departments.

---

## Advanced LookML techniques

I implement advanced patterns including Liquid templating (parameter-driven metrics/drills), derived tables and incremental PDTs, aggregate awareness with datagroups, refinements/extends for modular reuse, and role-based access controls with access grants/filters.

### Sanitized LookML view example (Club Range Logic)

The following sanitized view demonstrates a production-grade approach to handling membership activity and tiered logic within the **Club Range** pillar. It showcases SQL-based derived tables, Liquid-driven HTML formatting for member tiers, and parameter-based logic.

👉 **[View: portfolio_club_range_logic.view.lkml](lookml/portfolio_club_range_logic.view.lkml)**

---

### Sanitized LookML view example (Finance — P&L, EBITDA, Gross Margin)

The following sanitized view is derived from the private `staccatodw_finance` project and demonstrates real enterprise-grade financial metric logic. Key patterns showcased include:

- **P&L structure** — Revenue, COGS, Gross Margin, and Operating Expenses as typed `sum` and `number` measures
- **EBITDA** — Derived from Gross Margin minus Operating Expenses using measure references
- **Gross Margin %** — A `number` measure using `NULLIF` to guard against division by zero
- **GL Account categorization** — A `CASE` dimension dynamically bucketing GL account names into financial categories
- **KPI HTML formatting** — Liquid-driven color coding on revenue attainment vs. budget (green/red threshold logic)
- **Accounting Period dimension** — Supporting time-series P&L analysis

👉 **[View: portfolio_finance_logic.view.lkml](lookml/portfolio_finance_logic.view.lkml)**

---

### Sanitized LookML view example (HR/People — Headcount, Paylocity, Turnover)

The following sanitized view is derived from the private `staccatodw_hr` project and demonstrates enterprise-grade People Analytics logic. This view integrates directly with **Paylocity HRIS** and showcases patterns used in production for headcount tracking, turnover analysis, and organizational metrics.

Key patterns showcased include:

- **Headcount measures** — Active, terminated, FT/PT/contractor breakdowns using filtered `count_distinct`
- **Turnover & retention** — Voluntary/involuntary termination tracking, turnover rate calculations
- **Tenure analysis** — `DATEDIFF` logic for tenure in days/years, tenure bucketing with `type: tier`
- **Paylocity integration** — Employee ID, employee number, sync date dimensions for HRIS data lineage
- **Organizational hierarchy** — Department, team, job level, manager name dimensions with drill-down paths
- **Compensation analytics** — Total payroll, average/median salary measures (sanitized)
- **Span of control** — Manager count and employee-to-manager ratio
- **Employment classification** — Active/terminated status, FT/PT/contractor, exempt/non-exempt (FLSA)

👉 **[View: portfolio_people_organization_logic.view.lkm](lookml/portfolio_people_organization_logic.view.lkm)**

## Contact

If you want to talk enterprise Looker architecture, KPI governance, or building dashboard products that finance leaders actually trust:

- • GitHub: https://github.com/MHBennett92
- • LinkedIn: https://linkedin.com/in/mhbennett

---

*All repositories referenced are private. No proprietary data, schema names, internal URLs, or business-sensitive SQL has been disclosed—only architecture patterns and generalized examples.*
