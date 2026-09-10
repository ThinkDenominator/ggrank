## Resubmission

This is a resubmission. In this version I have:

* replaced the `\dontrun{}` wrapper in the `ggrank_app()` example with
  `if (interactive()) { ... }`, as requested, so the example clearly identifies
  the Shiny application as interactive while remaining visible to users.

## Initial submission

This is the first CRAN submission of ggrank.

The package includes only synthetic teaching datasets created specifically for
its examples. It contains no downloaded Global Burden of Disease estimates and
is not affiliated with or endorsed by the Institute for Health Metrics and
Evaluation.

## R CMD check results

0 errors | 0 warnings | 2 notes

Checked locally on:

* macOS, R-devel

The local NOTEs are:

* "New submission", which is expected because ggrank is not yet on CRAN.

* HTML validation was skipped because the macOS system HTML Tidy is too old.
  The HTML manual was generated successfully. This is not a package-code or
  documentation issue.

GitHub Actions also checks R-release on macOS, Windows, and Ubuntu, and R-devel
on Ubuntu.

## Reverse dependencies

There are currently no reverse dependencies because this is a new submission.
