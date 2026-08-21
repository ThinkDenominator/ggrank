#' Visualise the largest rank changes
#'
#' Turns the output of [ggrank_table()] into a focused diverging bar chart.
#' Positive values indicate a rise in rank and negative values indicate a fall.
#'
#' @param data A rank-change table returned by [ggrank_table()].
#' @param top Maximum number of categories to display for each transition,
#'   selected by absolute rank change.
#' @param palette Named colours for `riser`, `faller`, and `stable`.
#' @param base_size Base text size.
#' @param title,subtitle Optional plot title and subtitle.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' changes <- ggrank_table(
#'   ggrank_products, product, year, sales,
#'   periods = c(2022, 2024), top_n = 5
#' )
#' ggrank_change(changes, top = 5)
ggrank_change <- function(data, top = 15,
                          palette = c(riser = "#17845B",
                                      faller = "#C44E52",
                                      stable = "#667085"),
                          base_size = 11, title = NULL, subtitle = NULL) {
  required <- c("category", "from", "to", "rank_change")
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame returned by `ggrank_table()`.",
         call. = FALSE)
  }
  missing_columns <- setdiff(required, names(data))
  if (length(missing_columns)) {
    stop("`data` is missing required column", if (length(missing_columns) > 1L) "s" else "",
         ": ", paste(missing_columns, collapse = ", "), ".",
         call. = FALSE)
  }
  if (!is.numeric(data$rank_change)) {
    stop("`rank_change` must be numeric.", call. = FALSE)
  }
  if (length(top) != 1L || is.na(top) || !is.finite(top) ||
      top < 1 || top != as.integer(top)) {
    stop("`top` must be one positive whole number.", call. = FALSE)
  }
  if (length(base_size) != 1L || is.na(base_size) || !is.finite(base_size) ||
      base_size <= 0) {
    stop("`base_size` must be one positive number.", call. = FALSE)
  }
  needed_colours <- c("riser", "faller", "stable")
  if (is.null(names(palette)) || any(!needed_colours %in% names(palette))) {
    stop("`palette` must provide named colours for riser, faller, and stable.",
         call. = FALSE)
  }

  plot_data <- data[is.finite(data$rank_change), required, drop = FALSE]
  if (!nrow(plot_data)) {
    stop("`data` contains no finite rank changes to plot.", call. = FALSE)
  }
  plot_data$category <- as.character(plot_data$category)
  plot_data$from <- as.character(plot_data$from)
  plot_data$to <- as.character(plot_data$to)
  plot_data$.transition <- paste(plot_data$from, plot_data$to, sep = " to ")
  plot_data$.absolute_change <- abs(plot_data$rank_change)
  plot_data <- dplyr::group_by(plot_data, .transition)
  plot_data <- dplyr::arrange(plot_data, dplyr::desc(.absolute_change),
                              category, .by_group = TRUE)
  plot_data <- dplyr::slice_head(plot_data, n = as.integer(top))
  plot_data <- dplyr::ungroup(plot_data)
  plot_data$movement <- ifelse(plot_data$rank_change > 0, "riser",
                              ifelse(plot_data$rank_change < 0, "faller", "stable"))
  plot_data$change_label <- ifelse(plot_data$rank_change > 0,
                                   paste0("+", plot_data$rank_change),
                                   as.character(plot_data$rank_change))
  plot_data$.row <- paste(plot_data$.transition, plot_data$category, sep = "\r")
  row_order <- rev(plot_data$.row)
  plot_data$.row <- factor(plot_data$.row, levels = unique(row_order))

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = rank_change, y = .row, fill = movement)
  ) +
    ggplot2::geom_vline(xintercept = 0, colour = "#98A2B3", linewidth = 0.45) +
    ggplot2::geom_col(width = 0.68) +
    ggplot2::geom_point(
      data = plot_data[plot_data$rank_change == 0, , drop = FALSE],
      shape = 21, size = 2.5, stroke = 0, colour = NA
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = change_label,
                   hjust = ifelse(rank_change < 0, 1.15, -0.15)),
      size = base_size / 3.3
    ) +
    ggplot2::facet_grid(rows = ggplot2::vars(.transition), scales = "free_y",
                        space = "free_y", switch = "y") +
    ggplot2::scale_y_discrete(labels = function(x) sub("^.*\r", "", x)) +
    ggplot2::scale_x_continuous(
      name = "Rank change",
      expand = ggplot2::expansion(mult = c(0.14, 0.14))
    ) +
    ggplot2::scale_fill_manual(values = palette[needed_colours],
                               breaks = needed_colours, name = NULL) +
    ggplot2::labs(title = title, subtitle = subtitle, y = NULL) +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      legend.position = "bottom",
      strip.placement = "outside",
      strip.text.y.left = ggplot2::element_text(angle = 0, face = "bold"),
      plot.title.position = "plot",
      plot.margin = ggplot2::margin(12, 18, 12, 12)
    )
}
