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
  expect_error(ggrank_change(data.frame(category = "A")), "requires")
  expect_error(ggrank_change(data.frame(
    category = "A", from = "a", to = "b", rank_from = NA_real_,
    rank_to = NA_real_, rank_change = NA_real_
  )), "No non-zero rank changes")
})

test_that("ggrank_change defaults to latest and supports all comparisons", {
  changes <- ggrank_table(ggrank::ggrank_products, product, year, sales,
                          top_n = 5, show_transitions = "all")
  latest <- ggrank_change(changes, top = 5)
  expect_equal(unique(as.character(latest$data$.transition)), "2023 to 2024")
  all <- ggrank_change(changes, top = 5, comparison = "all")
  expect_setequal(unique(as.character(all$data$.transition)),
                  c("2022 to 2023", "2023 to 2024"))
  explicit <- ggrank_change(changes, from = 2022, to = 2023)
  expect_equal(unique(as.character(explicit$data$.transition)), "2022 to 2023")
  expect_error(ggrank_change(changes, from = 2022, to = 2024),
               "not present")
})

test_that("ggrank_change uses direction, absolute magnitude, and stable policy", {
  changes <- data.frame(
    category = LETTERS[1:7], from = "before", to = "after",
    rank_from = c(7, 2, 5, 4, 6, 8, 3),
    rank_to = c(3, 5, 1, 6, 5, 9, 3),
    rank_change = c(4, -3, 4, -2, 1, -1, 0),
    status = c("riser", "faller", "riser", "faller", "entrant", "exit", "stable")
  )
  plot <- ggrank_change(changes, top = 5)
  expect_equal(nrow(plot$data), 5)
  expect_setequal(plot$data$category, LETTERS[1:5])
  expect_equal(plot$data$movement[plot$data$category == "A"], "riser")
  expect_equal(plot$data$movement[plot$data$category == "B"], "faller")
  expect_false("G" %in% plot$data$category)
  stable <- ggrank_change(changes, top = 7, show_stable = TRUE,
                          change_label = "ranks", label_wrap = 8)
  expect_true("G" %in% stable$data$category)
  expect_equal(unname(stable$data$.change_label[stable$data$category == "A"]),
               "7 → 3 (+4)")
  expect_equal(stable$data$movement[stable$data$status == "entrant"], "riser")
  expect_equal(stable$data$movement[stable$data$status == "exit"], "faller")
})

test_that("ggrank_change accepts raw data and preserves competition ranks", {
  x <- data.frame(
    period = rep(c("before", "after"), each = 5),
    item = rep(LETTERS[1:5], 2),
    value = c(5, 4, 3, 3, 2, 5, 3, 4, 3, 2)
  )
  plot <- ggrank_change(x, item, period, value, top = 5,
                        show_stable = TRUE)
  expect_s3_class(plot, "ggplot")
  expect_true(any(plot$data$rank_from == 3 & plot$data$category %in% c("C", "D")))
})

test_that("ggrank_change reports an all-stable comparison", {
  stable <- data.frame(category = c("A", "B"), from = "a", to = "b",
                       rank_from = 1:2, rank_to = 1:2, rank_change = 0,
                       status = "stable")
  expect_error(ggrank_change(stable), "No non-zero rank changes")
  expect_s3_class(ggrank_change(stable, show_stable = TRUE), "ggplot")
})

test_that("legend labels are validated and applied", {
  changes <- ggrank_table(ggrank::ggrank_products, product, year, sales,
                          show_transitions = "all")
  labels <- c(riser = "Moved up", faller = "Moved down")
  plot <- ggrank_change(changes, legend_title = "Movement",
                        legend_labels = labels)
  expect_equal(plot$scales$get_scales("fill")$name, "Movement")
  expect_error(ggrank_change(changes, legend_labels = c(riser = "Up")),
               "every displayed movement")
  expect_s3_class(ggrank(ggrank::ggrank_products, product, year, sales,
    colour_by = "movement", legend_title = "Status",
    legend_labels = c(riser = "Up", faller = "Down", stable = "Same",
                      entrant = "Entered", exit = "Exited", new = "New")),
    "ggplot")
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
