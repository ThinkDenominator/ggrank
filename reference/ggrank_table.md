# Build a readable rank-transition table

Produces the analytical companion to
[`ggrank()`](https://thinkdenominator.github.io/ggrank/reference/ggrank.md).
Each row compares a category between two adjacent selected states. A
two-state comparison has one row per category; three or four states
produce successive transition rows such as 1990 to 2010 and 2010 to
2021.

## Usage

``` r
ggrank_table(
  data,
  category,
  period,
  value,
  rank = NULL,
  label = NULL,
  group = NULL,
  periods = NULL,
  top_n = 10,
  direction = c("descending", "ascending"),
  ties = c("min", "dense", "first"),
  show_transitions = c("boundary", "top_only", "all"),
  check_rank = TRUE
)
```

## Arguments

- data:

  A data frame with one row per category and period.

- category, period, value:

  Unquoted columns identifying the category, ordered state, and numeric
  value.

- rank:

  Optional unquoted column containing precomputed ranks.

- label:

  Optional unquoted display-label column. By default `value` is
  formatted using [`format()`](https://rdrr.io/r/base/format.html).

- group:

  Optional unquoted category-group column.

- periods:

  Optional vector selecting and ordering two to four states.

- top_n:

  Rank threshold to retain in each state. All categories tied at the
  boundary are included, so the result may contain more than `top_n`
  categories.

- direction:

  Whether large (`"descending"`) or small (`"ascending"`) values rank
  first.

- ties:

  Ranking method: `"min"` (the default competition ranking), `"dense"`,
  or `"first"` (unique alphabetical ranks).

- show_transitions:

  `"boundary"` retains categories appearing in the top N in any selected
  state; `"top_only"` includes top-N observations only; `"all"` includes
  every category.

- check_rank:

  When `TRUE`, supplied ranks are checked for disagreements with equal
  values, shared ranks across different values, and the requested
  ranking direction. Potential disagreements warn rather than fail
  because authoritative ranks may use external tie-breakers or
  additional data.

## Value

A data frame with category, transition states, ranks, rank change,
values, value change, labels, group, missing-value indicators, and
movement status. Positive `rank_change` means that a category rose in
the ranking.

## Examples

``` r
ggrank_table(
  ggrank_products, product, year, sales,
  periods = c(2022, 2024), top_n = 5
)
#>    category from   to rank_from rank_to rank_change value_from value_to
#> 1 Product B 2022 2024         2       1           1       7034     8068
#> 2 Product D 2022 2024         4       2           2       5034     7068
#> 3 Product E 2022 2024         5       3           2       4034     6068
#> 4 Product A 2022 2024         1       4          -3       8034     5068
#> 5 Product H 2022 2024         8       5           3       1034     4068
#> 6 Product C 2022 2024         3       6          -3       6034     3068
#>   value_change label_from label_to group missing_from missing_to  status
#> 1         1034       7034     8068  <NA>        FALSE      FALSE   riser
#> 2         2034       5034     7068  <NA>        FALSE      FALSE   riser
#> 3         2034       4034     6068  <NA>        FALSE      FALSE   riser
#> 4        -2966       8034     5068  <NA>        FALSE      FALSE  faller
#> 5         3034       1034     4068  <NA>        FALSE      FALSE entrant
#> 6        -2966       6034     3068  <NA>        FALSE      FALSE    exit
```
