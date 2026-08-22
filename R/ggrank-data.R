#' Prepare and inspect ranked data
#'
#' Calculates ranks within each state before any top-N display filtering is
#' applied. This helper is optional: [ggrank()] performs the same ranking
#' automatically. Use it when you want to inspect, teach, export, or reuse the
#' calculated ranks.
#'
#' Ranking uses the exact numeric `value`; formatting supplied through `label`
#' never changes the rank. By default, equal values receive the same competition
#' rank (`1, 2, 3, 3, 5`). Tied categories receive separate alphabetical display
#' positions so their plot boxes do not overlap.
#'
#' @param data A data frame with one row per category and period.
#' @param category,period Unquoted columns identifying the category and state.
#' @param value Optional unquoted numeric ranking-value column. It may be
#'   omitted when an authoritative `rank` column is supplied.
#' @param rank Optional unquoted column containing authoritative precomputed
#'   ranks. When supplied, these ranks are preserved.
#' @param label Optional unquoted display-label column.
#' @param group Optional unquoted category-group column.
#' @param periods Optional vector selecting and ordering states. Unlike
#'   [ggrank()], this preparation helper is not limited to four states.
#' @param direction Whether large (`"descending"`) or small (`"ascending"`)
#'   values rank first.
#' @param ties Ranking method: `"min"` (competition ranking), `"dense"`, or
#'   `"first"` (unique ranks resolved alphabetically by category).
#' @param check_rank When `TRUE`, supplied ranks are checked for potential
#'   disagreements with the values and ranking direction. These checks warn
#'   rather than fail because authoritative ranks may use external information.
#'
#' @return A data frame containing `category`, `period`, `value`, `rank`,
#'   `display_position`, `label`, and `group`.
#' @export
#' @examples
#' ggrank_data(ggrank_products, product, year, sales)
#'
#' tied <- data.frame(
#'   year = rep(c(2020, 2025), each = 4),
#'   organism = rep(LETTERS[1:4], 2),
#'   rate = c(5, 4, 3, 3, 6, 4, 4, 2)
#' )
#' ggrank_data(tied, organism, year, rate)
#'
#' ranks_only <- data.frame(
#'   year = rep(c(2024, 2025), each = 3),
#'   student = rep(c("A", "B", "C"), 2),
#'   rank = c(1, 2, 3, 2, 1, 3)
#' )
#' ggrank_data(ranks_only, student, year, rank = rank)
ggrank_data <- function(data, category, period, value = NULL, rank = NULL,
                        label = NULL, group = NULL, periods = NULL,
                        direction = c("descending", "ascending"),
                        ties = c("min", "dense", "first"),
                        check_rank = TRUE) {
  direction <- match.arg(direction)
  ties <- match.arg(ties)

  period_q <- rlang::enquo(period)
  value_q <- rlang::enquo(value)

  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  if (is.null(periods)) {
    periods <- unique(dplyr::pull(data, !!period_q))
  }
  selected <- data[dplyr::pull(data, !!period_q) %in% periods, , drop = FALSE]
  if (!nrow(selected)) stop("No rows matched the requested `periods`.", call. = FALSE)
  max_categories <- max(table(dplyr::pull(selected, !!period_q)))

  prepared <- .prepare_ggrank_data(
    data, {{ category }}, {{ period }}, {{ value }},
    rank = {{ rank }}, label = {{ label }}, group = {{ group }},
    periods = periods, top_n = max_categories,
    direction = direction, ties = ties, show_transitions = "all",
    min_states = 1L, max_states = Inf, check_rank = check_rank
  )

  result <- data.frame(
    category = prepared$category,
    period = prepared$period,
    value = if (rlang::quo_is_null(value_q)) NA_real_ else prepared$value,
    rank = prepared$rank,
    display_position = prepared$display_position,
    label = prepared$label,
    group = prepared$group,
    stringsAsFactors = FALSE
  )
  rownames(result) <- NULL
  result
}
