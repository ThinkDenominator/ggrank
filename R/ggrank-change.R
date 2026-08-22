#' Visualise the largest rank changes
#'
#' Creates a diverging bar chart answering "Who moved the most?" Positive
#' values rose towards rank one; negative values fell away from rank one. Raw
#' data are processed by [ggrank_table()], preserving one ranking engine.
#'
#' @param data Raw data or a rank-change table returned by [ggrank_table()].
#' @param category,period Unquoted columns used with raw `data`.
#' @param value Optional numeric value column. It may be omitted when `rank` is
#'   supplied.
#' @param rank,label,group Optional unquoted columns used with raw `data`.
#' @param periods Optional vector selecting and ordering two to four periods.
#' @param top Maximum categories displayed per comparison, selected by
#'   `abs(rank_change)`. This is not `top` risers plus `top` fallers.
#' @param top_n Top-rank boundary used to classify entrants and exits with raw
#'   data. It does not control the number of bars; `top` does.
#' @param direction,ties,check_rank Ranking options passed to [ggrank_table()].
#' @param comparison Display the latest consecutive comparison (default) or
#'   all comparisons. Ignored when `from` and `to` are supplied.
#' @param from,to Optional explicit comparison. Both must be supplied and the
#'   pair must already exist in the rank-change table.
#' @param show_stable Include unchanged categories. The default excludes them.
#' @param change_label Show signed change (`"change"`), detailed ranks such as
#'   `"7 -> 3 (+4)"` (`"ranks"`), or no bar-end label (`"none"`).
#' @param label_wrap Approximate characters per category-label line.
#' @param palette Named colours for `riser`, `faller`, and `stable`.
#' @param legend_title Optional legend title.
#' @param legend_labels Optional named labels for displayed movements.
#' @param show_legend Show the movement legend.
#' @param base_size Base text size.
#' @param title,subtitle Optional text overriding informative defaults. Use
#'   `subtitle = ""` to suppress the default subtitle.
#'
#' @return A `ggplot` object whose data retain the underlying table `status`.
#' @export
#' @examples
#' ggrank_change(ggrank_products, product, year, sales, top = 5)
#'
#' changes <- ggrank_table(
#'   ggrank_products, product, year, sales,
#'   top_n = 5, show_transitions = "all"
#' )
#' ggrank_change(changes, top = 5, comparison = "all")
ggrank_change <- function(data, category = NULL, period = NULL, value = NULL,
                          rank = NULL, label = NULL, group = NULL,
                          periods = NULL, top = 15, top_n = 10,
                          direction = c("descending", "ascending"),
                          ties = c("min", "dense", "first"),
                          check_rank = TRUE,
                          comparison = c("latest", "all"),
                          from = NULL, to = NULL, show_stable = FALSE,
                          change_label = c("change", "ranks", "none"),
                          label_wrap = 30,
                          palette = c(riser = "#0072B2",
                                      faller = "#D55E00",
                                      stable = "#667085"),
                          legend_title = NULL, legend_labels = NULL,
                          show_legend = TRUE, base_size = 11,
                          title = NULL, subtitle = NULL) {
  comparison <- match.arg(comparison)
  change_label <- match.arg(change_label)
  direction <- match.arg(direction)
  ties <- match.arg(ties)
  category_q <- rlang::enquo(category)
  period_q <- rlang::enquo(period)
  value_q <- rlang::enquo(value)
  rank_q <- rlang::enquo(rank)
  label_q <- rlang::enquo(label)
  group_q <- rlang::enquo(group)
  table_columns <- c("category", "from", "to", "rank_from", "rank_to",
                     "rank_change")

  if (!is.data.frame(data)) stop("`data` must be a data frame.", call. = FALSE)
  if (all(table_columns %in% names(data))) {
    changes <- data
  } else {
    if (rlang::quo_is_null(category_q) || rlang::quo_is_null(period_q) ||
        (rlang::quo_is_null(value_q) && rlang::quo_is_null(rank_q))) {
      stop("Raw `data` requires `category`, `period`, and either `value` or `rank`.",
           call. = FALSE)
    }
    changes <- ggrank_table(
      data, !!category_q, !!period_q, !!value_q,
      rank = !!rank_q, label = !!label_q, group = !!group_q,
      periods = periods, top_n = top_n, direction = direction, ties = ties,
      show_transitions = "all", check_rank = check_rank
    )
  }

  if (!is.numeric(changes$rank_change)) stop("`rank_change` must be numeric.", call. = FALSE)
  if (length(top) != 1L || is.na(top) || !is.finite(top) || top < 1 || top != as.integer(top)) {
    stop("`top` must be one positive whole number.", call. = FALSE)
  }
  if (length(label_wrap) != 1L || is.na(label_wrap) || !is.finite(label_wrap) || label_wrap < 1) {
    stop("`label_wrap` must be one positive number.", call. = FALSE)
  }
  if (length(base_size) != 1L || is.na(base_size) || !is.finite(base_size) || base_size <= 0) {
    stop("`base_size` must be one positive number.", call. = FALSE)
  }
  if (!is.logical(show_stable) || length(show_stable) != 1L || is.na(show_stable)) {
    stop("`show_stable` must be TRUE or FALSE.", call. = FALSE)
  }
  if (!is.logical(show_legend) || length(show_legend) != 1L || is.na(show_legend)) {
    stop("`show_legend` must be TRUE or FALSE.", call. = FALSE)
  }
  needed_colours <- c("riser", "faller", "stable")
  if (is.null(names(palette)) || any(!needed_colours %in% names(palette))) {
    stop("`palette` must provide named colours for riser, faller, and stable.", call. = FALSE)
  }

  changes$from <- as.character(changes$from)
  changes$to <- as.character(changes$to)
  changes$.transition <- paste(changes$from, changes$to, sep = " to ")
  transition_order <- unique(changes$.transition)
  if (xor(is.null(from), is.null(to))) stop("Supply both `from` and `to`, or neither.", call. = FALSE)
  if (!is.null(from)) {
    if (length(from) != 1L || length(to) != 1L || is.na(from) || is.na(to)) {
      stop("`from` and `to` must each be one non-missing value.", call. = FALSE)
    }
    requested <- paste(as.character(from), as.character(to), sep = " to ")
    if (!requested %in% transition_order) {
      stop("The comparison ", requested, " is not present in `data`. Available comparisons: ",
           paste(transition_order, collapse = ", "), ".", call. = FALSE)
    }
    selected_transitions <- requested
  } else if (comparison == "latest") {
    selected_transitions <- utils::tail(transition_order, 1L)
  } else {
    selected_transitions <- transition_order
  }

  plot_data <- changes[changes$.transition %in% selected_transitions &
                         is.finite(changes$rank_change), , drop = FALSE]
  if (!show_stable) plot_data <- plot_data[plot_data$rank_change != 0, , drop = FALSE]
  if (!nrow(plot_data)) {
    stop(if (show_stable) "No finite rank changes are available to plot."
         else "No non-zero rank changes are available. Use `show_stable = TRUE` to display unchanged categories.",
         call. = FALSE)
  }

  plot_data$category <- as.character(plot_data$category)
  wrapped <- strwrap(plot_data$category, width = label_wrap, simplify = FALSE)
  plot_data$.category_label <- vapply(wrapped, paste, collapse = "\n", FUN.VALUE = character(1))
  plot_data$.absolute_change <- abs(plot_data$rank_change)
  plot_data <- dplyr::group_by(plot_data, .transition)
  plot_data <- dplyr::arrange(plot_data, dplyr::desc(.absolute_change), category, .by_group = TRUE)
  plot_data <- dplyr::slice_head(plot_data, n = as.integer(top))
  plot_data <- dplyr::arrange(plot_data, rank_change, category, .by_group = TRUE)
  plot_data <- dplyr::ungroup(plot_data)
  plot_data$movement <- ifelse(plot_data$rank_change > 0, "riser",
                              ifelse(plot_data$rank_change < 0, "faller", "stable"))
  signed_change <- ifelse(plot_data$rank_change > 0, paste0("+", plot_data$rank_change),
                          as.character(plot_data$rank_change))
  plot_data$.change_label <- switch(change_label,
    change = signed_change,
    ranks = paste0(plot_data$rank_from, " \u2192 ", plot_data$rank_to, " (", signed_change, ")"),
    none = ""
  )
  plot_data$.row <- paste(plot_data$.transition, plot_data$.category_label, sep = "\r")
  plot_data$.row <- factor(plot_data$.row, levels = unique(rev(plot_data$.row)))
  plot_data$.transition <- factor(plot_data$.transition, levels = selected_transitions)

  legend_order <- c("riser", "stable", "faller")
  displayed_movements <- legend_order[legend_order %in% plot_data$movement]
  default_labels <- c(riser = "Riser", faller = "Faller", stable = "Stable")
  if (is.null(legend_labels)) {
    legend_labels <- default_labels
  } else if (is.null(names(legend_labels)) || any(!displayed_movements %in% names(legend_labels))) {
    stop("`legend_labels` must be named for every displayed movement: ",
         paste(displayed_movements, collapse = ", "), ".", call. = FALSE)
  }
  if (is.null(title)) {
    title <- if (length(selected_transitions) == 1L) paste0("Largest changes in rank: ", selected_transitions) else "Largest changes in rank"
  }
  if (is.null(subtitle)) subtitle <- "Positive values rose in rank; negative values fell"

  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = rank_change, y = .row, fill = movement)) +
    ggplot2::geom_vline(xintercept = 0, colour = "#98A2B3", linewidth = 0.45) +
    ggplot2::geom_col(width = 0.68) +
    ggplot2::geom_point(data = plot_data[plot_data$rank_change == 0, , drop = FALSE],
                        shape = 21, size = 2.5, stroke = 0, colour = NA)
  if (change_label != "none") {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = .change_label, hjust = ifelse(rank_change < 0, 1.12, -0.12)),
      size = base_size / 3.3
    )
  }
  p +
    ggplot2::facet_grid(rows = ggplot2::vars(.transition), scales = "free_y", space = "free_y", switch = "y") +
    ggplot2::scale_y_discrete(labels = function(x) sub("^.*\r", "", x)) +
    ggplot2::scale_x_continuous(name = "Rank change", expand = ggplot2::expansion(mult = c(0.20, 0.20))) +
    ggplot2::scale_fill_manual(values = palette[needed_colours], breaks = displayed_movements,
      labels = unname(legend_labels[displayed_movements]), name = legend_title,
      guide = if (show_legend) "legend" else "none") +
    ggplot2::labs(title = title, subtitle = subtitle, y = NULL) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(panel.grid.major.y = ggplot2::element_blank(), panel.grid.minor = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(), legend.position = if (show_legend) "bottom" else "none",
      strip.placement = "outside", strip.text.y.left = ggplot2::element_text(angle = 0, face = "bold"),
      plot.title.position = "plot", plot.margin = ggplot2::margin(12, 24, 12, 12))
}
