## Manual test: synthetic sports leaderboards
## Run from the package root, one section at a time. No loops are used.

devtools::load_all(".")

football <- data.frame(
  season = rep(c("2024", "2025"), each = 20),
  club = rep(c(
    "Ashford Athletic", "Bayside City", "Cedar United", "Docklands FC",
    "Eastborough", "Forest Rovers", "Granite Town", "Harbour Albion",
    "Ironbridge", "Juniper Wanderers", "Kingsport", "Lakeside FC",
    "Meadow County", "Northgate", "Oakfield", "Parkside Rangers",
    "Queensborough", "Riverside", "Stonehaven", "Westford"
  ), 2),
  points = c(
    91, 86, 82, 78, 74, 70, 66, 63, 60, 57,
    54, 51, 48, 45, 42, 39, 36, 33, 29, 24,
    84, 92, 76, 81, 69, 73, 61, 65, 58, 55,
    52, 49, 46, 43, 40, 37, 34, 31, 27, 22
  )
)


## 1. Top five ---------------------------------------------------------------

football_top_5 <- ggrank(
  football, club, season, points,
  top_n = 5,
  value_header = "Points",
  title = "Football title race: top five"
)

football_top_5


## 2. Top ten ----------------------------------------------------------------

football_top_10 <- ggrank(
  football, club, season, points,
  top_n = 10,
  value_header = "Points",
  label_wrap = 20,
  title = "Football league: top ten"
)

football_top_10


## 3. Complete twenty-club table ---------------------------------------------

football_top_20 <- ggrank(
  football, club, season, points,
  top_n = 20,
  value_header = "Points",
  label_wrap = 20,
  base_size = 9,
  title = "Complete football league table"
)

football_top_20

## Inspect this plot in a tall plotting window.
## Optional export:
## ggplot2::ggsave("football-top-20.png", football_top_20,
##                 width = 14, height = 11, units = "in", dpi = 300)


## 4. Rank-only cricket leaderboard ------------------------------------------

cricket <- data.frame(
  season = rep(c("2025", "2026"), each = 10),
  team = rep(c(
    "Bengaluru Blazers", "Chennai Super Kings (CSK)", "Delhi Comets", "Gujarat Falcons",
    "Hyderabad Suns", "Jaipur Royals", "Kolkata Knights", "Lucknow Leopards",
    "Mumbai Mariners", "Punjab Panthers"
  ), 2),
  rank = c(2, 1, 3, 4, 5, 6, 7, 8, 9, 10,
           4, 1, 5, 2, 8, 3, 6, 10, 7, 9)
)

cricket_top_10 <- ggrank(
  cricket, team, season,
  rank = rank,
  top_n = 10,
  label_wrap = 20,
  title = "Cricket league standings"
)

cricket_top_10


## 5. Thirty-rank layout stress test -----------------------------------------

large_leaderboard <- data.frame(
  season = rep(c("Round 1", "Round 2"), each = 30),
  player = rep(sprintf("Player %02d", 1:30), 2),
  rank = c(1:30, c(6:30, 1:5))
)

leaderboard_top_30 <- ggrank(
  large_leaderboard, player, season,
  rank = rank,
  top_n = 30,
  label_wrap = 16,
  base_size = 8,
  title = "Thirty-player gaming leaderboard"
)

leaderboard_top_30

## Inspect in a tall plotting window. For export, begin around 14–16 inches
## high rather than trying to fit thirty rows on a normal presentation slide.
