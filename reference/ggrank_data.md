# Prepare and inspect ranked data

Calculates ranks within each state before any top-N display filtering is
applied. This helper is optional:
[`ggrank()`](https://thinkdenominator.github.io/ggrank/reference/ggrank.md)
performs the same ranking automatically. Use it when you want to
inspect, teach, export, or reuse the calculated ranks.

## Usage

``` r
ggrank_data(
  data,
  category,
  period,
  value = NULL,
  rank = NULL,
  label = NULL,
  group = NULL,
  periods = NULL,
  direction = c("descending", "ascending"),
  ties = c("min", "dense", "first"),
  check_rank = TRUE
)
```

## Arguments

- data:

  A data frame with one row per category and period.

- category, period:

  Unquoted columns identifying the category and state.

- value:

  Optional unquoted numeric ranking-value column. It may be omitted when
  an authoritative `rank` column is supplied.

- rank:

  Optional unquoted column containing authoritative precomputed ranks.
  When supplied, these ranks are preserved.

- label:

  Optional unquoted display-label column.

- group:

  Optional unquoted category-group column.

- periods:

  Optional vector selecting and ordering states. Unlike
  [`ggrank()`](https://thinkdenominator.github.io/ggrank/reference/ggrank.md),
  this preparation helper is not limited to four states.

- direction:

  Whether large (`"descending"`) or small (`"ascending"`) values rank
  first.

- ties:

  Ranking method: `"min"` (competition ranking), `"dense"`, or `"first"`
  (unique ranks resolved alphabetically by category).

- check_rank:

  When `TRUE`, supplied ranks are checked for potential disagreements
  with the values and ranking direction. These checks warn rather than
  fail because authoritative ranks may use external information.

## Value

A data frame containing `category`, `period`, `value`, `rank`,
`display_position`, `label`, and `group`.

## Details

Ranking uses the exact numeric `value`; formatting supplied through
`label` never changes the rank. By default, equal values receive the
same competition rank (`1, 2, 3, 3, 5`). Tied categories receive
separate alphabetical display positions so their plot boxes do not
overlap.

## Examples

``` r
ggrank_data(ggrank_products, product, year, sales)
#>     category period value rank display_position label group
#> 1  Product A   2022  8034    1                1  8034  <NA>
#> 2  Product B   2022  7034    2                2  7034  <NA>
#> 3  Product C   2022  6034    3                3  6034  <NA>
#> 4  Product D   2022  5034    4                4  5034  <NA>
#> 5  Product E   2022  4034    5                5  4034  <NA>
#> 6  Product F   2022  3034    6                6  3034  <NA>
#> 7  Product G   2022  2034    7                7  2034  <NA>
#> 8  Product H   2022  1034    8                8  1034  <NA>
#> 9  Product B   2023  8051    1                1  8051  <NA>
#> 10 Product A   2023  7051    2                2  7051  <NA>
#> 11 Product D   2023  6051    3                3  6051  <NA>
#> 12 Product F   2023  5051    4                4  5051  <NA>
#> 13 Product C   2023  4051    5                5  4051  <NA>
#> 14 Product H   2023  3051    6                6  3051  <NA>
#> 15 Product E   2023  2051    7                7  2051  <NA>
#> 16 Product G   2023  1051    8                8  1051  <NA>
#> 17 Product B   2024  8068    1                1  8068  <NA>
#> 18 Product D   2024  7068    2                2  7068  <NA>
#> 19 Product E   2024  6068    3                3  6068  <NA>
#> 20 Product A   2024  5068    4                4  5068  <NA>
#> 21 Product H   2024  4068    5                5  4068  <NA>
#> 22 Product C   2024  3068    6                6  3068  <NA>
#> 23 Product F   2024  2068    7                7  2068  <NA>
#> 24 Product G   2024  1068    8                8  1068  <NA>

tied <- data.frame(
  year = rep(c(2020, 2025), each = 4),
  organism = rep(LETTERS[1:4], 2),
  rate = c(5, 4, 3, 3, 6, 4, 4, 2)
)
ggrank_data(tied, organism, year, rate)
#>   category period value rank display_position label group
#> 1        A   2020     5    1                1     5  <NA>
#> 2        B   2020     4    2                2     4  <NA>
#> 3        C   2020     3    3                3     3  <NA>
#> 4        D   2020     3    3                4     3  <NA>
#> 5        A   2025     6    1                1     6  <NA>
#> 6        B   2025     4    2                2     4  <NA>
#> 7        C   2025     4    2                3     4  <NA>
#> 8        D   2025     2    4                4     2  <NA>

ranks_only <- data.frame(
  year = rep(c(2024, 2025), each = 3),
  student = rep(c("A", "B", "C"), 2),
  rank = c(1, 2, 3, 2, 1, 3)
)
ggrank_data(ranks_only, student, year, rank = rank)
#>   category period value rank display_position label group
#> 1        A   2024    NA    1                1        <NA>
#> 2        B   2024    NA    2                2        <NA>
#> 3        C   2024    NA    3                3        <NA>
#> 4        B   2025    NA    1                1        <NA>
#> 5        A   2025    NA    2                2        <NA>
#> 6        C   2025    NA    3                3        <NA>
```
