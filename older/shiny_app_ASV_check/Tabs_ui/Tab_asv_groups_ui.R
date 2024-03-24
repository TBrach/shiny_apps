Tab_asv_groups <- sidebarLayout(
  sidebarPanel(
    
    wellPanel(
      h5("Calculate ASV groups"),
      selectInput(inputId = "group_type", label = "Group type", choices = c("exclusive", "connected"), selected = "exclusive"),
      numericInput(
        inputId = "max_mismatch",
        label = "Max n_mismatches within group",
        value = 3,
        min = NA,
        max = NA,
        step = 1,
        width = NULL
      ),
      
      actionButton(inputId = "calc_groups", label = "Calculate ASV groups")
    ),
    
    wellPanel(
      textInput(inputId = "group_name", label = "Group name", value = ""),
      actionButton(inputId = "show_group", label = "Show named group"),
      actionButton(inputId = "next_group", label = "Show next group"),
      actionButton(inputId = "previous_group", label = "Show previous group")
    ),
    
    wellPanel(
      textInput(inputId = "search_group_term", label = "Search group term", value = ""),
      actionButton(inputId = "search_groups", label = "Search groups"),
      h5("Names of found asv groups:"),
      textOutput(outputId = 'found_asv_group_names')
    ),
    
    wellPanel(
      h5("Names of asv groups:"),
      textOutput(outputId = 'asv_group_names')
    )
    
  ),
  mainPanel(
    wellPanel(
      h4("Info text"),
      textOutput(outputId = 'infoText_asv_groups')
    ),
    
    # downloadButton(outputId = "savePlot", label = "Save plot as pdf"),
    
    uiOutput(outputId = "group_plot"),
    tableOutput(outputId = "group_table"),
    tableOutput(outputId = "taxa_option_table")
    #plotOutput(outputId = "calendar", height = "1000px"),
    #uiOutput(outputId = "scorePlot")
  )
)
