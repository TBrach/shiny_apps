Tab_asv_indiv <- sidebarLayout(
  sidebarPanel(
    wellPanel(
      h5("Load dada2 output: Choose input folder with dada2 data"),
      shinyDirButton(id = 'input_folder_asv_indiv', 'Select a folder', 'Please select a folder', FALSE)
    ),
    
    wellPanel(
      h5("Calculate ASV data (be patient, can take 2 minutes)"),

      actionButton(inputId = "calc_asvs_data", label = "Calculate ASV data")
    ),
    
    wellPanel(
      textInput(inputId = "ASV_name", label = "ASV name", value = ""),
      actionButton(inputId = "show_asv", label = "Show named ASV"),
      actionButton(inputId = "next_asv", label = "show next ASV"),
      actionButton(inputId = "previous_asv", label = "show previous ASV")
    )
    
    # wellPanel(
    #   textInput(inputId = "search_group_term", label = "search group term", value = ""),
    #   actionButton(inputId = "search_groups", label = "search groups"),
    #   h5("Names of found asv groups:"),
    #   textOutput(outputId = 'found_asv_group_names')
    # )
    
    
  ),
  mainPanel(
    wellPanel(
      h4("Info text"),
      textOutput(outputId = 'infoText_asv_indiv')
    ),
    
    # downloadButton(outputId = "savePlot", label = "Save plot as pdf"),
    
    # wellPanel(
    #   h5("Names of asv groups:"),
    #   textOutput(outputId = 'asv_group_names')
    # ),
    textOutput(outputId = 'asv_sequence'),
    uiOutput(outputId = "asv_plot"),
    tableOutput(outputId = "asv_table"),
    tableOutput(outputId = "asv_option_table")
    #plotOutput(outputId = "calendar", height = "1000px"),
    #uiOutput(outputId = "scorePlot")
  )
)
