test_that("automatic descending and ascending ranks work", {
  x <- data.frame(period = rep(c("a", "b"), each = 3), item = rep(letters[1:3], 2), value = c(3,2,1,1,2,3))
  d <- ggrank_table(x, item, period, value, top_n = 3)
  expect_equal(d$rank[d$period == "a"], 1:3)
  a <- ggrank_table(x, item, period, value, top_n = 3, direction = "ascending")
  expect_equal(a$category[a$period == "a" & a$rank == 1], "c")
})

test_that("entrants and exits remain visible", {
  x <- data.frame(period = rep(c(2020, 2025), each = 14), item = rep(letters[1:14], 2), value = c(14:1, 14:1))
  x$value[x$period == 2025 & x$item == "n"] <- 20
  z <- ggrank_table(x, item, period, value, top_n = 10)
  expect_true(any(z$category == "n" & z$period == 2020 & z$rank == 14))
  expect_true(any(z$category == "j" & z$period == 2025 & !z$in_top))
  expect_equal(z$display_position[z$category == "n" & z$period == 2020], 11)
})

test_that("supplied ranks and labels are retained", {
  x <- data.frame(period = rep(c("before", "after"), each = 2), item = rep(c("A", "B"), 2), value = c(4, 3, 2, 5), supplied = c(2, 1, 2, 1), shown = paste0("n=", 1:4))
  z <- ggrank_table(x, item, period, value, rank = supplied, label = shown, top_n = 2)
  key <- paste(z$period, z$category)
  original <- match(key, paste(x$period, x$item))
  expect_equal(z$rank, x$supplied[original])
  expect_equal(z$label, x$shown[original])
})

test_that("validation catches duplicate category-period rows", {
  x <- data.frame(period = c(1,1,2), item = c("a","a","a"), value = 1:3)
  expect_error(ggrank_table(x, item, period, value), "exactly once")
})

test_that("ggrank returns a ggplot", {
  expect_s3_class(ggrank(ggrank::ggrank_products, product, year, sales, top_n = 5), "ggplot")
})

test_that("tied ranks receive distinct display positions", {
  x <- data.frame(period = rep(c("a", "b"), each = 3), item = rep(letters[1:3], 2), value = c(3, 2, 2, 3, 2, 2))
  z <- ggrank_table(x, item, period, value, top_n = 3, ties = "dense")
  expect_equal(length(unique(z$display_position[z$period == "a"])), 3)
})

test_that("layout widths must be positive", {
  expect_error(
    ggrank(ggrank::ggrank_products, product, year, sales, value_width = 0),
    "positive numbers"
  )
})
