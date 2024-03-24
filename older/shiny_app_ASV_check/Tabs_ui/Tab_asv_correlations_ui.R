Tab_asv_correlations <- sidebarLayout(
  sidebarPanel(
    
    wellPanel(
      h5("Calculate ASV correlation groups"),
      selectInput(inputId = "cor_method", label = "Correlation method", choices = c("pearson", "spearman"), selected = "pearson"),
      numericInput(
        inputId = "min_n_samples",
        label = "Min n_samples in which both ASVs are present",
        value = 5,
        min = NA,
        max = NA,
        step = 1,
        width = NULL
      ),
      numericInput(
        inputId = "min_cor_coef",
        label = "Min correlation coefficient",
        value = 0.95,
        min = NA,
        max = NA,
        step = 0.01,
        width = NULL
      ),
      
      actionButton(inputId = "calc_correlation_groups", label = "Calculate ASV correlation groups")
    ),
    
    wellPanel(
      textInput(inputId = "correlation_group_name", label = "Group name", value = ""),
      actionButton(inputId = "show_correlation_group", label = "Show named group"),
      actionButton(inputId = "next_correlation_group", label = "Show next group"),
      actionButton(inputId = "previous_correlation_group", label = "Show previous group")
    ),
    
    # wellPanel(
    #   textInput(inputId = "search_group_term", label = "Search group term", value = ""),
    #   actionButton(inputId = "search_groups", label = "Search groups"),
    #   h5("Names of found asv groups:"),
    #   textOutput(outputId = 'found_asv_group_names')
    # ),
    
    wellPanel(
      h5("Names of correlation groups:"),
      textOutput(outputId = 'asv_correlation_group_names')
    )
    
  ),
  mainPanel(
    wellPanel(
      h4("Info text"),
      textOutput(outputId = 'infoText_asv_correlation_groups')
    ),
    
    # downloadButton(outputId = "savePlot", label = "Save plot as pdf"),
    
    uiOutput(outputId = "correlation_group_plot"),
    tableOutput(outputId = "correlation_group_table"),
    tableOutput(outputId = "correlation_taxa_option_table")
    #plotOutput(outputId = "calendar", height = "1000px"),
    #uiOutput(outputId = "scorePlot")
  )
)
