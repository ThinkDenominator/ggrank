#' Launch the ggrank graphical interface
#'
#' Opens a local Shiny application for creating a rank-transition chart,
#' inspecting its comparison table, and visualising its largest rank changes.
#' Users can start with the synthetic teaching data or upload a CSV file.
#'
#' The app is a companion to the code-first workflow. It shows and downloads
#' reusable R code for the selected analysis.
#'
#' @param ... Additional arguments passed to [shiny::runApp()].
#' @param launch.browser Logical or a function passed to [shiny::runApp()].
#'   The default uses the RStudio Viewer when available and otherwise opens a
#'   browser during an interactive session.
#'
#' @return Invisibly returns the value from [shiny::runApp()].
#' @export
#' @examples
#' \dontrun{
#' ggrank_app()
#' }
ggrank_app <- function(..., launch.browser = NULL) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("The `shiny` package is required. Install it with `install.packages(\"shiny\")`.",
         call. = FALSE)
  }
  app_dir <- system.file("shiny", "ggrank", package = "ggrank")
  if (!nzchar(app_dir)) {
    stop("The ggrank GUI files could not be found. Reinstall `ggrank`.",
         call. = FALSE)
  }
  if (is.null(launch.browser)) {
    launch.browser <- if (
      interactive() && requireNamespace("rstudioapi", quietly = TRUE) &&
        rstudioapi::isAvailable()
    ) {
      rstudioapi::viewer
    } else {
      interactive()
    }
  }
  shiny::runApp(app_dir, launch.browser = launch.browser, ...)
}
