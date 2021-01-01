TitleP <- titlePanel("Plan and save your next itinerary")
WellP <- wellPanel(
    textInput(inputId = "itname", label = "Name of itinerary", value = "Itinerary"),
    tags$h6("Name will be used as file name for saved csv, pdf, rds files.")
)

Tab01 <- sidebarLayout(
    sidebarPanel(
        tabsetPanel(
            tabPanel("Add/remove events",
                     tags$br(),
                     textInput(inputId = "name", label = "Event Name", value = "Eventname", placeholder = "give your event a name"),
                     selectInput(inputId = "category", label = "Event Category", choices = list("Transport", "Hotel", "Activity", "Food")),
                     dateInput(inputId = "date", label = "Start Date", format = "yyyy-mm-dd"),
                     textOutput(outputId = 'startDateStatus'),
                     timeInput(inputId = "time", label = "Start Time", value = now(tzone = "CET"), seconds = FALSE),
                     # textInput(inputId = "time", label = "Start Time", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                     textOutput(outputId = 'startTimeStatus'),
                     textInput(inputId = "duration", label = "Duration (in minutes!)", placeholder = "duration in minutes"),
                     # checkboxInput(inputId = "wholeDay", label = "Whole Day (Start Time = 00:00; Duration = 1440)"),
                     dateInput(inputId = "endDate", label = "End Date (only considered if no duration is given)"),
                     textOutput(outputId = 'endDateStatus'),
                     # textInput(inputId = "endTime", label = "End Time (only considered if no duration is given)", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                     timeInput(inputId = "endTime", label = "End Time (only considered if no duration is given)", value = now(tzone = "CET"), seconds = FALSE), # NB: you can't use minute.steps, fucks up the timezone
                     textOutput(outputId = 'endTimeStatus'),
                     textInput(inputId = "link", label = "Link", placeholder = "Copy link here"),
                     textInput(inputId = "comment", label = "Comment", placeholder = "write a short note"),
                     textInput(inputId = "cost", label = "Cost", placeholder = "cost estimate"),
                     tags$label("Rate the event"),
                     wellPanel(
                         tags$h5("To rate the event: tick the box below, then use the slider to give 1 to 5 stars."),
                         checkboxInput(inputId = "ratedecide", label = "I want to rate the event", value = FALSE),
                         # tags$h6("1 = bad, 5 = excellent"),
                         sliderInput(inputId = "rate", label = NULL, min = 1, max = 5,
                                     value = 3, width = "80%")),
                     actionButton(inputId = "AddUpdate", label = "Add or Update Event"),
                     #tags$br(),
                     # actionButton(inputId = "remove", label = "Remove Event"),
                     HTML('<hr style="color: black;">'),
                     wellPanel(
                         actionButton(inputId = "pick", label = "Pick Event"),
                         actionButton(inputId = "pickRemove", label = "Remove Event"),
                         textInput(inputId = "no", label = "", placeholder = "No", width = "80px")
                     )),
            tabPanel("Load",
                     h4("Upload an itinerary: NB: will override current itinerary!"),
                     h5("Upload itinerary from drop box"),
                     actionButton(inputId = "GetDrop", label = "Get itinerary from Dropbox"),
                     h5("Upload itinerary from csv"),
                     fileInput(inputId = "load", label = NULL, accept = c(
                         "text/csv",
                         "text/comma-separated-values,text/plain",
                         ".csv")))
        ), 
        width = 4
    ),
    # helpText("Uploading an itinerary kills your current itinerary")),
    mainPanel(wellPanel(
        tags$h4("Why this app? 20200216: To plan and remember your trips."),
        tags$h5("Info text"),
        textOutput(outputId = "infoText"),
        # textOutput(outputId = "DateStatus"),
        # textOutput(outputId = "TimeStatus"),
        HTML('<hr style="color: black;">'),
        tags$h5("Save itinerary"),
        actionButton(inputId = "Drop", label = "Save in DP"),
        downloadButton(outputId = "save", label = "Save as csv"),
        HTML('<hr style="color: black;">'),
        tags$h5("Plot itinerary"),
        actionButton(inputId = "plot", label = "Plot itinerary"),
        downloadButton(outputId = "savePlot", label = "Save Plot as pdf"),
        HTML('<hr style="color: black;">'),
        textOutput(outputId = "TotalCost")
    ),
    textOutput(outputId = "DFiStatus"),
    # dataTableOutput(outputId = "itTable"),
    tableOutput(outputId = "itTable"),
    plotOutput(outputId = "itPlot", height = "600px")
    )
)