causes <- c("Ischaemic heart disease", "Stroke", "COPD", "Lower respiratory infections", "Neonatal disorders", "Diabetes", "Lung cancer", "Diarrhoeal diseases", "Road injuries", "Kidney disease", "Tuberculosis", "Alzheimer disease")
groups <- c("Non-communicable", "Non-communicable", "Non-communicable", "Communicable", "Communicable", "Non-communicable", "Non-communicable", "Communicable", "Injuries", "Non-communicable", "Communicable", "Non-communicable")
ranks <- list(`1990` = c(1,2,5,3,4,9,10,6,7,12,8,14), `2010` = c(1,2,4,5,8,6,7,10,9,11,13,12), `2021` = c(1,2,3,6,11,5,7,14,13,8,16,4))
ggrank_causes <- do.call(rbind, lapply(names(ranks), function(y) {
  r <- ranks[[y]]; rate <- round(185 / sqrt(r) + as.numeric(y) %% 17, 1)
  data.frame(year = as.integer(y), cause = causes, cause_group = groups, rank = r,
             rate = rate, lower = round(rate * .92, 1), upper = round(rate * 1.08, 1))
}))
ggrank_causes$display_value <- sprintf("%.1f (%.1f–%.1f)", ggrank_causes$rate, ggrank_causes$lower, ggrank_causes$upper)

products <- paste("Product", LETTERS[1:8])
cats <- rep(c("Home", "Work", "Leisure", "Travel"), each = 2)
orders <- list(`2022` = c(1,2,3,4,5,6,7,8), `2023` = c(2,1,5,3,7,4,8,6), `2024` = c(4,1,6,2,3,7,8,5))
ggrank_products <- do.call(rbind, lapply(names(orders), function(y) {
  r <- orders[[y]]
  data.frame(year = as.integer(y), product = products, category = cats,
             sales = (9 - r) * 1000 + as.integer(y) %% 10 * 17)
}))
save(ggrank_causes, file = "data/ggrank_causes.rda", compress = "xz")
save(ggrank_products, file = "data/ggrank_products.rda", compress = "xz")

