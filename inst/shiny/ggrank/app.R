library(shiny)
library(ggrank)

movement_palette <- c(
  riser = "#0072B2", faller = "#D55E00", stable = "#667085"
)

app_css <- "
body { background: #FAFAF8; color: #1C1C1E; }
.navbar, .well { border-radius: 0; }
.well { background: #FFFFFF; border: 1px solid #E3E3DE; }
.btn-primary { background: #17324D; border-color: #17324D; }
.app-close { position: fixed; right: 18px; bottom: 14px; z-index: 1000; }
.code-card { margin-top: 18px; padding: 14px; background: #F5F5F2;
  border: 1px solid #E3E3DE; border-radius: 6px; }
.help-copy { color: #5B616B; }
.guide-box { padding: 12px 15px; margin-bottom: 14px; background: #EEF4F8;
  border-left: 4px solid #17324D; }
.guide-box ol { margin-bottom: 0; }
details.advanced { margin: 14px 0; padding: 9px 11px; background: #F7F7F5;
  border: 1px solid #E3E3DE; border-radius: 6px; }
details.advanced summary { cursor: pointer; font-weight: 700; }
"

ui <- fluidPage(
  tags$head(tags$style(HTML(app_css))),
  titlePanel(tagList("ggrank", tags$small(" guided rank explorer"))),
  tags$p(
    class = "help-copy",
    "A point-and-click companion that uses the same ggrank functions and produces reusable R code."
  ),
  tags$div(class = "guide-box",
    tags$strong("Four steps"),
    tags$ol(
      tags$li("Choose teaching data or upload a CSV."),
      tags$li("Select category and period columns."),
      tags$li("Choose whether to calculate ranks from values or use an existing rank column."),
      tags$li("Select 2–4 periods, then click Create charts.")
    )
  ),
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        "source", "Data source",
        choices = c("Synthetic products" = "products",
                    "Synthetic causes" = "causes",
                    "Upload CSV" = "upload")
      ),
      conditionalPanel(
        "input.source == 'upload'",
        fileInput("file", "CSV file", accept = c(".csv", "text/csv")),
        tags$p(class = "help-copy",
               "Uploaded data stay in this local app session and are not sent by ggrank to an external service.")
      ),
      tags$details(class = "advanced",
        tags$summary("What should my data look like?"),
        tags$p("Use one row per category and period. Either of these forms works:"),
        tags$pre("student,institution,year,rank\nA,North,2024,1\nB,North,2024,2\nA,North,2025,3\nB,North,2025,1"),
        tags$pre("product,year,sales\nA,2024,120\nB,2024,95\nA,2025,130\nB,2025,140"),
        tags$p(class = "help-copy", "Rank-only data do not need marks, rates, scores, or another value column.")
      ),
      selectInput("category", "Category column", choices = NULL),
      selectInput("period", "Period column", choices = NULL),
      radioButtons("ranking_source", "How are ranks supplied?",
        choices = c("Calculate from numeric values" = "value",
                    "Use an existing rank column" = "rank")),
      conditionalPanel("input.ranking_source == 'value'",
        selectInput("value", "Numeric value column", choices = NULL),
        tags$p(class = "help-copy", "Exact values determine rank; the largest value ranks first by default.")
      ),
      conditionalPanel("input.ranking_source == 'rank'",
        selectInput("rank", "Existing rank column", choices = NULL),
        selectInput("rank_value", "Value column to display (optional)", choices = "None"),
        tags$p(class = "help-copy", "Ranks must be positive whole numbers. A value column is not required.")
      ),
      checkboxGroupInput("periods", "Periods (select 2–4)", choices = NULL),
      numericInput("top_n", "Top-rank threshold", value = 5, min = 1, step = 1),
      tags$details(class = "advanced",
        tags$summary("Advanced options"),
        selectInput("label", "Display label column (optional)", choices = "None"),
        selectInput("group", "Colour group column (optional)", choices = "None"),
        selectInput("direction", "Value ranking direction",
                    choices = c("Largest value first" = "descending",
                                "Smallest value first" = "ascending")),
        selectInput("ties", "Tie method for calculated ranks",
                    choices = c("Competition (1, 2, 2, 4)" = "min",
                                "Dense (1, 2, 2, 3)" = "dense",
                                "Alphabetical tie-break" = "first")),
        selectInput("change_comparison", "Change-chart comparisons",
                    choices = c("Latest comparison" = "latest",
                                "All comparisons" = "all")),
        selectInput("change_label", "Change-chart labels",
                    choices = c("Signed change (+4)" = "change",
                                "Ranks and change (7 → 3, +4)" = "ranks",
                                "No bar labels" = "none")),
        checkboxInput("show_stable", "Include unchanged ranks", FALSE)
      ),
      actionButton("draw", "Create charts", class = "btn-primary"),
      br(), br(),
      conditionalPanel(
        "input.view == 'Rank chart' || input.view == 'Change chart'",
        downloadButton("download_plot", "Download current plot")
      )
    ),
    mainPanel(
      helpText("Rank change is positive when a category rises and negative when it falls."),
      tabsetPanel(
        id = "view",
        tabPanel("Rank chart", plotOutput("rank_plot", height = "720px")),
        tabPanel("Change chart", plotOutput("change_plot", height = "620px")),
        tabPanel("Rank-change table", tableOutput("change_table")),
        tabPanel("Ranked data", tableOutput("ranked_data"))
      ),
      tags$div(
        class = "code-card",
        tags$h4("Reusable R code"),
        tags$p(class = "help-copy",
               "Copy or download this code to reproduce the current outputs without the app."),
        downloadButton("download_code", "Download .R"),
        verbatimTextOutput("analysis_code")
      )
    )
  ),
  tags$div(class = "app-close",
           actionButton("close_app", "Close app", class = "btn-danger"))
)

server <- function(input, output, session) {
  source_data <- reactive({
    if (input$source == "products") return(ggrank_products)
    if (input$source == "causes") return(ggrank_causes)
    req(input$file)
    read.csv(input$file$datapath, check.names = FALSE,
             stringsAsFactors = FALSE)
  })

  observeEvent(source_data(), {
    data <- source_data()
    columns <- names(data)
    numeric_columns <- columns[vapply(data, is.numeric, logical(1))]
    optional <- c("None", columns)
    optional_numeric <- c("None", numeric_columns)
    defaults <- if (input$source == "causes") {
      list(category = "cause", period = "year", value = "rate",
           rank = "rank", label = "display_value", group = "cause_group")
    } else {
      list(category = "product", period = "year", value = "sales",
           rank = "None", label = "None", group = "category")
    }
    selected_or_first <- function(selected, choices) {
      if (selected %in% choices) selected else choices[1]
    }
    updateSelectInput(session, "category", choices = columns,
                      selected = selected_or_first(defaults$category, columns))
    updateSelectInput(session, "period", choices = columns,
                      selected = selected_or_first(defaults$period, columns))
    updateSelectInput(session, "value", choices = numeric_columns,
                      selected = selected_or_first(defaults$value, numeric_columns))
    updateSelectInput(session, "rank", choices = numeric_columns,
                      selected = selected_or_first(defaults$rank, numeric_columns))
    updateSelectInput(session, "rank_value", choices = optional_numeric,
                      selected = if (defaults$value %in% optional_numeric) defaults$value else "None")
    updateSelectInput(session, "label", choices = optional,
                      selected = if (defaults$label %in% optional) defaults$label else "None")
    updateSelectInput(session, "group", choices = optional,
                      selected = if (defaults$group %in% optional) defaults$group else "None")
    updateRadioButtons(session, "ranking_source",
                       selected = if (input$source == "causes") "rank" else "value")
  }, ignoreInit = FALSE)

  observeEvent(list(source_data(), input$period), {
    req(input$period, input$period %in% names(source_data()))
    raw_choices <- source_data()[[input$period]]
    choices <- unique(as.character(raw_choices))
    if (is.numeric(raw_choices) || inherits(raw_choices, c("Date", "POSIXt"))) {
      choices <- as.character(sort(unique(raw_choices)))
    }
    selected <- if (length(choices) > 1L) choices[c(1L, length(choices))] else choices
    updateCheckboxGroupInput(session, "periods", choices = choices,
                             selected = selected)
  }, ignoreInit = TRUE)

  outputs <- eventReactive(input$draw, {
    data <- source_data()
    req(input$category, input$period, input$ranking_source)
    use_rank <- identical(input$ranking_source, "rank")
    value_name <- if (use_rank) input$rank_value else input$value
    rank_name <- if (use_rank) input$rank else "None"
    validate(
      need(use_rank || (value_name %in% names(data) && is.numeric(data[[value_name]])),
           "Choose a numeric value column, or select existing ranks."),
      need(!use_rank || (rank_name %in% names(data) && is.numeric(data[[rank_name]])),
           "Choose a numeric existing-rank column."),
      need(length(input$periods) >= 2 && length(input$periods) <= 4,
           "Select between two and four periods."),
      need(input$top_n >= 1 && input$top_n == as.integer(input$top_n),
           "Top-rank threshold must be a positive whole number.")
    )
    category <- rlang::sym(input$category)
    period <- rlang::sym(input$period)
    value <- if (is.null(value_name) || identical(value_name, "None")) NULL else rlang::sym(value_name)
    rank <- if (identical(rank_name, "None")) NULL else rlang::sym(rank_name)
    label <- if (identical(input$label, "None")) NULL else rlang::sym(input$label)
    group <- if (identical(input$group, "None")) NULL else rlang::sym(input$group)

    table <- rlang::inject(ggrank_table(
      data, !!category, !!period, !!value,
      rank = !!rank, label = !!label, group = !!group,
      periods = input$periods, top_n = as.integer(input$top_n),
      direction = input$direction, ties = input$ties,
      show_transitions = "all"
    ))
    list(
      ranked = rlang::inject(ggrank_data(
        data, !!category, !!period, !!value,
        rank = !!rank, label = !!label, group = !!group,
        periods = input$periods, direction = input$direction,
        ties = input$ties
      )),
      table = table,
      rank_plot = rlang::inject(ggrank(
        data, !!category, !!period, !!value,
        rank = !!rank, label = !!label, group = !!group,
        periods = input$periods, top_n = as.integer(input$top_n),
        direction = input$direction, ties = input$ties,
        label_wrap = 22, category_width = 2.6, value_width = 1.9,
        state_gap = 1.35, base_size = 10,
        title = "Rank transitions"
      )),
      change_plot = tryCatch(
        ggrank_change(table, top = as.integer(input$top_n),
          comparison = input$change_comparison, show_stable = input$show_stable,
          change_label = input$change_label, palette = movement_palette),
        error = function(error) error
      )
    )
  }, ignoreInit = FALSE)

  analysis_code <- eventReactive(input$draw, {
    req(input$category, input$period, input$ranking_source)
    use_rank <- identical(input$ranking_source, "rank")
    value_name <- if (use_rank) input$rank_value else input$value
    rank_name <- if (use_rank) input$rank else "None"
    data_line <- if (input$source == "products") {
      "data <- ggrank_products"
    } else if (input$source == "causes") {
      "data <- ggrank_causes"
    } else {
      'data <- read.csv("your-file.csv", check.names = FALSE)'
    }
    optional_line <- function(argument, selected) {
      if (is.null(selected) || identical(selected, "None")) return(NULL)
      paste0("  ", argument, " = `", selected, "`,")
    }
    period_code <- paste(sprintf('"%s"', input$periods), collapse = ", ")
    mapping <- c(
      paste0("  category = `", input$category, "`,"),
      paste0("  period = `", input$period, "`,"),
      optional_line("value", value_name),
      optional_line("rank", rank_name),
      optional_line("label", input$label),
      optional_line("group", input$group),
      paste0("  periods = c(", period_code, "),"),
      paste0("  top_n = ", as.integer(input$top_n), ","),
      paste0('  direction = "', input$direction, '",'),
      paste0('  ties = "', input$ties, '"')
    )
    table_mapping <- append(mapping, '  show_transitions = "all",',
                            after = length(mapping) - 1L)
    plot_mapping <- append(mapping, c(
      "  label_wrap = 22,", "  category_width = 2.6,",
      "  value_width = 1.9,", "  state_gap = 1.35,", "  base_size = 10,"
    ), after = length(mapping) - 1L)
    paste(c(
      "library(ggrank)", "", data_line, "",
      "changes <- ggrank_table(", "  data = data,", table_mapping, ")", "",
      "rank_plot <- ggrank(", "  data = data,", plot_mapping, ")", "",
      "change_plot <- ggrank_change(", "  data = changes,",
      paste0("  top = ", as.integer(input$top_n), ","),
      paste0('  comparison = "', input$change_comparison, '",'),
      paste0("  show_stable = ", if (isTRUE(input$show_stable)) "TRUE" else "FALSE", ","),
      paste0('  change_label = "', input$change_label, '"'), ")", "",
      "rank_plot", "change_plot", "changes"
    ), collapse = "\n")
  }, ignoreInit = FALSE)

  output$rank_plot <- renderPlot(outputs()$rank_plot, res = 110)
  output$change_plot <- renderPlot({
    plot <- outputs()$change_plot
    message <- if (inherits(plot, "error")) conditionMessage(plot) else ""
    validate(need(!inherits(plot, "error"), message))
    plot
  }, res = 110)
  output$change_table <- renderTable(outputs()$table, striped = TRUE,
                                     bordered = TRUE, spacing = "s")
  output$ranked_data <- renderTable(outputs()$ranked, striped = TRUE,
                                    bordered = TRUE, spacing = "s")
  output$analysis_code <- renderText(analysis_code())
  output$download_plot <- downloadHandler(
    filename = function() {
      view <- if (input$view %in% c("Rank chart", "Change chart")) input$view else "Rank chart"
      paste0("ggrank-", tolower(gsub(" ", "-", view)), ".png")
    },
    content = function(file) {
      plot <- if (identical(input$view, "Change chart")) {
        outputs()$change_plot
      } else {
        outputs()$rank_plot
      }
      if (inherits(plot, "error")) stop(conditionMessage(plot), call. = FALSE)
      ggplot2::ggsave(file, plot, width = 12, height = 7, dpi = 300)
    }
  )
  output$download_code <- downloadHandler(
    filename = function() "ggrank-analysis.R",
    content = function(file) writeLines(analysis_code(), file,
                                        useBytes = TRUE)
  )
  observeEvent(input$close_app, stopApp())
}

shinyApp(ui, server)
