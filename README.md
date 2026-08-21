# ggrank

Visualise how rankings change across time, groups, and scenarios using ggplot2.

`ggrank` is an independent open-source project and is not affiliated with or
endorsed by the Institute for Health Metrics and Evaluation (IHME). All data
included with the package are synthetic teaching data and do not contain
Global Burden of Disease estimates.

## Installation

Install the development version from GitHub:

```r
pak::pak("ThinkDenominator/ggrank")
```

```r
library(ggrank)

ggrank(
  ggrank_causes,
  category = cause,
  period = year,
  value = rate,
  rank = rank,
  label = display_value,
  group = cause_group,
  periods = c(1990, 2021),
  top_n = 10,
  value_header = "Rate (95% interval)"
)
```

The default boundary view retains categories that enter or leave the selected
top ranks, so important transitions are not silently discarded. The result is
an ordinary ggplot object and can be customised with `labs()`, themes, and
scales.

Use `ggrank_table()` when you need the readable analytical result behind a
figure—for example, exact before/after ranks, value changes, entrants, and
exits.

Use `ggrank_change()` to visualise the largest movements in that table:

```r
changes <- ggrank_table(
  ggrank_products, product, year, sales,
  periods = c(2022, 2024), top_n = 5
)

ggrank_change(changes, top = 5)
```

For a point-and-click workflow, launch the local Shiny interface:

```r
ggrank_app()
```

The app uses the same package functions. It can open the synthetic teaching
data or an uploaded CSV, create the ranking, display both charts, and show the
rank-change table.

## How ranks are calculated

Normally, supply one numeric value for each category and period; you do not
need to create a rank column. `ggrank()` ranks the exact values within each
period before applying `top_n`.

```r
ggrank_data(ggrank_products, product, year, sales)
```

Equal values share a competition rank by default (`1, 2, 3, 3, 5`). They are
placed on separate rows and all categories tied at the `top_n` boundary are
retained. `value` controls ranking, while an optional `label` controls only the
printed formatting. Do not pre-filter data to the top N: supply all relevant
categories so entrants and exits can be identified.

## Exporting results

`ggrank()` returns an ordinary ggplot object, so use standard R tools:

```r
p <- ggrank(ggrank_products, product, year, sales, top_n = 5)

ggplot2::ggsave(
  "rank-chart.png", p,
  width = 12, height = 7, units = "in", dpi = 300
)

changes <- ggrank_table(
  ggrank_products, product, year, sales,
  periods = c(2022, 2024), top_n = 5
)

write.csv(changes, "rank-changes.csv", row.names = FALSE)
```
