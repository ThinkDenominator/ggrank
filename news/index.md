# Changelog

## ggrank 0.1.0

- Initial implementation of
  [`ggrank()`](https://thinkdenominator.github.io/ggrank/reference/ggrank.md),
  [`ggrank_table()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_table.md),
  and
  [`theme_ggrank()`](https://thinkdenominator.github.io/ggrank/reference/theme_ggrank.md).
- Support for automatic and supplied ranks across two to four states.
- Automatic retention of categories entering and exiting the selected
  top N.
- Added synthetic causes and product teaching datasets.
- Added
  [`ggrank_data()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_data.md)
  for inspecting automatically calculated ranks.
- Equal values now share competition ranks by default; tied categories
  retain separate display positions and all ties at the top-N boundary
  are included.
- Ranking uses exact numeric values independently of printed labels, and
  missing or non-finite ranking values produce an informative warning.
- Supplied ranks can now be checked against value ties and ranking
  direction; potential disagreements warn because external ranking rules
  may be valid.
- Added
  [`ggrank_change()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_change.md)
  to visualise the largest rises and falls from a
  [`ggrank_table()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_table.md)
  result.
- Added
  [`ggrank_app()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_app.md)
  as an optional local Shiny interface for the existing ranking, table,
  and visualisation workflow.
- Finalised
  [`ggrank_change()`](https://thinkdenominator.github.io/ggrank/reference/ggrank_change.md)
  as a latest-comparison diverging chart with raw data support, explicit
  or all-comparison selection, stable-category control, detailed rank
  labels, within-comparison ordering, and wrapped labels.
- Added palette, legend-title, legend-label, and legend-visibility
  controls to both primary visualisations.
- Added rank-only workflows across the package and GUI. Authoritative
  ranks can now be plotted without inventing a value, mark, rate, or
  score column.
- Reworked the GUI as a four-step guided workflow with basic/advanced
  settings, embedded data examples, and independent error handling for
  the change chart.
