## Manual real-time test: complete ggrank user journey
## Package: ggrank 0.1.0
##
## Story:
## A user wants to understand how leading causes or products change rank across
## ordered states. We begin with the simplest automatic ranking, inspect the
## analytical table, add prepared ranks and labels, explore entrants and exits,
## compare two to four states, customise colours, and finish with ordinary
## ggplot2 modifications.
##
## How to use:
## Run this script section by section in RStudio. Inspect every printed table
## and plot before continuing. Do not source the whole file blindly: several
## plots are deliberately assigned and printed one at a time for visual review.


## 0. Setup -------------------------------------------------------------------

## During package development, run this from the package root:
devtools::load_all(".")

## After installing from GitHub, use these instead:
## pak::pak("ThinkDenominator/ggrank")
## library(ggrank)

library(ggplot2)

data("ggrank_causes", package = "ggrank")
data("ggrank_products", package = "ggrank")

## Both bundled datasets are synthetic teaching data. ggrank_causes does not
## contain IHME or published Global Burden of Disease estimates.

head(ggrank_causes)
str(ggrank_causes)

head(ggrank_products)
str(ggrank_products)


## 1. Simplest possible plot --------------------------------------------------

## User question:
## Which five products rank highest, and how did their positions change?

plot_products_default <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  top_n = 5
)

plot_products_default

## Check manually:
## - three year columns appear in chronological order;
## - each state has Category and Value boxes;
## - connectors link the same product;
## - movement colours and legend are readable;
## - products crossing the top-five boundary remain visible.


## 2. Inspect the analytical transition table --------------------------------

products_table <- ggrank_table(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  top_n = 5
)

products_table

products_table

## Check manually:
## - rank 1 has the largest sales value within each selected year;
## - a positive rank_change means the product rose;
## - entrants and exits have the expected status;
## - values and ranks before and after match the plotted categories.


## 3. Select and order two states --------------------------------------------

plot_products_two_states <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  title = "Product rankings: 2022 to 2024",
  subtitle = "Automatic descending ranks"
)

plot_products_two_states

## Reverse the requested order deliberately. The plot should follow periods,
## not sort them behind the user's back.
plot_products_reverse_order <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2024, 2022),
  top_n = 5,
  title = "User-specified reverse comparison"
)

plot_products_reverse_order


## 4. GBD-inspired plot with supplied ranks and labels -----------------------

causes_table <- ggrank_table(
  data = ggrank_causes,
  category = cause,
  period = year,
  value = rate,
  rank = rank,
  label = display_value,
  group = cause_group,
  periods = c(1990, 2021),
  top_n = 10
)

causes_table

plot_causes_grouped <- ggrank(
  data = ggrank_causes,
  category = cause,
  period = year,
  value = rate,
  rank = rank,
  label = display_value,
  group = cause_group,
  periods = c(1990, 2021),
  top_n = 10,
  category_header = "Cause",
  value_header = "Rate (95% interval)",
  title = "Leading causes, 1990 and 2021",
  subtitle = "Synthetic teaching data"
)

plot_causes_grouped

## Check manually:
## - supplied ranks are used rather than recalculated from rate;
## - uncertainty labels are printed unchanged;
## - Alzheimer disease (rank 14 to rank 4) is visible and connected;
## - causes leaving the top ten remain below the 2021 top-ten block;
## - cause-group colours are consistent across boxes and connectors.


## 5. Three-state and four-state layouts -------------------------------------

plot_causes_three_states <- ggrank(
  data = ggrank_causes,
  category = cause,
  period = year,
  value = rate,
  rank = rank,
  label = display_value,
  group = cause_group,
  periods = c(1990, 2010, 2021),
  top_n = 8,
  value_header = "Rate (95% interval)",
  label_wrap = 22,
  base_size = 10,
  title = "Leading causes across three states"
)

plot_causes_three_states

## Build a fourth state explicitly for manual layout testing.
products_four_states <- rbind(
  ggrank_products,
  data.frame(
    year = 2025,
    product = paste("Product", LETTERS[1:8]),
    category = rep(c("Home", "Work", "Leisure", "Travel"), each = 2),
    sales = c(5200, 8100, 3100, 7200, 6100, 4100, 2100, 1100)
  )
)

plot_products_four_states <- ggrank(
  data = products_four_states,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2023, 2024, 2025),
  top_n = 5,
  label_wrap = 18,
  base_size = 9,
  title = "Maximum supported four-state layout"
)

plot_products_four_states

## Check manually:
## - trajectories connect adjacent states only;
## - all four state headers and value boxes remain legible;
## - the figure is wide but does not overlap at presentation dimensions.


## 6. Transition display modes ------------------------------------------------

plot_boundary <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  show_transitions = "boundary",
  title = "Boundary: retain entrants and exits"
)

plot_boundary

plot_top_only <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  show_transitions = "top_only",
  title = "Top only: omit outside observations"
)

plot_top_only

plot_all <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  show_transitions = "all",
  title = "All categories"
)

plot_all

## Compare the three plots manually. Boundary should be the most informative
## compact view; top_only should be shortest; all should contain eight products.


## 7. Colour modes ------------------------------------------------------------

plot_colour_movement <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  colour_by = "movement",
  title = "Colour by movement"
)

plot_colour_movement

plot_colour_group <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  group = category,
  periods = c(2022, 2024),
  top_n = 5,
  colour_by = "group",
  title = "Colour by product group"
)

plot_colour_group

plot_colour_none <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  colour_by = "none",
  title = "Neutral colour"
)

plot_colour_none


## 8. Custom palettes ---------------------------------------------------------

product_palette <- c(
  Home = "#264653",
  Work = "#2A9D8F",
  Leisure = "#E9C46A",
  Travel = "#E76F51"
)

plot_custom_group_palette <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  group = category,
  periods = c(2022, 2024),
  top_n = 6,
  colour_by = "group",
  palette = product_palette,
  title = "Custom named group palette"
)

plot_custom_group_palette

movement_palette <- c(
  stable = "#6C757D",
  riser = "#198754",
  faller = "#DC3545",
  entrant = "#0D6EFD",
  exit = "#FD7E14",
  new = "#6F42C1"
)

plot_custom_movement_palette <- ggrank(
  data = ggrank_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  colour_by = "movement",
  palette = movement_palette,
  title = "Custom named movement palette"
)

plot_custom_movement_palette


## 9. Ascending rankings ------------------------------------------------------

## Here lower values are better. Rename sales conceptually as waiting time.
waiting_times <- data.frame(
  service = rep(c("A", "B", "C", "D", "E", "F"), 2),
  quarter = rep(c("Q1", "Q4"), each = 6),
  minutes = c(12, 18, 21, 25, 31, 40, 20, 10, 24, 17, 29, 35)
)

waiting_table <- ggrank_table(
  data = waiting_times,
  category = service,
  period = quarter,
  value = minutes,
  periods = c("Q1", "Q4"),
  top_n = 4,
  direction = "ascending"
)

waiting_table

plot_waiting_times <- ggrank(
  data = waiting_times,
  category = service,
  period = quarter,
  value = minutes,
  periods = c("Q1", "Q4"),
  top_n = 4,
  direction = "ascending",
  category_header = "Service",
  value_header = "Minutes",
  title = "Shortest waiting times rank first"
)

plot_waiting_times

## Check that 10 minutes is rank 1 in Q4.


## 10. Tie handling -----------------------------------------------------------

tied_scores <- data.frame(
  period = rep(c("Before", "After"), each = 5),
  category = rep(c("Alpha", "Bravo", "Charlie", "Delta", "Echo"), 2),
  score = c(100, 90, 90, 70, 60, 80, 95, 95, 70, 60)
)

ties_first <- ggrank_table(
  data = tied_scores,
  category = category,
  period = period,
  value = score,
  top_n = 5,
  ties = "first"
)

ties_first

ties_min <- ggrank_table(
  data = tied_scores,
  category = category,
  period = period,
  value = score,
  top_n = 5,
  ties = "min"
)

ties_min

ties_dense <- ggrank_table(
  data = tied_scores,
  category = category,
  period = period,
  value = score,
  top_n = 5,
  ties = "dense"
)

ties_dense

plot_ties_dense <- ggrank(
  data = tied_scores,
  category = category,
  period = period,
  value = score,
  top_n = 5,
  ties = "dense",
  title = "Dense ranking with ties"
)

plot_ties_dense

## Check the before/after ranks manually, then confirm in the plot that tied
## analytical ranks do not cause boxes to overlap.


## 11. Prepared display labels -----------------------------------------------

product_labels <- transform(
  ggrank_products,
  sales_label = paste0("£", format(sales, big.mark = ",", scientific = FALSE))
)

plot_prepared_labels <- ggrank(
  data = product_labels,
  category = product,
  period = year,
  value = sales,
  label = sales_label,
  periods = c(2022, 2024),
  top_n = 5,
  value_header = "Revenue",
  title = "User-prepared value labels"
)

plot_prepared_labels


## 12. Long labels and typography --------------------------------------------

long_label_products <- transform(
  ggrank_products,
  product = c(
    "Community infection surveillance dashboard",
    "Hospital antimicrobial stewardship toolkit",
    "Population denominator reference guide",
    "Public health reporting template",
    "Clinical audit data collection workbook",
    "Healthcare quality improvement course",
    "Regional epidemiology briefing service",
    "Interactive statistical learning resource"
  )[match(product, paste("Product", LETTERS[1:8]))]
)

plot_long_labels <- ggrank(
  data = long_label_products,
  category = product,
  period = year,
  value = sales,
  periods = c(2022, 2024),
  top_n = 5,
  label_wrap = 24,
  base_size = 10,
  title = "Long category labels"
)

plot_long_labels

## Check wrapping, row height, clipping, and value-box alignment carefully.

## Keep the two-column structure but rebalance the available width when either
## category names or value labels are unusually long.
plot_wider_value_boxes <- ggrank(
  data = ggrank_causes,
  category = cause,
  period = year,
  value = rate,
  rank = rank,
  label = display_value,
  group = cause_group,
  periods = c(1990, 2010, 2021),
  top_n = 8,
  label_wrap = 22,
  category_width = 2.5,
  value_width = 1.8,
  state_gap = 1.25,
  value_header = "Rate (95% interval)",
  title = "User-adjusted category and value widths"
)

plot_wider_value_boxes

## Check that wider value boxes retain clear separation from category text and
## that connectors still begin and end at the relevant box boundaries.


## 13. Standard ggplot2 customisation ----------------------------------------

plot_customised <- plot_causes_grouped +
  labs(
    title = "Changes in leading causes",
    subtitle = "A manually customised ggrank figure",
    caption = "Source: synthetic ggrank teaching data"
  ) +
  theme(
    text = element_text(family = "sans"),
    plot.title = element_text(face = "bold", colour = "#17324D"),
    plot.subtitle = element_text(colour = "#475467"),
    plot.caption = element_text(colour = "#667085")
  )

plot_customised

## Check that ordinary ggplot2 labs() and theme() additions are respected.


## 14. theme_ggrank() as a standalone exported function ----------------------

theme_example <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point(size = 2, colour = "#2A9D8F") +
  labs(
    title = "Standalone theme_ggrank() check",
    subtitle = "Axes are intentionally removed by this specialist theme"
  ) +
  theme_ggrank(base_size = 13, base_family = "sans")

theme_example

## Check that the theme returns a valid complete ggplot2 theme and removes
## axes, ticks, and grid lines as documented.


## 15. Factor periods ---------------------------------------------------------

factor_period_products <- transform(
  ggrank_products,
  year = factor(year, levels = c(2022, 2023, 2024))
)

plot_factor_periods <- ggrank(
  data = factor_period_products,
  category = product,
  period = year,
  value = sales,
  periods = factor(c(2022, 2023, 2024), levels = c(2022, 2023, 2024)),
  top_n = 5,
  title = "Factor periods"
)

plot_factor_periods


## 16. Expected validation messages ------------------------------------------

## Run each line separately. Every call below should stop with a clear,
## user-oriented error. These are intentional failures.

## Duplicate category-period rows:
## ggrank_table(
##   rbind(ggrank_products, ggrank_products[1, ]),
##   product, year, sales
## )

## Missing requested period:
## ggrank(
##   ggrank_products, product, year, sales,
##   periods = c(2022, 2030)
## )

## Too many states:
## ggrank(
##   products_four_states, product, year, sales,
##   periods = c(2021, 2022, 2023, 2024, 2025)
## )

## Group colouring without a group mapping:
## ggrank(
##   ggrank_products, product, year, sales,
##   colour_by = "group"
## )

## Incomplete palette:
## ggrank(
##   ggrank_products, product, year, sales,
##   group = category,
##   colour_by = "group",
##   palette = c(Home = "red")
## )


## 17. Final manual review checklist -----------------------------------------

## [ ] ggrank() works with the three required mappings only.
## [ ] ggrank_table() returns understandable before/after analytical columns.
## [ ] theme_ggrank() works independently.
## [ ] Two, three, and four-state layouts are readable.
## [ ] Requested period order is respected.
## [ ] Automatic descending and ascending ranks are correct.
## [ ] Supplied ranks and prepared labels are preserved.
## [ ] first, min, and dense tie methods behave as expected.
## [ ] Boundary mode retains entrants and exits.
## [ ] top_only and all modes visibly differ from boundary mode.
## [ ] Group, movement, and neutral colour modes are coherent.
## [ ] Named custom palettes map to the correct categories.
## [ ] Long labels wrap without clipping or overlapping adjacent rows.
## [ ] Rank numbers remain aligned when category labels wrap.
## [ ] Width controls preserve separate category and value boxes.
## [ ] Standard ggplot2 customisation remains available.
## [ ] Validation errors tell the user how to correct the input.
