test_that("automatic descending and ascending ranks work", {
  x <- data.frame(period = rep(c("a", "b"), each = 3), item = rep(letters[1:3], 2), value = c(3,2,1,1,2,3))
  d <- ggrank_table(x, item, period, value, top_n = 3)
  expect_equal(d$rank_from[order(d$rank_from)], 1:3)
  a <- ggrank_table(x, item, period, value, top_n = 3, direction = "ascending")
  expect_equal(a$category[a$rank_from == 1], "c")
})

test_that("entrants and exits remain visible", {
  x <- data.frame(period = rep(c(2020, 2025), each = 14), item = rep(letters[1:14], 2), value = c(14:1, 14:1))
  x$value[x$period == 2025 & x$item == "n"] <- 20
  z <- ggrank_table(x, item, period, value, top_n = 10)
  expect_equal(z$rank_from[z$category == "n"], 14)
  expect_equal(z$rank_to[z$category == "n"], 1)
  expect_equal(z$status[z$category == "n"], "entrant")
  expect_equal(z$status[z$category == "j"], "exit")
})

test_that("supplied ranks and labels are retained", {
  x <- data.frame(period = rep(c("before", "after"), each = 2), item = rep(c("A", "B"), 2), value = c(4, 3, 2, 5), supplied = c(2, 1, 2, 1), shown = paste0("n=", 1:4))
  z <- ggrank_table(x, item, period, value, rank = supplied, label = shown, top_n = 2, check_rank = FALSE)
  expect_equal(z$rank_from[match(c("A", "B"), z$category)], c(2, 1))
  expect_equal(z$rank_to[match(c("A", "B"), z$category)], c(2, 1))
  expect_equal(z$label_from[match(c("A", "B"), z$category)], c("n=1", "n=2"))
  expect_equal(z$label_to[match(c("A", "B"), z$category)], c("n=3", "n=4"))
})

test_that("validation catches duplicate category-period rows", {
  x <- data.frame(period = c(1,1,2), item = c("a","a","a"), value = 1:3)
  expect_error(ggrank_table(x, item, period, value), "exactly once")
})

test_that("ggrank returns a ggplot", {
  expect_s3_class(ggrank(ggrank::ggrank_products, product, year, sales, top_n = 5), "ggplot")
})

test_that("ggrank_change visualises a rank-change table", {
  changes <- ggrank_table(
    ggrank::ggrank_products, product, year, sales,
    periods = c(2022, 2024), top_n = 5
  )
  plot <- ggrank_change(changes, top = 3)
  expect_s3_class(plot, "ggplot")
  expect_lte(nrow(plot$data), 3)
  expect_true(all(unique(plot$data$movement) %in% c("riser", "faller", "stable")))
  expect_true(all(c("riser", "faller") %in% plot$data$movement))
})

test_that("ggrank_change checks its input", {
  expect_error(ggrank_change(data.frame(category = "A")), "missing required")
  expect_error(ggrank_change(data.frame(
    category = "A", from = "a", to = "b", rank_change = NA_real_
  )), "no finite rank changes")
})

test_that("the packaged GUI and launcher are available", {
  app_file <- system.file("shiny", "ggrank", "app.R", package = "ggrank")
  expect_true(file.exists(app_file))
  expect_true(all(c("...", "launch.browser") %in% names(formals(ggrank_app))))
  app_text <- paste(readLines(app_file), collapse = "\n")
  expect_match(app_text, "Reusable R code", fixed = TRUE)
  expect_match(app_text, "Download .R", fixed = TRUE)
  expect_match(app_text, "Close app", fixed = TRUE)
  expect_match(app_text, "local app session", fixed = TRUE)
})

test_that("tied ranks receive distinct display positions", {
  x <- data.frame(period = rep(c("a", "b"), each = 3), item = rep(letters[1:3], 2), value = c(3, 2, 2, 3, 2, 2))
  z <- ggrank:::.prepare_ggrank_data(x, item, period, value, top_n = 3, ties = "dense")
  expect_equal(length(unique(z$display_position[z$period == "a"])), 3)
})

test_that("multi-state tables contain adjacent transitions", {
  z <- ggrank_table(ggrank::ggrank_products, product, year, sales,
                    periods = c(2022, 2023, 2024), top_n = 5)
  expect_equal(unique(paste(z$from, z$to)), c("2022 2023", "2023 2024"))
})

test_that("layout widths must be positive", {
  expect_error(
    ggrank(ggrank::ggrank_products, product, year, sales, value_width = 0),
    "positive numbers"
  )
})

test_that("competition ranking is the default", {
  x <- data.frame(period = rep(c("a", "b"), each = 5), item = rep(LETTERS[1:5], 2), value = rep(c(5, 4, 3, 3, 2), 2))
  z <- ggrank_data(x, item, period, value)
  expect_equal(z$rank[z$period == "a"], c(1, 2, 3, 3, 5))
  expect_equal(z$display_position[z$period == "a"], 1:5)
})

test_that("all ties at the top-n boundary are retained", {
  x <- data.frame(period = rep(c("a", "b"), each = 5), item = rep(LETTERS[1:5], 2), value = rep(c(5, 4, 3, 3, 2), 2))
  z <- ggrank:::.prepare_ggrank_data(x, item, period, value, top_n = 3)
  expect_setequal(z$category[z$period == "a"], LETTERS[1:4])
})

test_that("display labels do not alter exact-value ranks", {
  x <- data.frame(period = rep(c("a", "b"), each = 2), item = rep(c("A", "B"), 2), value = c(3.48, 3.44, 3.48, 3.44), shown = "3")
  z <- ggrank_data(x, item, period, value, label = shown)
  expect_equal(z$rank[z$period == "a"], c(1, 2))
  expect_equal(z$label[z$period == "a"], c("3", "3"))
})

test_that("missing values are warned about and distinguished", {
  x <- data.frame(period = rep(c("a", "b"), each = 2), item = rep(c("A", "B"), 2), value = c(2, 1, 3, NA))
  expect_warning(
    z <- ggrank_table(x, item, period, value, top_n = 2),
    "excluded"
  )
  expect_equal(z$status[z$category == "B"], "missing")
  expect_true(z$missing_to[z$category == "B"])
})

test_that("supplied-rank disagreements produce optional warnings", {
  x <- data.frame(period = rep(c("a", "b"), each = 3), item = rep(LETTERS[1:3], 2), value = c(3, 2, 2, 3, 2, 1), supplied = c(1, 2, 3, 1, 2, 3))
  expect_warning(
    ggrank_data(x, item, period, value, rank = supplied),
    "equal-value"
  )
  expect_no_warning(
    ggrank_data(x, item, period, value, rank = supplied, check_rank = FALSE)
  )
})

test_that("supplied ranks must be positive whole numbers", {
  x <- data.frame(period = c("a", "b"), item = "A", value = 1, supplied = c(1, 1.5))
  expect_error(
    ggrank_data(x, item, period, value, rank = supplied),
    "whole numbers"
  )
})
