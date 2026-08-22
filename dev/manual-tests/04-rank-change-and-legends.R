## Manual test: rank-change behaviour and legend customisation
## Run from the package root, one section at a time. No loops are used.

devtools::load_all(".")
library(ggplot2)

data("ggrank_products", package = "ggrank")
data("ggrank_causes", package = "ggrank")


## 1. Direct raw-data workflow: latest comparison ----------------------------

change_latest <- ggrank_change(
  ggrank_products,
  category = product,
  period = year,
  value = sales,
  top = 5
)

change_latest

## Check manually:
## - only 2023 to 2024 is displayed;
## - negative bars extend left and positive bars extend right;
## - every bar has a signed whole-number label;
## - stable categories are absent;
## - the five bars are the largest absolute changes, not five per direction.


## 2. Inspect the table, then show all comparisons ----------------------------

product_changes <- ggrank_table(
  ggrank_products,
  category = product,
  period = year,
  value = sales,
  top_n = 5,
  show_transitions = "all"
)

product_changes

change_all <- ggrank_change(
  product_changes,
  top = 5,
  comparison = "all"
)

change_all

## Check that 2022 to 2023 and 2023 to 2024 have separate, correctly ordered
## panels and that each panel contains no more than five categories.


## 3. Explicit comparison and detailed rank labels ---------------------------

change_explicit <- ggrank_change(
  product_changes,
  from = 2022,
  to = 2023,
  top = 5,
  change_label = "ranks"
)

change_explicit

## Confirm labels follow: rank_from → rank_to (signed change).


## 4. Stable categories -------------------------------------------------------

change_with_stable <- ggrank_change(
  product_changes,
  top = 8,
  show_stable = TRUE
)

change_with_stable

## Confirm unchanged categories appear at zero and use the Stable legend key.


## 5. Custom movement colours and legend labels ------------------------------

custom_movement_colours <- c(
  riser = "#0072B2",
  faller = "#D55E00",
  stable = "#667085"
)

custom_movement_labels <- c(
  riser = "Moved towards rank 1",
  faller = "Moved away from rank 1",
  stable = "No rank change"
)

change_custom_legend <- ggrank_change(
  product_changes,
  top = 8,
  show_stable = TRUE,
  palette = custom_movement_colours,
  legend_title = "Movement",
  legend_labels = custom_movement_labels
)

change_custom_legend

change_without_legend <- ggrank_change(
  product_changes,
  top = 5,
  show_legend = FALSE
)

change_without_legend

## Confirm the first plot uses all custom labels and the second has no legend.


## 6. Custom cause-group legend in the full ranking chart --------------------

cause_colours <- c(
  "Communicable" = "#009E73",
  "Injuries" = "#0072B2",
  "Non-communicable" = "#D55E00"
)

cause_legend_labels <- c(
  "Communicable" = "Communicable diseases",
  "Injuries" = "Injuries",
  "Non-communicable" = "Non-communicable diseases"
)

rank_custom_group_legend <- ggrank(
  ggrank_causes,
  category = cause,
  period = year,
  value = rate,
  rank = rank,
  label = display_value,
  group = cause_group,
  periods = c(1990, 2021),
  top_n = 10,
  palette = cause_colours,
  legend_title = "Cause group",
  legend_labels = cause_legend_labels
)

rank_custom_group_legend

## Confirm the colours retain their cause-group meaning and the displayed
## legend uses the longer publication labels.


## 7. Long category labels ---------------------------------------------------

long_names <- transform(
  ggrank_products,
  product = paste(product, "with an intentionally long descriptive name")
)

change_long_names <- ggrank_change(
  long_names,
  category = product,
  period = year,
  value = sales,
  top = 5,
  label_wrap = 22
)

change_long_names

## Confirm category labels wrap cleanly without clipping bar labels or panels.


## 8. Expected informative errors --------------------------------------------

## Run these separately; each should stop with a useful correction.

## Only one explicit endpoint:
## ggrank_change(product_changes, from = 2022)

## Non-existent direct comparison:
## ggrank_change(product_changes, from = 2022, to = 2024)

## Incomplete legend labels:
## ggrank_change(product_changes, legend_labels = c(riser = "Up"))

## All ranks stable while stable display is off:
## stable_only <- data.frame(
##   category = c("A", "B"), from = 2020, to = 2025,
##   rank_from = 1:2, rank_to = 1:2, rank_change = c(0, 0),
##   status = c("stable", "stable")
## )
## ggrank_change(stable_only)
