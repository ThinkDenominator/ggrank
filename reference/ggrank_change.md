# Visualise the largest rank changes

Turns the output of
[`ggrank_table()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_table.md)
into a focused diverging bar chart. Positive values indicate a rise in
rank and negative values indicate a fall.

## Usage

``` r
ggrank_change(
  data,
  top = 15,
  palette = c(riser = "#17845B", faller = "#C44E52", stable = "#667085"),
  base_size = 11,
  title = NULL,
  subtitle = NULL
)
```

## Arguments

- data:

  A rank-change table returned by
  [`ggrank_table()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_table.md).

- top:

  Maximum number of categories to display for each transition, selected
  by absolute rank change.

- palette:

  Named colours for `riser`, `faller`, and `stable`.

- base_size:

  Base text size.

- title, subtitle:

  Optional plot title and subtitle.

## Value

A `ggplot` object.

## Examples

``` r
changes <- ggrank_table(
  ggrank_products, product, year, sales,
  periods = c(2022, 2024), top_n = 5
)
ggrank_change(changes, top = 5)
```
