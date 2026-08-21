# ggrank

Visualise how rankings change across time, groups, and scenarios using ggplot2.

`ggrank` is an independent open-source project and is not affiliated with or
endorsed by the Institute for Health Metrics and Evaluation (IHME). All data
included with the package are synthetic teaching data and do not contain
Global Burden of Disease estimates.

```r
library(ggrank)

ggrank(
  ggrank_causes,
  category = cause,
  period = year,
  value = rate,
  rank = rank,
  label = display_value,
  group = cause_group,
  periods = c(1990, 2021),
  top_n = 10,
  value_header = "Rate (95% interval)"
)
```

The default boundary view retains categories that enter or leave the selected
top ranks, so important transitions are not silently discarded. The result is
an ordinary ggplot object and can be customised with `labs()`, themes, and
scales.

Use `ggrank_table()` when you need the readable analytical result behind a
figure—for example, exact before/after ranks, value changes, entrants, and
exits.
