<div align="center">

# Michael H. Bennett

**FP&A Manager · Enterprise LookML Architect · BI Dashboard Designer**  
Austin, TX · [LinkedIn](https://linkedin.com/in/mhbennett) · [GitHub](https://github.com/MHBennett92)  
*M.S. Technology Management (4.0 GPA) · University of Arizona*

</div>

---

## About

I build governed, high-performance analytics products at the intersection of Finance and Technology—from data modeling in LookML to executive dashboards that drive daily decisions. My production work lives in private repositories to protect proprietary business data, but this portfolio captures the **architecture, patterns, and techniques** I use in real enterprise environments.

---

## Enterprise LookML architecture

### Hub → pillars → spokes

I designed and maintain a hub-and-spoke LookML ecosystem that scales across departments, data sources, and entities. The **Housing** project acts as the shared semantic layer hub; it connects directly to five core pillar projects (ECOM, S2011, HR, Finance, IT), and the remaining spoke projects sit under those pillars.

```
                 ┌──────────────────────┐
                 │      HOUSING         │
                 │ (Hub / Semantic Layer)│
                 └───────┬─────┬────┬────┘
                         │     │    │
           ┌────────────┘     │    └────────────┐
           │                  │                 │
    ┌──────▼──────┐    ┌──────▼──────┐   ┌──────▼──────┐
    │    ECOM     │    │    S2011    │   │     IT      │
    │  (Pillar)   │    │  (Pillar)   │   │  (Pillar)   │
    └──────┬───────┘    └──────┬───────┘   └──────┬───────┘
           │                   │                  │
 ┌─────────────┼────────────┐  │      ┌───────────┼───────────┐
 │             │            │  │      │           │           │
┌──────▼──────┐ ┌────▼─────┐ ┌────▼─────┐ ┌──▼──────┐ ┌──▼────────┐ ┌──▼──────────┐
│  MARKETING  │ │    CX    │ │   CET    │ │   SFC   │ │Salesforce │ │ COMPLIANCE  │
│   (Spoke)   │ │ (Spoke)  │ │ (Spoke)  │ │ (Spoke) │ │  (Spoke)  │ │ (Spoke/ATF) │
└──────────────┘ └───────────┘ └──────────┘ └──────────┘ └───────────┘ └─────────────┘

     ┌──────────────┐        ┌──────────────┐
     │      HR      │        │   FINANCE    │
     │   (Pillar)   │        │   (Pillar)   │
     └──────┬───────┘        └──────┬───────┘
            │                       │
     ┌──────▼──────┐         ┌──────▼──────────┐
     │      HR     │         │      AMMO       │
     │   (Spoke)   │         │   (Spoke/LHA)   │
     └──────────────┘         └──────┬──────────┘
                                     │
                              ┌──────▼──────────┐
                              │       LHP       │
                              │(Spoke/Subsidiary│
                              └──────────────────┘

Under S2011 pillar (additional spokes):
BD · LE Sales · Ranch/Vegas · Customer Excellence

Under IT pillar (additional spokes):
IT Data Team
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

---

## Contact

If you want to talk enterprise Looker architecture, KPI governance, or building dashboard products that finance leaders actually trust:

- • GitHub: https://github.com/MHBennett92
- • LinkedIn: https://linkedin.com/in/mhbennett

---

*All repositories referenced are private. No proprietary data, schema names, internal URLs, or business-sensitive SQL has been disclosed—only architecture patterns and generalized examples.*
