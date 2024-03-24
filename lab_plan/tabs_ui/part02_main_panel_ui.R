part_02 <- mainPanel(
        textOutput(outputId = 'infoText'),
        tags$br(),
        tableOutput(outputId = "labplan_table")
        # plotOutput(outputId = "calendar", height = "1250px")
        
)