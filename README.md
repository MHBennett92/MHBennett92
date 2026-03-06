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

### Sanitized LookML dashboard example

Below is a sanitized pattern (structure only) showing the techniques I use: layout grid placement, HTML/CSS text tiles, single-value progress tiles, table calculations, and a dual-axis chart.

```yaml
- dashboard: enterprise_kpi_board
  title: Enterprise KPI Board (Sanitized)
  layout: newspaper
  elements:
  - name: header
    type: text
    body_text: |
      <div style="text-align: center; background: linear-gradient(135deg, #002856 0%, #004080 100%); padding: 20px; border-radius: 8px;">
        <h1 style="color: white; margin: 0; font-size: 28px;">🎯 ENTERPRISE 🟢 Live</h1>
        <p style="color: #b3d9ff; margin: 8px 0 0 0; font-size: 14px;">Performance KPIs · Drill-ready</p>
      </div>
    row: 0
    col: 0
    width: 24
    height: 3

  - title: KPI vs Goal
    name: kpi_vs_goal
    model: Finance_Model
    explore: gl_summary
    type: single_value
    fields: [gl_summary.kpi_value]
    dynamic_fields:
    - category: table_calculation
      label: Goal
      expression: "${gl_summary.kpi_value} * 0 + 100000"
      value_format_name: decimal_0
      table_calculation: goal
    show_comparison: true
    comparison_type: progress_percentage
    comparison_label: Goal
    row: 3
    col: 0
    width: 6
    height: 2

  - title: Trend (Dual Axis)
    name: trend_dual_axis
    model: Finance_Model
    explore: gl_summary
    type: looker_column
    fields: [gl_summary.month, gl_summary.metric_a, gl_summary.metric_b]
    fill_fields: [gl_summary.month]
    y_axes:
    - orientation: left
      series:
      - id: gl_summary.metric_a
    - orientation: right
      series:
      - id: gl_summary.metric_b
    series_types:
      gl_summary.metric_b: line
    series_colors:
      gl_summary.metric_a: "#002856"
      gl_summary.metric_b: "#e02926"
    row: 5
    col: 0
    width: 24
    height: 4

  - title: Monthly Table (Transpose)
    name: monthly_table
    model: Finance_Model
    explore: gl_summary
    type: marketplace_viz_report_table::report_table_visualization
    fields: [gl_summary.month, gl_summary.revenue, gl_summary.ebitda]
    transposeTable: true
    useUnit: true
    row: 9
    col: 0
    width: 24
    height: 3
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
