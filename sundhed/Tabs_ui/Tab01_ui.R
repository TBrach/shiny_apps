Tab01 <- sidebarLayout(
        sidebarPanel(
                #tabsetPanel(
                #tabPanel("Plan",
                textOutput(outputId = 'infoTextExtra1'),
                wellPanel(
                        selectInput(inputId = "item", label = "Item Type", choices = itemLevels, selected = itemLevels[1]),
                        selectInput(inputId = "unit", label = "Unit", choices = unique(unitLevels), selected = unique(unitLevels)[1]),
                        numericInput(inputId = "value", label = "Value", value = NA),
                        dateInput(inputId = "date", label = "Date"),
                        textOutput(outputId = 'dateStatus2'),
                        timeInput(inputId = "time", label = "Time", value = now(tzone = "CET"), seconds = FALSE), # NB: you can't use minute.steps, fucks up the timezone
                        textOutput(outputId = 'timeStatus2'),
                        textInput(inputId = "comment", label = "Comment"),
                        actionButton(inputId = "addItem", label = "Add/Update")
                ),
                wellPanel(
                        textInput(inputId = "no", label = "No of item to pick or remove", placeholder = "No", width = "200px"),
                        actionButton(inputId = "pick", label = "Pick Item"),
                        actionButton(inputId = "removeItem", label = "Remove Item")
                ),
                wellPanel(
                        textInput(inputId = "listName", label = "Name of sundhed list", value = "sundhed"),
                        # tags$br(),
                        actionButton(inputId = "getDropbox", label = "Get from Dropbox"),
                        actionButton(inputId = "saveDropbox", label = "Save in Dropbox")
                ),
                textOutput(outputId = 'infoTextExtra2'),
                #tags$br(),
                wellPanel(
                        checkboxInput(inputId = "restrictItem", label = "restict items"),
                        checkboxGroupInput(inputId = "itemNames", label = "restrict shown items", choices = itemLevels, selected = NULL),
                        checkboxInput(inputId = "restrictDate", label = "restict dates"),
                        dateInput(inputId = "startDate", label = "Start Date"),
                        textOutput(outputId = 'startDateStatus2'),
                        dateInput(inputId = "endDate", label = "End Date"),
                        textOutput(outputId = 'endDateStatus2')
                ),
                #tags$br(),
                textOutput(outputId = 'infoTextExtra3'),
                wellPanel(
                        # textInput(inputId = "maxview", label = "maximum events shown", value = "10", placeholder = "How many events will be shown (max)"),
                        radioButtons(inputId = "view", label = "Items shown in table", choices = c("date past", "end", "date"), selected = "end"),
                        textInput(inputId = "item_number", label = "max number of items shown", value = "5")
                )
                #),
                
                #tabPanel("Score",
                #wellPanel(
                
                #)
                #)
                #)
                
        ),
        mainPanel(
                tags$h4("Why this app? 20200216: To keep a timeline documentation of your blood pressure and other health measures."),
                actionButton(inputId = "plot", label = "Plot Items"),
                downloadButton(outputId = "savePlot", label = "Save plot as pdf"),
                tags$br(),
                textOutput(outputId = 'dateStatus'),
                textOutput(outputId = 'timeStatus'),
                textOutput(outputId = 'startDateStatus'),
                textOutput(outputId = 'endDateStatus'),
                textOutput(outputId = 'infoText'),
                tags$br(),
                tableOutput(outputId = "itemTable"),
                uiOutput(outputId = "itemPlot")
        )
)
