# Manual tests

These scripts are intended for interactive, human review. Run them section by
section from the package root and inspect every table and plot. They complement
the automated `testthat` suite; they do not replace it.

Start with `01-ggrank-complete-manual-test.R`.
Its final section launches `ggrank_app()`; run that section last because the
interactive app keeps the R session busy until it is stopped.

Use `02-ggrank-data-ranking-workflow.R` for a focused walkthrough of automatic
ranking, whole-number ties, ranking methods, top-N boundary ties, exact versus
displayed values, ascending ranks, supplied ranks, and missing values.

Use `03-ggrank-app-usability-check.R` for the same short, uncoached usability
review principle used by the gtstats and gtregression apps.

Use `04-rank-change-and-legends.R` to review latest/all/explicit comparisons,
stable categories, detailed change labels, long names, palettes, legend titles,
legend labels, and legend suppression. It contains no loops.

Use `05-rank-only-workflow.R` to verify student/product/institution rankings
that contain names and authoritative ranks but no marks, rates, or values.

Use `06-sports-leaderboards.R` to inspect top-5, top-10, top-20, and top-30
leaderboard layouts using synthetic football and cricket-style data. It also
demonstrates practical export heights and contains no loops.
