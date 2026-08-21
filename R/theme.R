#' A minimal theme for rank-transition charts
#'
#' @param base_size Base font size.
#' @param base_family Base font family.
#' @return A complete `ggplot2` theme.
#' @export
#' @examples
#' theme_ggrank()
theme_ggrank <- function(base_size = 11, base_family = "") {
  ggplot2::`%+replace%`(ggplot2::theme_minimal(base_size = base_size, base_family = base_family),
    ggplot2::theme(
      axis.title = ggplot2::element_blank(), axis.text = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(), panel.grid = ggplot2::element_blank(),
      legend.position = "bottom", legend.direction = "horizontal",
      plot.title.position = "plot", plot.caption.position = "plot",
      plot.margin = ggplot2::margin(12, 12, 12, 12)
    ))
}
