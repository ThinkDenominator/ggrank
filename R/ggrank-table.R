#' Build a rank-transition table
#'
#' Calculates or uses supplied ranks and identifies categories that rise, fall,
#' remain stable, enter, or exit the selected top ranks. The first release
#' compares two to four ordered states.
#'
#' @param data A data frame with one row per category and period.
#' @param category,period,value Unquoted columns identifying the category,
#'   ordered state, and numeric value.
#' @param rank Optional unquoted column containing precomputed ranks.
#' @param label Optional unquoted display-label column. By default `value` is
#'   formatted using `format()`.
#' @param group Optional unquoted category-group column.
#' @param periods Optional vector selecting and ordering two to four states.
#' @param top_n Number of leading categories to retain in each state.
#' @param direction Whether large (`"descending"`) or small (`"ascending"`)
#'   values rank first.
#' @param ties Ranking method: `"first"`, `"min"`, or `"dense"`.
#' @param show_transitions `"boundary"` retains the union of categories in the
#'   top N in any selected state; `"top_only"` only displays top-N observations;
#'   `"all"` displays every category.
#'
#' @return A data frame with one row per displayed category-state observation.
#'   Its `status` and `rank_change` compare each observation with the preceding
#'   selected state. Additional layout columns are used by [ggrank()].
#' @export
#' @examples
#' ggrank_table(ggrank_products, product, year, sales, top_n = 5)
ggrank_table <- function(data, category, period, value, rank = NULL,
                         label = NULL, group = NULL, periods = NULL,
                         top_n = 10, direction = c("descending", "ascending"),
                         ties = c("first", "min", "dense"),
                         show_transitions = c("boundary", "top_only", "all")) {
  direction <- match.arg(direction)
  ties <- match.arg(ties)
  show_transitions <- match.arg(show_transitions)
  category_q <- rlang::enquo(category)
  period_q <- rlang::enquo(period)
  value_q <- rlang::enquo(value)
  rank_q <- rlang::enquo(rank)
  label_q <- rlang::enquo(label)
  group_q <- rlang::enquo(group)

  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  if (length(top_n) != 1L || is.na(top_n) || top_n < 1 || top_n != as.integer(top_n)) {
    stop("`top_n` must be one positive whole number.", call. = FALSE)
  }

  out <- dplyr::select(data, .category = !!category_q, .period = !!period_q,
                       .value = !!value_q)
  out$.rank_input <- if (rlang::quo_is_null(rank_q)) NA_real_ else dplyr::pull(data, !!rank_q)
  out$.label <- if (rlang::quo_is_null(label_q)) format(out$.value, trim = TRUE) else as.character(dplyr::pull(data, !!label_q))
  out$.group <- if (rlang::quo_is_null(group_q)) NA_character_ else as.character(dplyr::pull(data, !!group_q))

  if (anyNA(out$.category) || anyNA(out$.period)) stop("`category` and `period` cannot contain missing values.", call. = FALSE)
  if (!is.numeric(out$.value)) stop("`value` must be numeric.", call. = FALSE)
  dup <- dplyr::summarise(dplyr::group_by(out, .period, .category), n = dplyr::n(), .groups = "drop")
  if (any(dup$n > 1L)) stop("Each category-period combination must occur exactly once.", call. = FALSE)

  available <- unique(out$.period)
  if (is.null(periods)) periods <- available
  if (length(periods) < 2L || length(periods) > 4L) stop("Select between two and four `periods`.", call. = FALSE)
  if (any(!periods %in% available)) stop("Every requested period must occur in `data`.", call. = FALSE)
  out <- dplyr::filter(out, .period %in% periods, is.finite(.value))
  out$.period_index <- match(out$.period, periods)
  out$.period_label <- as.character(out$.period)

  if (rlang::quo_is_null(rank_q)) {
    out <- dplyr::group_by(out, .period_index)
    if (ties == "first") {
      out <- if (direction == "descending") dplyr::arrange(out, dplyr::desc(.value), .category, .by_group = TRUE) else dplyr::arrange(out, .value, .category, .by_group = TRUE)
      out <- dplyr::mutate(out, rank = dplyr::row_number())
    } else {
      rank_fun <- if (ties == "min") dplyr::min_rank else dplyr::dense_rank
      out <- dplyr::mutate(out, rank = rank_fun(if (direction == "descending") -.value else .value))
    }
    out <- dplyr::ungroup(out)
  } else {
    if (any(!is.finite(out$.rank_input)) || any(out$.rank_input < 1)) stop("Supplied ranks must be finite positive numbers.", call. = FALSE)
    out$rank <- out$.rank_input
  }

  in_top <- out$rank <= top_n
  if (show_transitions == "boundary") {
    keep <- unique(out$.category[in_top])
    out <- dplyr::filter(out, .category %in% keep)
  } else if (show_transitions == "top_only") {
    out <- out[in_top, , drop = FALSE]
  }

  out <- dplyr::group_by(out, .period_index)
  out <- dplyr::arrange(out, rank, .category, .by_group = TRUE)
  out <- dplyr::mutate(out,
    display_position = ifelse(rank <= top_n, rank, top_n + cumsum(rank > top_n)),
    in_top = rank <= top_n
  )
  out <- dplyr::ungroup(out)

  previous <- dplyr::select(out, .category, .period_index, previous_rank = rank, previous_in_top = in_top)
  previous$.period_index <- previous$.period_index + 1L
  out <- dplyr::left_join(out, previous, by = c(".category", ".period_index"))
  out$rank_change <- out$previous_rank - out$rank
  out$status <- ifelse(is.na(out$previous_rank), "new",
    ifelse(!out$previous_in_top & out$in_top, "entrant",
      ifelse(out$previous_in_top & !out$in_top, "exit",
        ifelse(out$rank_change > 0, "riser", ifelse(out$rank_change < 0, "faller", "stable")))))
  out$category <- out$.category
  out$period <- out$.period
  out$value <- out$.value
  out$label <- out$.label
  out$group <- out$.group
  out
}
