# ggrank 0.1.0

* Period selections now reject duplicates and report selected periods left
  without finite ranking values using clear, user-facing errors.
* Missing-value status matching now joins on category and period safely.
* `ggrank_change()` now validates scalar `from` and `to` comparisons.
* Plot layout arguments receive consistent validation, and GUI plot downloads
  are available only while viewing a plot.
* Added synthetic football- and cricket-style leaderboard examples, including
  guidance for exporting rankings containing 20 or 30 rows.

* Initial implementation of `ggrank()`, `ggrank_table()`, and
  `theme_ggrank()`.
* Support for automatic and supplied ranks across two to four states.
* Automatic retention of categories entering and exiting the selected top N.
* Added synthetic causes and product teaching datasets.
* Added `ggrank_data()` for inspecting automatically calculated ranks.
* Equal values now share competition ranks by default; tied categories retain
  separate display positions and all ties at the top-N boundary are included.
* Ranking uses exact numeric values independently of printed labels, and
  missing or non-finite ranking values produce an informative warning.
* Supplied ranks can now be checked against value ties and ranking direction;
  potential disagreements warn because external ranking rules may be valid.
* Added `ggrank_change()` to visualise the largest rises and falls from a
  `ggrank_table()` result.
* Added `ggrank_app()` as an optional local Shiny interface for the existing
  ranking, table, and visualisation workflow.
* Finalised `ggrank_change()` as a latest-comparison diverging chart with raw
  data support, explicit or all-comparison selection, stable-category control,
  detailed rank labels, within-comparison ordering, and wrapped labels.
* Added palette, legend-title, legend-label, and legend-visibility controls to
  both primary visualisations.
* Added rank-only workflows across the package and GUI. Authoritative ranks can
  now be plotted without inventing a value, mark, rate, or score column.
* Reworked the GUI as a four-step guided workflow with basic/advanced settings,
  embedded data examples, and independent error handling for the change chart.
