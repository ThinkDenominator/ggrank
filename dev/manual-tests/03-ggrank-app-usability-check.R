## ggrank app: short uncoached usability check
##
## Use this with 3--5 people who have not used the app. Do not coach while they
## attempt each task. Record pauses, mis-clicks, expectations, and unclear
## wording. These are interface findings, not participant mistakes.

devtools::load_all(".")

ggrank_app()

## Task 1: Use Synthetic products and create a 2022-to-2024 top-five chart.
## Success: participant selects the two periods, updates outputs, and explains
## what one connector means without assistance.

## Task 2: Open Rank-change table and Change chart.
## Success: participant identifies the largest rise and fall and explains why
## positive rank_change means movement towards rank one.

## Task 3: Open Ranked data and find a category's calculated rank.
## Success: participant distinguishes the exact numeric value from rank and
## understands the selected tie method.

## Task 4: Switch to Synthetic causes.
## Success: the participant recognises the prepared rank, label, and group
## defaults and creates the two-period chart without coaching.

## Task 5: Upload a CSV with category, period, and numeric value columns.
## Success: participant maps the three columns, selects two to four periods,
## and receives all four outputs. Confirm that the local-session privacy note
## is noticed.

## Task 6: Reproduce the result outside the app.
## Success: participant finds Reusable R code, downloads the .R file, and can
## explain that the GUI calls ggrank_data(), ggrank_table(), ggrank(), and
## ggrank_change() rather than implementing a separate ranking procedure.

## Task 7: Download each chart and close the app.
## Success: the selected chart downloads as a PNG and Close app returns control
## to the R console.

## Ask after every task:
## - What did you expect to happen?
## - Which label or control was unclear?
## - Did the app make you confident that the output was reproducible?
