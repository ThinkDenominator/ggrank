## Manual test: rank-only data without marks, rates, scores, or values
## Run from the package root, one section at a time. No loops are used.

devtools::load_all(".")

student_ranks <- data.frame(
  year = rep(c(2024, 2025), each = 6),
  student = rep(c("Asha", "Ben", "Chen", "Dina", "Euan", "Fatima"), 2),
  institution = "North School",
  rank = c(1, 2, 3, 4, 5, 6, 3, 1, 2, 6, 4, 5)
)


## 1. Inspect authoritative ranks --------------------------------------------

rank_only_data <- ggrank_data(
  student_ranks,
  category = student,
  period = year,
  rank = rank
)

rank_only_data

## Confirm supplied ranks are unchanged and value is NA.


## 2. Plot rank transitions without a value column ---------------------------

rank_only_plot <- ggrank(
  student_ranks,
  category = student,
  period = year,
  rank = rank,
  group = institution,
  top_n = 5,
  title = "Student rank changes"
)

rank_only_plot

## Confirm:
## - category boxes show rank and student name;
## - no empty Value boxes or Value headers are drawn;
## - connectors use the supplied ranks;
## - students entering or leaving the top five remain visible.


## 3. Inspect the rank-change table ------------------------------------------

rank_only_table <- ggrank_table(
  student_ranks,
  category = student,
  period = year,
  rank = rank,
  group = institution,
  top_n = 5,
  show_transitions = "all"
)

rank_only_table

## Confirm rank_from, rank_to, rank_change, and status are populated while
## value_from, value_to, and value_change are NA.


## 4. Plot the largest rank changes ------------------------------------------

rank_only_change_plot <- ggrank_change(
  student_ranks,
  category = student,
  period = year,
  rank = rank,
  top = 5,
  change_label = "ranks"
)

rank_only_change_plot

## Confirm positive changes rose towards rank one and negative changes fell.


## 5. GUI rank-only workflow -------------------------------------------------

## Save a CSV if you want to test upload:
rank_only_csv <- tempfile(fileext = ".csv")
write.csv(student_ranks, rank_only_csv, row.names = FALSE)
rank_only_csv

## Run last. In the app choose Upload CSV, select "Use an existing rank
## column", map student/year/rank, choose 2024 and 2025, then Create charts.
ggrank_app()
