#' Prepare rank-transition data
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
#' @return An internal data frame used to construct plots and tables.
#' @noRd
.prepare_ggrank_data <- function(data, category, period, value, rank = NULL,
                                 label = NULL, group = NULL, periods = NULL,
                                 top_n = 10,
                                 direction = c("descending", "ascending"),
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
    display_position = dplyr::row_number(),
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

#' Build a readable rank-transition table
#'
#' Produces the analytical companion to [ggrank()]. Each row compares a
#' category between two adjacent selected states. A two-state comparison has
#' one row per category; three or four states produce successive transition
#' rows such as 1990 to 2010 and 2010 to 2021.
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
#' @param show_transitions `"boundary"` retains categories appearing in the
#'   top N in any selected state; `"top_only"` includes top-N observations
#'   only; `"all"` includes every category.
#'
#' @return A data frame with category, transition states, ranks, rank change,
#'   values, value change, labels, group, and movement status. Positive
#'   `rank_change` means that a category rose in the ranking.
#' @export
#' @examples
#' ggrank_table(
#'   ggrank_products, product, year, sales,
#'   periods = c(2022, 2024), top_n = 5
#' )
ggrank_table <- function(data, category, period, value, rank = NULL,
                         label = NULL, group = NULL, periods = NULL,
                         top_n = 10, direction = c("descending", "ascending"),
                         ties = c("first", "min", "dense"),
                         show_transitions = c("boundary", "top_only", "all")) {
  prepared <- .prepare_ggrank_data(
    data, {{ category }}, {{ period }}, {{ value }},
    rank = {{ rank }}, label = {{ label }}, group = {{ group }},
    periods = periods, top_n = top_n, direction = direction,
    ties = ties, show_transitions = show_transitions
  )

  period_order <- unique(prepared$.period_label[order(prepared$.period_index)])
  transition_tables <- vector("list", length(period_order) - 1L)

  for (i in seq_len(length(period_order) - 1L)) {
    from_data <- prepared[prepared$.period_index == i,
      c(".category", ".period_label", "rank", ".value", ".label", ".group", "in_top")]
    to_data <- prepared[prepared$.period_index == i + 1L,
      c(".category", ".period_label", "rank", ".value", ".label", ".group", "in_top")]
    names(from_data) <- c("category", "from", "rank_from", "value_from",
                          "label_from", "group_from", "in_top_from")
    names(to_data) <- c("category", "to", "rank_to", "value_to",
                        "label_to", "group_to", "in_top_to")
    transition <- merge(from_data, to_data, by = "category", all = TRUE,
                        sort = FALSE)
    transition$from[is.na(transition$from)] <- period_order[i]
    transition$to[is.na(transition$to)] <- period_order[i + 1L]
    transition$rank_change <- transition$rank_from - transition$rank_to
    transition$value_change <- transition$value_to - transition$value_from
    transition$group <- ifelse(!is.na(transition$group_to),
                               transition$group_to, transition$group_from)
    transition$status <- ifelse(is.na(transition$rank_from), "new",
      ifelse(is.na(transition$rank_to), "absent",
        ifelse(!transition$in_top_from & transition$in_top_to, "entrant",
          ifelse(transition$in_top_from & !transition$in_top_to, "exit",
            ifelse(transition$rank_change > 0, "riser",
              ifelse(transition$rank_change < 0, "faller", "stable"))))))
    transition$transition_index <- i
    transition_tables[[i]] <- transition
  }

  result <- dplyr::bind_rows(transition_tables)
  result <- dplyr::arrange(result, transition_index,
                           is.na(rank_to), rank_to,
                           is.na(rank_from), rank_from, category)
  dplyr::select(result, category, from, to, rank_from, rank_to,
                rank_change, value_from, value_to, value_change,
                label_from, label_to, group, status)
}
