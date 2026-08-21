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
