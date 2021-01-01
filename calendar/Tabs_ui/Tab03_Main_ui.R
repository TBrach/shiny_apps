Tab03 <- mainPanel(
        tags$h4("Why this app? 20200216: To plan and remember events."),
        dateInput(inputId = "plotDate", label = paste("Center Date of plots. Today: ", wday(now(tzone = "CET"), label = T), " ", format(now(tzone = "CET"), "%Y-%m-%d"), sep = "")),
        textOutput(outputId = 'plotDateStatus2'),
        actionButton(inputId = "plot", label = "Plot"),
        downloadButton(outputId = "savePlot", label = "Save week plot as pdf"),
        tags$br(),
        textOutput(outputId = 'dateStatus'),
        textOutput(outputId = 'endDateStatus'),
        textOutput(outputId = 'timeStatus'),
        textOutput(outputId = 'endTimeStatus'),
        textOutput(outputId = 'plotDateStatus'),
        textOutput(outputId = 'infoText'),
        tags$br(),
        tableOutput(outputId = "calendarTable"),
        plotOutput(outputId = "calendar", height = "1250px")
        
)