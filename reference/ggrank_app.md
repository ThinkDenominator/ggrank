# Launch the ggrank graphical interface

Opens a local Shiny application for creating a rank-transition chart,
inspecting its comparison table, and visualising its largest rank
changes. Users can start with the synthetic teaching data or upload a
CSV file.

## Usage

``` r
ggrank_app(..., launch.browser = NULL)
```

## Arguments

- ...:

  Additional arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

- launch.browser:

  Logical or a function passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html). The
  default uses the RStudio Viewer when available and otherwise opens a
  browser during an interactive session.

## Value

Invisibly returns the value from
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Details

The app is a companion to the code-first workflow. It shows and
downloads reusable R code for the selected analysis.

## Examples

``` r
if (FALSE) { # \dontrun{
ggrank_app()
} # }
```
