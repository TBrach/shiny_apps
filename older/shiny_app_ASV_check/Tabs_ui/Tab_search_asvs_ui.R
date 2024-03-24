Tab_search_asvs <- sidebarLayout(
  sidebarPanel(
    
    wellPanel(
      textInput(inputId = "search_asv_term", label = "Search term (Sequence, taxonomic term)", value = ""),
      actionButton(inputId = "search_asvs", label = "Search ASVs")
    )
    
  ),
  mainPanel(
    wellPanel(
      h4("Info text"),
      textOutput(outputId = 'infoText_search_asvs')
    ),
    
    tableOutput(outputId = "found_asvs_table")
    #plotOutput(outputId = "calendar", height = "1000px"),
    #uiOutput(outputId = "scorePlot")
  )
)
