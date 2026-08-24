# ggrank

Visualise how rankings change across time, groups, and scenarios using
ggplot2.

`ggrank` is an independent open-source project and is not affiliated
with or endorsed by the Institute for Health Metrics and Evaluation
(IHME). All data included with the package are synthetic teaching data
and do not contain Global Burden of Disease estimates.

## Installation

Install the development version from GitHub:

``` r

pak::pak("ThinkDenominator/ggrank")
```

``` r

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

## Two complementary views

[`ggrank()`](https://thinkdenominator.github.io/ggrank/reference/ggrank.md)
answers **How did the ranking evolve?** It shows the complete rank
structure, values, trajectories, risers, fallers, entrants, and exits.
The default boundary view retains categories that enter or leave the
selected top ranks, so important transitions are not silently discarded.

Use
[`ggrank_table()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_table.md)
when you need the readable analytical result behind a figure—for
example, exact before/after ranks, value changes, entrants, and exits.

[`ggrank_change()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_change.md)
answers **Who moved the most?** It highlights the largest increases and
decreases in rank. It accepts raw data directly:

``` r

ggrank_change(ggrank_products, product, year, sales, top = 5)
```

By default this displays the latest comparison, excludes unchanged
categories, and selects the largest absolute changes. Use
`comparison = "all"` for every adjacent transition. Both functions
return ordinary ggplot objects.

See the [movement, status, and legend
guide](https://thinkdenominator.github.io/ggrank/articles/movement-status-and-legends.html)
for status definitions, detailed rank labels, colours, legend labels,
and comparison selection.

For a point-and-click workflow, launch the local Shiny interface:

``` r

ggrank_app()
```

The app uses the same package functions. It can open the synthetic
teaching data or an uploaded CSV, create the ranking, display both
charts, and show the rank-change table.

## How ranks are calculated

Normally, supply one numeric value for each category and period; you do
not need to create a rank column.
[`ggrank()`](https://thinkdenominator.github.io/ggrank/reference/ggrank.md)
ranks the exact values within each period before applying `top_n`.

``` r

ggrank_data(ggrank_products, product, year, sales)
```

Equal values share a competition rank by default (`1, 2, 3, 3, 5`). They
are placed on separate rows and all categories tied at the `top_n`
boundary are retained. `value` controls ranking, while an optional
`label` controls only the printed formatting. Do not pre-filter data to
the top N: supply all relevant categories so entrants and exits can be
identified.

## Already have ranks but no values?

A value, mark, score, or rate is not required when authoritative ranks
already exist. Supply `category`, `period`, and `rank`:

``` r

student_ranks <- data.frame(
  year = rep(c(2024, 2025), each = 4),
  student = rep(c("Asha", "Ben", "Chen", "Dina"), 2),
  rank = c(1, 2, 3, 4, 3, 1, 2, 4)
)

ggrank(
  student_ranks,
  category = student,
  period = year,
  rank = rank,
  top_n = 4
)
```

The chart uses a compact category-and-rank layout and does not draw an
empty value column. Ranks must be positive whole numbers. If several
institutions have separate rankings in the same period, analyse each
institution separately or create a distinct period/list identifier;
`group` controls colour but does not create independent ranking
populations.

## Sports leaderboards and larger rankings

`top_n` is a rank threshold, not a fixed page size. A football table can
use `top_n = 20`, a ten-team cricket league can use `top_n = 10`, and a
larger competition can use `top_n = 30`. Boundary ties are retained, so
a top-10 chart can contain more than ten rows.

``` r

football <- data.frame(
  season = rep(c("2024", "2025"), each = 20),
  club = rep(sprintf("Club %02d", 1:20), 2),
  points = c(91, 86, 82, 78, 74, 70, 66, 63, 60, 57,
             54, 51, 48, 45, 42, 39, 36, 33, 29, 24,
             84, 92, 76, 81, 69, 73, 61, 65, 58, 55,
             52, 49, 46, 43, 40, 37, 34, 31, 27, 22)
)

league_plot <- ggrank(
  football, club, season, points,
  top_n = 20,
  value_header = "Points",
  title = "Football league table"
)
```

For twenty rows, start with a 10–12 inch-high export; for thirty rows,
start around 14–16 inches. The appropriate height also depends on label
wrapping, font size, number of periods, and slide or page dimensions.
See the [sports leaderboard
guide](https://thinkdenominator.github.io/ggrank/articles/sports-leaderboards.html)
for football-style and cricket-style examples.

## Exporting results

[`ggrank()`](https://thinkdenominator.github.io/ggrank/reference/ggrank.md)
returns an ordinary ggplot object, so use standard R tools:

``` r

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
