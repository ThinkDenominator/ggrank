library(shiny)
library(ggrank)

movement_palette <- c(
  riser = "#17845B", faller = "#C44E52", stable = "#667085"
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
"

ui <- fluidPage(
  tags$head(tags$style(HTML(app_css))),
  titlePanel(tagList("ggrank", tags$small(" guided rank explorer"))),
  tags$p(
    class = "help-copy",
    "A point-and-click companion that uses the same ggrank functions and produces reusable R code."
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
      selectInput("category", "Category column", choices = NULL),
      selectInput("period", "Period column", choices = NULL),
      selectInput("value", "Numeric value column", choices = NULL),
      selectInput("rank", "Rank column (optional)", choices = "None"),
      selectInput("label", "Display label column (optional)", choices = "None"),
      selectInput("group", "Group column (optional)", choices = "None"),
      checkboxGroupInput("periods", "Periods (select 2–4)", choices = NULL),
      numericInput("top_n", "Top-rank threshold", value = 5, min = 1, step = 1),
      selectInput("direction", "Ranking direction",
                  choices = c("Largest value first" = "descending",
                              "Smallest value first" = "ascending")),
      selectInput("ties", "Tie method",
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
      checkboxInput("show_stable", "Include unchanged ranks", FALSE),
      actionButton("draw", "Update outputs", class = "btn-primary"),
      br(), br(),
      downloadButton("download_plot", "Download current plot")
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
    updateSelectInput(session, "rank", choices = optional,
                      selected = if (defaults$rank %in% optional) defaults$rank else "None")
    updateSelectInput(session, "label", choices = optional,
                      selected = if (defaults$label %in% optional) defaults$label else "None")
    updateSelectInput(session, "group", choices = optional,
                      selected = if (defaults$group %in% optional) defaults$group else "None")
  }, ignoreInit = FALSE)

  observeEvent(list(source_data(), input$period), {
    req(input$period, input$period %in% names(source_data()))
    choices <- unique(as.character(source_data()[[input$period]]))
    updateCheckboxGroupInput(session, "periods", choices = choices,
                             selected = head(choices, 4))
  }, ignoreInit = TRUE)

  outputs <- eventReactive(input$draw, {
    data <- source_data()
    req(input$category, input$period, input$value)
    validate(
      need(input$value %in% names(data) && is.numeric(data[[input$value]]),
           "Choose a numeric value column."),
      need(length(input$periods) >= 2 && length(input$periods) <= 4,
           "Select between two and four periods."),
      need(input$top_n >= 1 && input$top_n == as.integer(input$top_n),
           "Top-rank threshold must be a positive whole number.")
    )
    category <- rlang::sym(input$category)
    period <- rlang::sym(input$period)
    value <- rlang::sym(input$value)
    rank <- if (identical(input$rank, "None")) NULL else rlang::sym(input$rank)
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
        title = "Rank transitions"
      )),
      change_plot = ggrank_change(
        table, top = as.integer(input$top_n),
        comparison = input$change_comparison,
        show_stable = input$show_stable,
        change_label = input$change_label,
        palette = movement_palette
      )
    )
  }, ignoreInit = FALSE)

  analysis_code <- eventReactive(input$draw, {
    req(input$category, input$period, input$value)
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
      paste0("  value = `", input$value, "`,"),
      optional_line("rank", input$rank),
      optional_line("label", input$label),
      optional_line("group", input$group),
      paste0("  periods = c(", period_code, "),"),
      paste0("  top_n = ", as.integer(input$top_n), ","),
      paste0('  direction = "', input$direction, '",'),
      paste0('  ties = "', input$ties, '"')
    )
    table_mapping <- append(mapping, '  show_transitions = "all",',
                            after = length(mapping) - 1L)
    paste(c(
      "library(ggrank)", "", data_line, "",
      "changes <- ggrank_table(", "  data = data,", table_mapping, ")", "",
      "rank_plot <- ggrank(", "  data = data,", mapping, ")", "",
      "change_plot <- ggrank_change(", "  data = changes,",
      paste0("  top = ", as.integer(input$top_n), ","),
      paste0('  comparison = "', input$change_comparison, '",'),
      paste0("  show_stable = ", if (isTRUE(input$show_stable)) "TRUE" else "FALSE", ","),
      paste0('  change_label = "', input$change_label, '"'), ")", "",
      "rank_plot", "change_plot", "changes"
    ), collapse = "\n")
  }, ignoreInit = FALSE)

  output$rank_plot <- renderPlot(outputs()$rank_plot, res = 110)
  output$change_plot <- renderPlot(outputs()$change_plot, res = 110)
  output$change_table <- renderTable(outputs()$table, striped = TRUE,
                                     bordered = TRUE, spacing = "s")
  output$ranked_data <- renderTable(outputs()$ranked, striped = TRUE,
                                    bordered = TRUE, spacing = "s")
  output$analysis_code <- renderText(analysis_code())
  output$download_plot <- downloadHandler(
    filename = function() paste0("ggrank-", input$view, ".png"),
    content = function(file) {
      plot <- if (identical(input$view, "Change chart")) {
        outputs()$change_plot
      } else {
        outputs()$rank_plot
      }
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
