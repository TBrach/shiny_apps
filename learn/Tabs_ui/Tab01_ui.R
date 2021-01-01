Tab01 <- sidebarLayout(
        sidebarPanel(
                #tabsetPanel(
                #tabPanel("Plan",
                wellPanel(
                        textInput(inputId = "no", label = "No of event to pick or remove", placeholder = "No", width = "200px"),
                        actionButton(inputId = "pick", label = "Pick item"),
                        actionButton(inputId = "removeItem", label = "Remove item")
                ),
                textOutput(outputId = 'infoTextExtra'),
                wellPanel(
                        textInput(inputId = "category", label = "Categories (comma separated)"),
                        dateInput(inputId = "date", label = "Date"),
                        textOutput(outputId = 'dateStatus2'),
                        #textInput(inputId = "time", label = "Start Time", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                        timeInput(inputId = "time", label = "Start time", value = now(tzone = "CET"), seconds = FALSE), # NB: you can't use minute.steps, fucks up the timezone
                        textOutput(outputId = 'timeStatus2'),
                        textInput(inputId = "itemName", label = "Item name"),
                        textInput(inputId = "description", label = "description", placeholder = ""),
                        textInput(inputId = "comment", label = "Comment"),
                        textInput(inputId = "files", label = "Files (comma separated)"),
                        actionButton(inputId = "addItem", label = "Add/Update")
                ),
                # tags$br(),
                wellPanel(
                        textInput(inputId = "calendarName", label = "Learn list name", value = "Learn"),
                        # tags$br(),
                        actionButton(inputId = "getDropbox", label = "Get from Dropbox"),
                        actionButton(inputId = "saveDropbox", label = "Save in Dropbox")
                ),
                textOutput(outputId = 'infoTextExtra1'),
                #tags$br(),
                wellPanel(
                        checkboxInput(inputId = "search", label = "Item names containing.."),
                        textInput(inputId = "wordsearch", label = "search entry", placeholder = "search entry"),
                        checkboxInput(inputId = "search_cat", label = "Items with these categories.."),
                        textInput(inputId = "wordsearch_cat", label = "search categories", placeholder = "category entry")
                        
                ),
                tags$br(),
                textOutput(outputId = 'infoTextExtra2'),
                #tags$br(),
                #tags$br(),
                wellPanel(
                        # textInput(inputId = "maxview", label = "maximum events shown", value = "10", placeholder = "How many events will be shown (max)"),
                        radioButtons(inputId = "view", label = "Items shown in table", choices = c("plot date past", "end", "plot date"), selected = "end"),
                        textInput(inputId = "event_number", label = "max number of items shown", value = "5")
                )
                #),
                
                #tabPanel("Score",
                #wellPanel(
                
                #)
                #)
                #)
                
        ),
        mainPanel(
            tags$h4("Why this app? 20200216: To generate a Dropbox archieve/library of files showing how things work."),
                dateInput(inputId = "plotDate", label = paste("Table date. Today: ", wday(now(tzone = "CET"), label = T), " ", format(now(tzone = "CET"), "%Y-%m-%d"), sep = "")),
                textOutput(outputId = 'plotDateStatus'),
                #downloadButton(outputId = "savePlot", label = "Save score plot as pdf"),
                tags$br(),
                textOutput(outputId = 'dateStatus'),
                textOutput(outputId = 'timeStatus'),
                textOutput(outputId = 'infoText'),
                tags$br(),
                tableOutput(outputId = "learnTable"),
                #uiOutput(outputId = "calendar"),
                tableOutput(outputId = "categories")
        )
)
