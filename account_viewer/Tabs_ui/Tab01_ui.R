Tab01 <- sidebarLayout(
    sidebarPanel(
        wellPanel(#h4("Upload csv file with account data"),
                  # fileInput(inputId = "load", label = NULL, accept = c(
                  #     "text/csv",
                  #     "text/comma-separated-values,text/plain",
                  #     ".csv")),
                  
                  h4("Add to account in your account list"),
                  fileInput(inputId = "addCSV", label = NULL, accept = c(
                      "text/csv",
                      "text/comma-separated-values,text/plain",
                      ".csv")),
                  
                  h4("Save account list to dropbox"),
                  actionButton(inputId = "saveDropbox", label = "Save account_list in Dropbox")
                  
                  #tags$h4("Remove accounts (almost deprecated, dont save!)"),
                  #actionButton(inputId = "remove", label = "Remove account of given index"),
                  #textInput(inputId = "index", label = "Please type the index of the account you want to remove", value = "")
        ),
        
        wellPanel(
            tags$h4("Info Box"),
            
            textOutput(outputId = 'infoText')
            
        ),
        
        wellPanel(
            tags$h4("Generate a plot of your accounts"),
            actionButton(inputId = "plot", label = "Generate or update plot"),
            tags$h5("Plot options:"),
            radioButtons(inputId = "facet", label = "Faceted or single plot",
                         choices = c("single",
                                     "faceted"),
                         width = "100%"),
            checkboxInput(inputId = "includeTotal", label = "include Total account", value = TRUE),
            checkboxInput(inputId = "restrictItem", label = "restict items"),
            checkboxGroupInput(inputId = "itemNames", label = "restrict shown accounts", choices = c("IngDiba_Giro", "IngDiba_Extra", "IngDiba_Depot", "BasisBank_Loen", "Handelsbanken_Faelles"), selected = NULL),
            checkboxInput(inputId = "freeY", label = "free Y axis scale in faceted plot", value = TRUE)
            
        ),
        
        
        wellPanel(
            tags$h4("Generate a table of your accounts"),
            
            actionButton(inputId = "generateAccountTable", label = "Generate or update table"),
            
            selectInput(inputId = 'tableAccount', label = 'Account', choices = ""),
            
            numericInput(inputId = "NoEntries", label = "Max number of entries in table", value = 50),
            wellPanel(
                checkboxInput(inputId = "search", label = "Entries containing.."),
                textInput(inputId = "wordsearch", label = "search entry", placeholder = "search entry")
                
            )),
        
        wellPanel(
            tags$h4("You can restrict the date range shown in the plot and the table:"),
            dateInput(inputId = "startDate", label = "start date"),
            textOutput(outputId = 'startDateStatus'),
            dateInput(inputId = "endDate", label = "end date"),
            textOutput(outputId = 'endDateStatus')),
        
        wellPanel(
            h4("householdbook plots based on pattern to category files"),
            h4("Load pattern to category file"),
            fileInput(inputId = "addHaushalt", label = NULL, accept = c(
                "text/csv",
                "text/comma-separated-values,text/plain",
                ".csv")),
            checkboxInput(inputId = "individualItems", label = "show individual items", value = FALSE),
            actionButton(inputId = "plotHB", label = "generate householdbook plots")
        ),
        
        wellPanel(
            tags$h4("Change the currency in some of your accounts"),
            
            selectInput(inputId = 'fromCurrency', label = 'From', choices = c("DKK", "EUR")),
            
            selectInput(inputId = 'toCurrency', label = 'To', choices = c("DKK", "EUR")),
            
            numericInput(inputId = "changeRate", label = "Change Rate: type how much one money item in From is in To", value = 7.47),
            
            actionButton(inputId = "changeCurrency", label = "Change accounts with From currency to To currency")
            
        )
        
        
    ),
    mainPanel(
        tags$h4("Why this app? 20200216: To easily keep track of your bank accounts and what you use your money for = Haushaltsbuch."),
        wellPanel(h5("This app allows you to visualize your bank account data, and to add up several accounts into a Total account. 
                     20200101: I changed the app. From now on your account_list is saved in Dropbox, and you can directly add the csvs you download from the bank
                     websites. See Tab03a to see how it works for the different accounts!")),
        # textOutput(outputId = 'infoText2'),
        # tags$br(),
        tableOutput(outputId = "overviewTable"),
        tags$br(),
        #plotlyOutput(outputId = "accountPlot", height = "1000px"), # , height = "1000px"
        uiOutput("plotUI"),
        tags$br(),
        uiOutput("plotUI_HB"),
        tags$br(),
        uiOutput("plotUI_HB2"),
        tags$br(),
        tableOutput(outputId = "accountTable")
        
    )
)
