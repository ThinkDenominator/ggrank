## Manual real-time test: preparing and inspecting ranks
## Package: ggrank 0.1.0
## Function: ggrank_data()
##
## Story:
## A surveillance analyst has rates and counts but no rank column. This script
## demonstrates exactly how ggrank calculates ranks, handles equal values,
## separates analytical rank from display position, preserves supplied ranks,
## and passes the prepared result into a chart.
##
## How to use:
## Run this script section by section in RStudio. Inspect every printed data
## frame and plot before continuing. The script contains no loops and is not an
## automated test suite.


## 0. Setup -------------------------------------------------------------------

## During package development, run from the package root:
devtools::load_all(".")

## After installing from GitHub, use these instead:
## pak::pak("ThinkDenominator/ggrank")
## library(ggrank)


## 1. Decimal rates: automatic descending ranks ------------------------------

decimal_rates <- data.frame(
  year = rep(c(2020, 2025), each = 5),
  organism = rep(
    c("E. coli", "S. aureus", "K. pneumoniae", "E. faecalis", "P. aeruginosa"),
    2
  ),
  rate = c(5.42, 4.87, 3.61, 2.95, 1.74, 4.96, 5.13, 3.84, 2.11, 2.73)
)

decimal_ranked <- ggrank_data(
  data = decimal_rates,
  category = organism,
  period = year,
  value = rate
)

decimal_ranked

## Check manually:
## - the largest rate is rank 1 within each year;
## - ranking restarts in 2025;
## - display_position matches rank because there are no ties;
## - the original decimal values are preserved.

decimal_plot <- ggrank(
  data = decimal_rates,
  category = organism,
  period = year,
  value = rate,
  top_n = 5,
  category_header = "Organism",
  value_header = "Rate per 100,000",
  title = "Automatic ranking from decimal rates"
)

decimal_plot


## 2. Whole numbers: equal values share competition ranks --------------------

whole_number_counts <- data.frame(
  year = rep(c(2020, 2025), each = 6),
  organism = rep(c("A", "B", "C", "D", "E", "F"), 2),
  episodes = c(
    15, 12, 8, 8, 6, 4,
    18, 11, 11, 7, 5, 3
  )
)

whole_number_ranked <- ggrank_data(
  data = whole_number_counts,
  category = organism,
  period = year,
  value = episodes
)

whole_number_ranked

## Check manually:
## - C and D both receive rank 3 in 2020;
## - B and C both receive rank 2 in 2025;
## - the next ranks are 5 and 4 respectively under competition ranking;
## - tied categories have different display_position values;
## - alphabetical order determines display order inside a tie.

whole_number_plot <- ggrank(
  data = whole_number_counts,
  category = organism,
  period = year,
  value = episodes,
  top_n = 5,
  category_header = "Organism",
  value_header = "Episodes",
  title = "Whole-number counts with shared ranks"
)

whole_number_plot


## 3. Compare all three tie methods ------------------------------------------

competition_ranks <- ggrank_data(
  data = whole_number_counts,
  category = organism,
  period = year,
  value = episodes,
  ties = "min"
)

competition_ranks

## Expected sequence for 2020: 1, 2, 3, 3, 5, 6.

dense_ranks <- ggrank_data(
  data = whole_number_counts,
  category = organism,
  period = year,
  value = episodes,
  ties = "dense"
)

dense_ranks

## Expected sequence for 2020: 1, 2, 3, 3, 4, 5.

unique_ranks <- ggrank_data(
  data = whole_number_counts,
  category = organism,
  period = year,
  value = episodes,
  ties = "first"
)

unique_ranks

## Expected sequence for 2020: 1, 2, 3, 4, 5, 6. C appears before D because
## equal values are resolved alphabetically for the unique-rank method.


## 4. A tie at the top-N boundary --------------------------------------------

boundary_ties <- data.frame(
  year = rep(c(2020, 2025), each = 7),
  organism = rep(c("A", "B", "C", "D", "E", "F", "G"), 2),
  rate = c(
    9, 8, 7, 6, 6, 6, 3,
    9, 8, 8, 5, 4, 3, 2
  )
)

boundary_ranked <- ggrank_data(
  data = boundary_ties,
  category = organism,
  period = year,
  value = rate
)

boundary_ranked

boundary_plot <- ggrank(
  data = boundary_ties,
  category = organism,
  period = year,
  value = rate,
  top_n = 4,
  title = "All categories tied at the rank-four boundary"
)

boundary_plot

## Check manually:
## - D, E, and F all have rank 4 in 2020;
## - all three appear even though top_n = 4;
## - top_n is therefore a rank threshold, not an exact box count;
## - no tied boxes overlap.


## 5. Exact ranking values versus rounded display labels ---------------------

rounded_labels <- data.frame(
  year = rep(c(2020, 2025), each = 4),
  organism = rep(c("A", "B", "C", "D"), 2),
  exact_rate = c(3.48, 3.44, 3.11, 2.76, 3.62, 3.58, 3.21, 2.81)
)

rounded_labels$whole_number_label <- sprintf(
  "%.0f per 100,000",
  rounded_labels$exact_rate
)

exact_ranked <- ggrank_data(
  data = rounded_labels,
  category = organism,
  period = year,
  value = exact_rate,
  label = whole_number_label
)

exact_ranked

## Check manually:
## - A and B print the same rounded label in each year;
## - A still ranks above B because exact_rate differs;
## - label affects printing only and never changes rank.

rounded_label_plot <- ggrank(
  data = rounded_labels,
  category = organism,
  period = year,
  value = exact_rate,
  label = whole_number_label,
  top_n = 4,
  value_header = "Displayed rate",
  title = "Exact values ranked; rounded values printed"
)

rounded_label_plot

## If the analytical rule genuinely treats one-decimal values as equal, create
## that ranking value explicitly before calling ggrank.
rounded_labels$rate_for_rank <- round(rounded_labels$exact_rate, 1)

rounded_value_ranked <- ggrank_data(
  data = rounded_labels,
  category = organism,
  period = year,
  value = rate_for_rank,
  label = whole_number_label
)

rounded_value_ranked

## Compare this output with exact_ranked. Any new ties are a deliberate result
## of ranking rate_for_rank rather than silent package rounding.


## 6. Ascending ranks: smaller values are better -----------------------------

waiting_times <- data.frame(
  quarter = rep(c("Q1", "Q4"), each = 5),
  service = rep(c("A", "B", "C", "D", "E"), 2),
  minutes = c(12, 18, 18, 25, 31, 20, 10, 10, 17, 29)
)

ascending_ranked <- ggrank_data(
  data = waiting_times,
  category = service,
  period = quarter,
  value = minutes,
  direction = "ascending"
)

ascending_ranked

## Check manually:
## - 12 minutes is rank 1 in Q1;
## - B and C share rank 2 in Q1;
## - B and C share rank 1 in Q4;
## - the ranking direction is clearly appropriate for the measure.

ascending_plot <- ggrank(
  data = waiting_times,
  category = service,
  period = quarter,
  value = minutes,
  direction = "ascending",
  top_n = 3,
  category_header = "Service",
  value_header = "Minutes",
  title = "Lower waiting times rank first"
)

ascending_plot


## 7. Preserve authoritative supplied ranks ---------------------------------

official_results <- data.frame(
  year = rep(c(2020, 2025), each = 4),
  organism = rep(c("A", "B", "C", "D"), 2),
  rate = c(8.1, 7.4, 6.8, 5.9, 7.9, 8.3, 6.7, 6.2),
  official_rank = c(1, 2, 3, 4, 2, 1, 4, 3)
)

official_ranked <- ggrank_data(
  data = official_results,
  category = organism,
  period = year,
  value = rate,
  rank = official_rank
)

official_ranked

## Check manually that rank exactly matches official_rank. The package should
## preserve supplied ranks instead of recalculating them.

official_plot <- ggrank(
  data = official_results,
  category = organism,
  period = year,
  value = rate,
  rank = official_rank,
  top_n = 4,
  title = "Authoritative supplied ranks"
)

official_plot


## 8. More than four periods --------------------------------------------------

long_series <- data.frame(
  year = rep(2020:2025, each = 3),
  category = rep(c("A", "B", "C"), 6),
  value = c(
    9, 8, 7,
    8, 9, 7,
    8, 7, 9,
    9, 7, 8,
    7, 9, 8,
    8, 9, 7
  )
)

long_series_ranked <- ggrank_data(
  data = long_series,
  category = category,
  period = year,
  value = value
)

long_series_ranked

## Check manually that ggrank_data() prepares all six periods. The detailed
## ggrank() box layout intentionally remains limited to two to four periods.


## 9. Missing and non-finite values ------------------------------------------

missing_values <- data.frame(
  year = rep(c(2020, 2025), each = 4),
  organism = rep(c("A", "B", "C", "D"), 2),
  rate = c(5, 4, NA, 2, 6, Inf, 3, 2)
)

## Run the following call and inspect the warning. It should report two
## excluded rows because NA and Inf cannot receive ranks.
missing_ranked <- ggrank_data(
  data = missing_values,
  category = organism,
  period = year,
  value = rate
)

missing_ranked

missing_transition <- ggrank_table(
  data = missing_values,
  category = organism,
  period = year,
  value = rate,
  top_n = 4
)

missing_transition

## Check manually:
## - the warning is clear;
## - invalid values are absent from the ranked rows;
## - ggrank_table() marks affected comparisons as status = "missing";
## - a present-but-missing value is not labelled as ordinary absence.


## 10. Expected validation messages ------------------------------------------

## Run each example separately. These calls are intentionally invalid and
## should stop with clear guidance.

## Duplicate category-period rows:
## ggrank_data(
##   rbind(decimal_rates, decimal_rates[1, ]),
##   organism, year, rate
## )

## Character ranking values:
## invalid_character_value <- transform(decimal_rates, rate = as.character(rate))
## ggrank_data(invalid_character_value, organism, year, rate)

## Missing category:
## invalid_missing_category <- decimal_rates
## invalid_missing_category$organism[1] <- NA
## ggrank_data(invalid_missing_category, organism, year, rate)

## Missing requested period:
## ggrank_data(
##   decimal_rates, organism, year, rate,
##   periods = c(2020, 2030)
## )


## 11. Final manual review checklist -----------------------------------------

## [ ] Decimal values rank correctly within every period.
## [ ] Whole-number ties share competition ranks by default.
## [ ] Tied categories receive unique display positions.
## [ ] Alphabetical category order resolves tied display positions.
## [ ] min, dense, and first tie methods produce the documented sequences.
## [ ] All categories tied at the top-N boundary appear in the plot.
## [ ] Exact values control rank independently of printed labels.
## [ ] Intentional pre-ranking rounding can be performed explicitly.
## [ ] Ascending direction gives the smallest value rank 1.
## [ ] Supplied authoritative ranks are preserved.
## [ ] ggrank_data() accepts more than four periods.
## [ ] Missing and non-finite values produce an informative warning.
## [ ] Missing values are distinguished from absent categories in the table.
## [ ] Prepared ranks agree with the corresponding ggrank() plots.

