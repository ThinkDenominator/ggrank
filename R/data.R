#' Synthetic GBD-inspired causes
#'
#' A synthetic teaching dataset with cause rankings and uncertainty intervals.
#' Values do not represent published Global Burden of Disease estimates.
#' This dataset was generated specifically for package examples and contains no
#' downloaded IHME or Global Burden of Disease data. The package is independent
#' and is not affiliated with or endorsed by IHME.
#'
#' @format A data frame with 36 rows and 8 variables: `year`, `cause`,
#' `cause_group`, `rank`, `rate`, `lower`, `upper`, and `display_value`.
#' @source Synthetic data created for ggrank.
"ggrank_causes"

#' Synthetic product rankings
#'
#' A general-purpose teaching dataset of product sales across three years.
#' Every product name, ranking, and sales value is synthetic and was generated
#' specifically for package teaching examples.
#'
#' @format A data frame with 24 rows and 4 variables: `year`, `product`,
#' `category`, and `sales`.
#' @source Synthetic data created for ggrank.
"ggrank_products"
