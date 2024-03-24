Tab_check_assignment <- sidebarLayout(
  sidebarPanel(
    wellPanel(
      h5("Load reference database"),
      fileInput(inputId = "refDB", label = "choose refDB file", accept = c(".rds")),
    ),
    
    wellPanel(
      h4("Find assignment options for ASV from amplicon refDB"),
      textInput(inputId = "asv_or_seq", label = "ASV name or sequence", value = ""),
      actionButton(inputId = "find_100PC", label = "Find 100% matches"),
      h5("In case there are no 100% matches... do an alignment"),
      selectInput(inputId = "align_to", label = "Align to", choices = c("UHGG + rrnDB", "UHGG", "rrnDB", "entries of tax you enter", "entire refDB"), selected = "UHGG + rrnDB"),
      textInput(inputId = "align_tax", label = "Give tax of entries to align to", value = "Prevotella"),
      actionButton(inputId = "align", label = "Find closest matches"),
      actionButton(inputId = "show_search_seq", label = "Show search_seq")
    )
  ),
  mainPanel(
    wellPanel(
      h4("Info text"),
      textOutput(outputId = 'infoText_check_assignment')
    ),
    tableOutput(outputId = "assignment_options"),
    
    wellPanel(
    textOutput(outputId = "search_seq")
    )
  )
)
