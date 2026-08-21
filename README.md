# ggrank

Visualise how rankings change across time, groups, and scenarios using ggplot2.

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

