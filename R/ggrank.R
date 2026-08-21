#' Draw a rank-transition chart
#'
#' Creates a `ggplot2` chart that combines ranked tables with connecting lines.
#' Categories entering or exiting `top_n` remain visible outside the boundary.
#'
#' @inheritParams ggrank_table
#' @param colour_by Colour categories by `"group"`, `"movement"`, or `"none"`.
#'   The default `"auto"` uses groups when supplied and movement otherwise.
#' @param palette Optional named colour vector.
#' @param category_header,value_header Headers shown over the two box columns.
#' @param label_wrap Approximate number of characters per category-label line.
#' @param base_size Base text size passed to [theme_ggrank()].
#' @param title,subtitle Optional plot title and subtitle.
#'
#' @return A `ggplot` object.
#' @export
#' @examples
#' ggrank(ggrank_causes, cause, year, rate,
#'   rank = rank, label = display_value, group = cause_group,
#'   periods = c(1990, 2021), top_n = 10
#' )
ggrank <- function(data, category, period, value, rank = NULL, label = NULL,
                   group = NULL, periods = NULL, top_n = 10,
                   direction = c("descending", "ascending"),
                   ties = c("first", "min", "dense"),
                   show_transitions = c("boundary", "top_only", "all"),
                   colour_by = c("auto", "group", "movement", "none"),
                   palette = NULL, category_header = "Category",
                   value_header = "Value", label_wrap = 28, base_size = 11,
                   title = NULL, subtitle = NULL) {
  direction <- match.arg(direction)
  ties <- match.arg(ties)
  show_transitions <- match.arg(show_transitions)
  colour_by <- match.arg(colour_by)
  group_q <- rlang::enquo(group)
  tbl <- ggrank_table(data, {{ category }}, {{ period }}, {{ value }},
    rank = {{ rank }}, label = {{ label }}, group = {{ group }}, periods = periods,
    top_n = top_n, direction = direction, ties = ties,
    show_transitions = show_transitions)

  has_group <- !rlang::quo_is_null(group_q) && any(!is.na(tbl$group))
  if (colour_by == "auto") colour_by <- if (has_group) "group" else "movement"
  if (colour_by == "group" && !has_group) stop("`colour_by = \"group\"` requires a `group` column.", call. = FALSE)
  if (colour_by == "movement") {
    movement_by_category <- vapply(split(tbl, tbl$.category), function(z) {
      z <- z[order(z$.period_index), , drop = FALSE]
      first <- z[1, , drop = FALSE]
      last <- z[nrow(z), , drop = FALSE]
      if (first$.period_index > 1L) return("new")
      if (last$.period_index < max(tbl$.period_index)) return("exit")
      if (!first$in_top && last$in_top) return("entrant")
      if (first$in_top && !last$in_top) return("exit")
      delta <- first$rank - last$rank
      if (delta > 0) "riser" else if (delta < 0) "faller" else "stable"
    }, character(1))
    tbl$.colour <- unname(movement_by_category[as.character(tbl$.category)])
  } else {
    tbl$.colour <- if (colour_by == "group") tbl$group else "Category"
  }
  tbl$.colour[is.na(tbl$.colour)] <- "Other"
  levels_colour <- unique(tbl$.colour)
  if (is.null(palette)) {
    movement <- c(stable = "#667085", riser = "#17845B", faller = "#C44E52", entrant = "#3465A4", exit = "#C77800", new = "#7A5AA6", Category = "#52616B", Other = "#98A2B3")
    palette <- if (all(levels_colour %in% names(movement))) movement[levels_colour] else stats::setNames(scales::hue_pal(l = 55, c = 80)(length(levels_colour)), levels_colour)
  } else if (is.null(names(palette)) && length(palette) >= length(levels_colour)) {
    names(palette) <- levels_colour
  }
  if (any(!levels_colour %in% names(palette))) stop("`palette` must supply a colour for every displayed group/status.", call. = FALSE)

  spacing <- 4.5
  tbl$x <- (tbl$.period_index - 1) * spacing
  tbl$y <- -tbl$display_position
  tbl$category_text <- paste0(tbl$rank, "  ", vapply(strwrap(as.character(tbl$category), width = label_wrap, simplify = FALSE), paste, collapse = "\n", FUN.VALUE = character(1)))
  box_h <- 0.42
  links <- merge(
    tbl[, c(".category", ".period_index", "x", "y", ".colour")],
    tbl[, c(".category", ".period_index", "x", "y")],
    by = ".category", suffixes = c("", "_next")
  )
  links <- links[links$.period_index_next == links$.period_index + 1L, ]

  headers <- unique(tbl[, c(".period_index", ".period_label")])
  headers$x <- (headers$.period_index - 1) * spacing
  p <- ggplot2::ggplot()
  if (nrow(links)) p <- p + ggplot2::geom_segment(data = links, ggplot2::aes(x = x + 1.55, xend = x_next - 1.55, y = y, yend = y_next, colour = .colour), linewidth = 0.7, alpha = 0.75)
  p <- p +
    ggplot2::geom_rect(data = tbl, ggplot2::aes(xmin = x - 1.5, xmax = x + 0.55, ymin = y - box_h, ymax = y + box_h, colour = .colour, fill = .colour), linewidth = 0.55, alpha = 0.10) +
    ggplot2::geom_rect(data = tbl, ggplot2::aes(xmin = x + 0.60, xmax = x + 1.50, ymin = y - box_h, ymax = y + box_h, colour = .colour), fill = "white", linewidth = 0.55) +
    ggplot2::geom_text(data = tbl, ggplot2::aes(x = x - 1.42, y = y, label = category_text), hjust = 0, lineheight = 0.9, size = base_size / 3.2) +
    ggplot2::geom_text(data = tbl, ggplot2::aes(x = x + 1.05, y = y, label = label), size = base_size / 3.4) +
    ggplot2::geom_text(data = headers, ggplot2::aes(x = x, y = 0.8, label = .period_label), fontface = "bold", size = base_size / 2.6) +
    ggplot2::geom_text(data = headers, ggplot2::aes(x = x - 1.5, y = 0.15, label = category_header), hjust = 0, fontface = "bold", size = base_size / 3.2) +
    ggplot2::geom_text(data = headers, ggplot2::aes(x = x + 1.05, y = 0.15, label = value_header), fontface = "bold", size = base_size / 3.2) +
    ggplot2::scale_color_manual(values = palette, name = NULL) +
    ggplot2::scale_fill_manual(values = palette, guide = "none") +
    ggplot2::coord_cartesian(clip = "off") +
    ggplot2::labs(title = title, subtitle = subtitle) +
    theme_ggrank(base_size = base_size)
  p
}
