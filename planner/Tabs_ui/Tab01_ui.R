Tab01 <- sidebarLayout(
        sidebarPanel(
                #tabsetPanel(
                #tabPanel("Plan",
                wellPanel(
                        textInput(inputId = "no", label = "No of event to pick or remove", placeholder = "No", width = "200px"),
                        actionButton(inputId = "pick", label = "Pick Event"),
                        actionButton(inputId = "removeEvent", label = "Remove Event")
                ),
                textOutput(outputId = 'infoTextExtra3'),
                wellPanel(
                        textInput(inputId = "eventName", label = "Event Name", value = ""),
                        selectInput(inputId = "color", label = "Category", choices = c("Work", "Sport_Motion", "Social", "Meditation", "Learn_Create", "Braintable", "diary"), selected = "Work"),
                        dateInput(inputId = "date", label = "Date"),
                        textOutput(outputId = 'dateStatus2'),
                        #textInput(inputId = "time", label = "Start Time", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                        timeInput(inputId = "time", label = "Start Time", value = now(tzone = "CET"), seconds = FALSE), # NB: you can't use minute.steps, fucks up the timezone
                        textOutput(outputId = 'timeStatus2'),
                        textInput(inputId = "duration", label = "Duration (in minutes!)", placeholder = "duration in minutes"),
                        # checkboxInput(inputId = "wholeDay", label = "Whole Day (Start Time = 00:00; Duration = 1440)"),
                        dateInput(inputId = "endDate", label = "End Date (only considered if no duration is given)"),
                        textOutput(outputId = 'endDateStatus2'),
                        timeInput(inputId = "endTime", label = "End Time (only considered if no duration is given)", value = now(tzone = "CET"), seconds = FALSE), # NB: you can't use minute.steps, fucks up the timezone
                        textOutput(outputId = 'endTimeStatus2'),
                        # selectInput(inputId = "urgency", label = "urgency level", choices = c("a", "b", "c")),
                        textInput(inputId = "comment", label = "Comment"),
                        actionButton(inputId = "addEvent", label = "Add/Update")
                ),
                # tags$br(),
                wellPanel(
                        textInput(inputId = "calendarName", label = "Planner name", value = "Planner"),
                        # tags$br(),
                        actionButton(inputId = "getDropbox", label = "Get from Dropbox"),
                        actionButton(inputId = "saveDropbox", label = "Save in Dropbox")
                ),
                textOutput(outputId = 'infoTextExtra4'),
                #tags$br(),
                wellPanel(
                        checkboxInput(inputId = "search", label = "Entries containing.."),
                        textInput(inputId = "wordsearch", label = "search entry", placeholder = "search entry"),
                        checkboxInput(inputId = "filter", label = "Filter table by category"),
                        selectInput(inputId = "catfilt", label = "Category", choices = colorLevels, selected = "Braintable")
                ),
                tags$br(),
                textOutput(outputId = 'infoTextExtra5'),
                #tags$br(),
                #tags$br(),
                wellPanel(
                        # textInput(inputId = "maxview", label = "maximum events shown", value = "10", placeholder = "How many events will be shown (max)"),
                        radioButtons(inputId = "view", label = "Events shown in table", choices = c("plot date past", "end", "plot date"), selected = "plot date past"),
                        textInput(inputId = "event_number", label = "max number of events shown", value = "5")
                )
                #),
                
                #tabPanel("Score",
                #wellPanel(
                
                #)
                #)
                #)
                
        ),
        mainPanel(
                tags$h4("Why this app? 20200216: To structure, remember, and summarize your hverdag."),
                dateInput(inputId = "plotDate", label = paste("Plot date. Today: ", wday(now(tzone = "CET"), label = T), " ", format(now(tzone = "CET"), "%Y-%m-%d"), sep = "")),
                textOutput(outputId = 'plotDateStatus2'),
                actionButton(inputId = "plot", label = "PlotPlan"),
                actionButton(inputId = "plotScore", label = "PlotScore"),
                downloadButton(outputId = "savePlot", label = "Save score plot as pdf"),
                tags$br(),
                textOutput(outputId = 'dateStatus'),
                textOutput(outputId = 'endDateStatus'),
                textOutput(outputId = 'timeStatus'),
                textOutput(outputId = 'endTimeStatus'),
                textOutput(outputId = 'plotDateStatus'),
                textOutput(outputId = 'infoText'),
                tags$br(),
                tableOutput(outputId = "calendarTable"),
                uiOutput(outputId = "calendar"),
                #plotOutput(outputId = "calendar", height = "1000px"),
                uiOutput(outputId = "scorePlot")
        )
)
