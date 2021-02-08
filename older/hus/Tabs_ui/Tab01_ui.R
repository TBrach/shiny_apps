Tab01 <- sidebarLayout(
        sidebarPanel(
                wellPanel(
                    selectInput(inputId = "person", label = "Person", choices = c("Iben", "Thorsten", "Konti", "Kirsten/Leif"), selected = "Iben"),
                        textInput(inputId = "url", label = "Input boliga url", placeholder = "URL"),
                        actionButton(inputId = "addEntry", label = "Add hus from boliga")
                ),
                textOutput(outputId = 'infoTextExtra1'),
                wellPanel(
                        textInput(inputId = "no", label = "No of entry to remove", placeholder = "No", width = "200px"),
                        actionButton(inputId = "rmEntry", label = "Remove entry")
                ),
                wellPanel(
                    textInput(inputId = "no2", label = "No of entry to add/change comment", placeholder = "No", width = "200px"),
                    textInput(inputId = "comment", label = "Comment"),
                    actionButton(inputId = "addComment", label = "Add/Update comment")
                ),
                # tags$br(),
                wellPanel(
                        actionButton(inputId = "saveDropbox", label = "Save in Dropbox")
                ),
                textOutput(outputId = 'infoTextExtra2'),
                wellPanel(
                    selectInput(inputId = "personNB", label = "Person", choices = c("Iben", "Thorsten", "Konti", "Kirsten/Leif"), selected = "Iben"),
                    textInput(inputId = "urlNB", label = "Input url", placeholder = "URL"),
                    textInput(inputId = "titleNB", label = "Title: address - bolig type", placeholder = "address - bolig type"),
                    actionButton(inputId = "addEntryNB", label = "Add hus from non-boliga site")
                )
                
                
        ),
        mainPanel(
                tags$h4("Why this app? 20200926: To keep track of housing hunt."),
                textOutput(outputId = 'infoText'),
                tags$br(),
                tableOutput(outputId = "husTable")
        )
)
