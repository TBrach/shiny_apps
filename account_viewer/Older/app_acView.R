library(shiny)
library(lubridate)
library(tidyr)
library(dplyr)
# library(rdrop2)
library(viridis)
library(ggplot2)
library(plotly)







# ---------------To save Data to your dropbox account this had to be done once ----------------
# # important: authentication to rdrop2 to submit data from shiny to dropbox
# install.packages("rdrop2")
# library(rdrop2)
# # has to be done once by hand
# drop_auth()
# # after you autnthicated in the browser this created a .httr-oauth file in your working directory
# # move the .httr-oauth file into your app folder via iTerm
# # In consequence putting things to dropbox only works when .httr-oauth is in your app folder
# ----------------------------------------------------------



#path <- "/Users/jvb740/Coursera_MOOC/20161202_LearningShiny_FantasySports/shinyy/Apps/170506_Calendar"
#file <- "calendarFunctions.R"
source("accountViewerFunctions.R")



ui <- fluidPage(
        
        tags$style(HTML("
                                .shiny-text-output {
                        color: rgb(102,0,51);
                        }
                        ")),
        tags$style(HTML("
                                .shiny-output-error-validation {
                        color: red;
                        }
                        ")),
        #tags$head(tags$script(HTML(JScode))), # linked to the JScode, the categorial slider input
        
        sidebarLayout(
                sidebarPanel(
                        wellPanel(h4("Upload csv file with account data"),
                                  fileInput(inputId = "load", label = NULL, accept = c(
                                          "text/csv",
                                          "text/comma-separated-values,text/plain",
                                          ".csv")),
                                  
                                  tags$h4("You can also remove uploaded accounts again"),
                                  
                                  
                                  actionButton(inputId = "remove", label = "Remove account of given index"),
                                  
                                  textInput(inputId = "index", label = "Please type the index of the account you want to remove", value = "")
                                  
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
                                tags$h4("Change the currency in some of your accounts"),
                                
                                selectInput(inputId = 'fromCurrency', label = 'From', choices = c("DKK", "EUR")),
                                
                                selectInput(inputId = 'toCurrency', label = 'To', choices = c("DKK", "EUR")),
                                
                                numericInput(inputId = "changeRate", label = "Change Rate: type how much one money item in From is in To", value = 7.47),
                                
                                actionButton(inputId = "changeCurrency", label = "Change accounts with From currency to To currency")
                                
                        )
                        
                        
                ),
                mainPanel(
                        wellPanel(h5("This app allows you to visualize your bank account data, and to add up several accounts into a Total account. To use the app, you have to download your account transaction data in a csv file. Almost all online banking applications offer this option.
Open the file in excel (or similar spread sheet programme) and make sure it has the following 5 columns (order irrelevant): Date (in day-month-year format), Saldo, Amount, Text, and Currency. The Text column should contain info about the transactions. Saldo and Amount should be numeric with comma used as 0 delimiter. Save the file again as csv. Upload such csv files here (so for each account one csv file). You can then generate here a plot of your bank account data over time, and
also generate a table and inspect the data. In the plot you can hover over the different entries to get the Saldo and Text information.
                                     You can restrict the dates for the plot and the table.
                                     You can search entries within the table and restrict to certain accounts.
                                     If you want to restrict the accounts in the plot you currently have to remove the account, sorry.
                                     I also added a currency converter that changes the amounts of each account with the From Currency to the To currency, the user has to give the From to exchange rate.")),
                        # textOutput(outputId = 'infoText2'),
                        # tags$br(),
                        tableOutput(outputId = "overviewTable"),
                        tags$br(),
                        #plotlyOutput(outputId = "accountPlot", height = "1000px"), # , height = "1000px"
                        uiOutput("plotUI"),
                        tags$br(),
                        tableOutput(outputId = "accountTable")
                        
                )
        )
)









server <- function(input, output, session){
        
        
        # - generate reactive Values -
        rv <- reactiveValues(account_list = NULL, overviewTable = NULL, accountTable = NULL, infoText = NULL, Tra = NULL, plotHeight = 0)
        # --
        
        
        
        ##  - parts for the Overview Table - ##
        {
                # - make overviewTable -
                observe({
                        account_list <- rv$account_list
                        
                        if (is.null(account_list)){
                                rv$overviewTable <- NULL
                        } else {
                                
                                if (length(account_list) > 1){
                                        total_account <- generate_Total_account(account_list)
                                        
                                        # -- add it to account_list --
                                        index <- length(account_list) + 1
                                        account_list[[index]] <- total_account
                                        names(account_list)[index] <- "Total" 
                                        # ----
                                }
                                
                                Indexes <- 1:length(account_list)
                                Names <- names(account_list)
                                minDates <- unlist(lapply(1:length(account_list), function(i){as.character(min(account_list[[i]]$Date))}))
                                maxDates <- unlist(lapply(1:length(account_list), function(i){as.character(max(account_list[[i]]$Date))}))
                                Entries <- unlist(lapply(account_list, "nrow"))
                                minAmount <- unlist(lapply(1:length(account_list), function(i){min(account_list[[i]]$Saldo)}))
                                maxAmount <- unlist(lapply(1:length(account_list), function(i){max(account_list[[i]]$Saldo)}))
                                lastAmount <- unlist(lapply(1:length(account_list), function(i){
                                        if (account_list[[i]]$Date[1] > account_list[[i]]$Date[nrow(account_list[[i]])]){
                                                account_list[[i]]$Saldo[1]
                                                
                                        } else {
                                                account_list[[i]]$Saldo[nrow(account_list[[i]])]
                                        }
                                }))
                                Currencies <- unlist(lapply(1:length(account_list), function(i){paste(unique(account_list[[i]]$Currency), collapse = "_")}))
                                DF <- data.frame(Index = Indexes, Name = Names, minDate = minDates, maxDate = maxDates, NoEntries = Entries,
                                                 minAmount = minAmount, maxAmount = maxAmount, lastAmount = lastAmount, Currency = Currencies)
                                rv$overviewTable <- DF
                        }
                        
                })
                # --
                
                
                # -- render the overviewViews table --
                output$overviewTable <- renderTable({
                        rv$overviewTable
                }, sanitize.text.function = function(x) x, caption = "Overview of loaded accounts", caption.placement = getOption("xtable.caption.placement", "top"))
                # ----
        }
        ###############################
        
        
        ## - parts for the Date checks - ##
        # - Separate all dates and times into reactive expressions
        # and run validation tests on these inputs to check user input -
        {
        startDate <- reactive({
                validate(need(!is.na(lubridate::parse_date_time(input$startDate, orders = "ymd", tz = "CET")), "Please add the date in year-month-day format!"))
                lubridate::parse_date_time(input$startDate, orders = "ymd", tz = "CET")
        })
        
        endDate <- reactive({
                validate(need(!is.na(lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")), "Please add the end date in year-month-day format!"))
                lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")
        })
        # --
        
        
        # - inform the user when validation tests on input$date or input$time failed -
        output$startDateStatus <- renderText({
                if(is.character(startDate())) {
                        startDate()
                } else {
                        NULL
                }
        })
        
        output$endDateStatus <- renderText({
                if(is.character(endDate())) {
                        endDate()
                } else {
                        NULL
                }
        })
        
        # --
        }
        #######################################
        
        
        # - Allow to load a csv saved itinerary -
        # NB: this option is probably not yet fail-proof
        observeEvent(input$load, {
                
                rv$Tra <- NULL
                
                inFile <- input$load
                
                
                df_in <- upload_creation(inFile)
                
                if (class(df_in) != "data.frame"){
                        rv$infoText <- df_in
                        return()
                }
                
                # -- you check Amount values in comparison to Saldos --
                if (!all.equal(df_in$Amount[2:nrow(df_in)], diff(df_in$Saldo))) {
                        warning("!!!!!!!your Amounts did not fit to your Saldo's, this was corrected here but you should check it in your csv!!!! ")
                        df_in$Amount[2:nrow(df_in)] <- diff(df_in$Saldo)
                }
                # ----
                
                # - for this multiple account version add the account name -
                account_name <- inFile$name
                account_name <- strsplit(x = account_name, split = ".csv")[[1]][1]
                if (account_name == "Total") { # to prevent a clash with the Total account being the total of all accounts!
                        account_name <- "Total_uploaded"
                }
                df_in$Account <- account_name
                # --
                
                # - add the loaded account to account_list -
                account_list <- rv$account_list
                if (is.null(account_list)){
                        account_list <- list()
                        account_list[[1]] <- df_in
                        names(account_list)[1] <- account_name
                } else {
                        if (account_name %in% names(account_list)){
                                index <- which(account_name == names(account_list))
                                account_list[[index]] <- df_in
                        } else {
                                index <- length(account_list) + 1
                                account_list[[index]] <- df_in
                                names(account_list)[index] <- account_name
                        }
                }
                # --
                
                
                # -- set the date inputs based on the min and max values in the account_list --
                minDate <- lapply(1:length(account_list), function(i){min(account_list[[i]]$Date)})
                minDate <- do.call("min", minDate)
                maxDate <- lapply(1:length(account_list), function(i){max(account_list[[i]]$Date)})
                maxDate <- do.call("max", maxDate)
                
                updateDateInput(session, inputId = "startDate", value = as.character(minDate))
                updateDateInput(session, inputId = "endDate", value = as.character(maxDate))
                # ----
                
                rv$account_list <- account_list
                rv$infoText <- paste("Uploaded suitable account csv with ", nrow(df_in), " entries covering ", df_in$Date[1], " to ", df_in$Date[nrow(df_in)], sep = "")
    
        })
        # --


        
        # - output infoText -
        {
                output$infoText <- renderText({
                        rv$infoText
                })
                
                # output$infoText2 <- renderText({
                #         rv$infoText
                # })
        }
        # --
        
       
       
        # - option to remove an account from account_list -
        # NB: this option is probably not yet fail-proof
        observeEvent(input$remove, {
                
                if (is.null(rv$account_list)){
                        rv$infoText <- "There are no accounts in your account_list yet to remove"
                        return()
                }
                
                account_list <- rv$account_list
                
                Index <- input$index
                Index <- as.numeric(Index)
                
                if (! Index %in% 1:length(account_list)){
                        rv$infoText <- "The given index was not an index in your account_list, please correct input."
                        return() 
                }
                
                account_list <- account_list[-Index]
                
                if (length(account_list) == 0){
                        rv$account_list <- NULL
                } else {
                        rv$account_list <- account_list
                }
                
                rv$infoText <- paste("removed the account that had the index:", as.character(Index))
                
        })
        # --
        
        
         
         
        # - generate the plots when plot button is pressed -
        observeEvent(input$plot, { 
                
                if(is.null(rv$account_list)){
                        rv$infoText <- "There is no account data to plot, please upload account data first."
                        rv$Tra <- NULL
                        rv$plotHeight <- 0
                } else {
                        
                        account_list <- rv$account_list
                        
                        # - add Total account if asked for -
                        if (input$includeTotal) {
                                total_account <- generate_Total_account(account_list)
                                
                                # -- add it to account_list --
                                index <- length(account_list) + 1
                                account_list[[index]] <- total_account
                                names(account_list)[index] <- "Total" 
                                # ----
                        }
                        # --
                        

                        # - filter all account dfs based on the given start and end dates and only keep accounts with entries in this time span!! -
                        account_list2 <- lapply(account_list, function(df){dplyr::filter(df, Date >= startDate(), Date <= endDate())})
                        # account_list2 <- lapply(account_list, function(df){dplyr::filter(df, Date >= startDate, Date <= endDate)})
                        
                        remainingEntries <- lapply(account_list2, nrow)
                        account_list2 <- account_list2[remainingEntries > 0]
                        if (length(account_list2) == 0){
                                rv$infoText <- "In none of your accounts there was an entry between the given start and end dates, therefore no plot was generated and start and end date were re-set."
                                rv$Tra <- NULL
                                minDate <- lapply(1:length(account_list), function(i){min(account_list[[i]]$Date)})
                                minDate <- do.call("min", minDate)
                                maxDate <- lapply(1:length(account_list), function(i){max(account_list[[i]]$Date)})
                                maxDate <- do.call("max", maxDate)
                                
                                updateDateInput(session, inputId = "startDate", value = as.character(minDate))
                                updateDateInput(session, inputId = "endDate", value = as.character(maxDate))
                                return()
                        }
                        # --
                        
                        
                        # - spread for each account entries on the same day over minutes -
                        # NB: I'm aware that his causes that the total does not fully fit to the individual accounts on a single day, but that is fine I guess
                        account_list2 <- lapply(account_list2, function(df){
                                rleDates <- rle(as.character(df$Date))[[1]]
                                df$Minute <- unlist(lapply(rleDates, function(i){minute_spreader(i)}))
                                
                                df$ActionTime <- df$Date + lubridate::minutes(df$Minute)
                                df$NextTime <- c(df$ActionTime[2:nrow(df)], df$ActionTime[nrow(df)] + lubridate::minutes(5))
                                df
                                
                        })
                        # --
                        
                        
                        # - define the colors for the accounts and order them - 
                        accounts <- names(account_list2)
                        if ("Total" %in% accounts) {
                                accounts <- c("Total", setdiff(accounts, "Total"))
                                
                                if (length(accounts < 17)){
                                        account_colors <- c(cbPalette[2], QuantColors15[1:(length(accounts)-1)])
                                } else {
                                        account_colors <- c(cbPalette[2], viridis(length(accounts)-1))
                                }
                        } else {
                                if (length(accounts < 16)){
                                        account_colors <- c(QuantColors15[1:length(accounts)])
                                } else {
                                        account_colors <- viridis(length(accounts))
                                }
                        }
                        names(account_colors) <- accounts
                        # -- 
                        
                        # - put DFaPlot together -
                        DFaPlot <- do.call("rbind", account_list2)
                        DFaPlot$Account <- factor(DFaPlot$Account, levels = accounts, ordered = TRUE)
                        # --

                        # - do the plot -
                        Tr <- ggplot(DFaPlot, aes(x = ActionTime, y = Saldo, col = Account,
                                                  text = paste("Date: ", as.Date(ActionTime),
                                                                                     "<br>Amount: ", Amount,
                                                                                     "<br>Text:", Text)))
                        Tr <- Tr +
                                geom_segment(aes(x = ActionTime, xend = NextTime, yend = Saldo), linetype = 3) +
                                geom_segment(aes(x = ActionTime, xend = ActionTime, yend = Saldo - Amount), linetype = 1) +
                                geom_point(size = 1, alpha = 0.85) +
                                scale_color_manual("", values = account_colors) +
                                theme_bw() +
                                xlab("") +
                                ylab(paste0("Saldo [", paste(unique(DFaPlot$Currency), collapse = "_"), "]"))


                        if (input$facet == "faceted"){

                                if (input$freeY){
                                        Tr <- Tr +
                                                facet_wrap(~ Account, ncol = 1, scales = "free_y")
                                } else {
                                        Tr <- Tr +
                                                facet_wrap(~ Account, ncol = 1)
                                }

                                Tr <- Tr +
                                        theme(legend.position = "none")
                                
                                plotHeight <- 400*length(accounts)
                                
                                rv$plotHeight <- plotHeight
                                
                                Tr <- ggplotly(Tr, tooltip = c("Saldo", "text"), height = plotHeight) # , height = plotHeight

                        } else {
                                
                                plotHeight <- 800
                                
                                rv$plotHeight <- plotHeight
                                
                                Tr <- ggplotly(Tr, tooltip = c("Saldo", "text"), height = plotHeight) #, height = plotHeight
                                
                        }
                        # --

                        rv$Tra <- Tr
                        rv$infoText <- "Generated a Plot."
                }
        })
        # --
        
        # # - plot the account -
        # output$accountPlot <- renderPlotly({
        #         if (is.null(rv$Tra)) {
        #                 return()
        #                 rv$infoText = "no plot generated yet"
        #         } else {
        #                 print(rv$Tra)
        #         }
        #                 
        # })
        # # --
        
        # - plot the account -
        output$plotUI <- renderUI({
                plotlyOutput(outputId = "accountPlot", height = paste0(rv$plotHeight,"px"))
        })
        
        output$accountPlot <- renderPlotly({
                if (is.null(rv$Tra)) {
                        return()
                        rv$infoText = "no plot generated yet"
                } else {
                        print(rv$Tra)
                }
        })
        # --
        
        
        
        # - update the selectInput options for the accountTable -
        observe({
                if(!is.null(rv$account_list)){
                        
                        account_list <- rv$account_list
                        accounts <- names(account_list)
                        
                        if(length(accounts) > 1){
                                accounts <- c("Total", accounts)
                        }
                        
                        updateSelectInput(session, inputId = "tableAccount",
                                          choices = accounts)
                }
        })
        # --
        
        
        
        # - prepare the accountTable -
        observeEvent(input$generateAccountTable, {
                
                if(!is.null(rv$account_list)){

                        account_list <- rv$account_list
                        account <- input$tableAccount

                        if (account == "Total") {
                                DFaShow <- generate_Total_account(account_list)
                                
                        } else {
                                DFaShow <- account_list[[account]]
                        }

                        DFaShow <- cbind(No = 1:nrow(DFaShow), DFaShow)
                        DFaShow <- dplyr::filter(DFaShow, Date >= startDate(), Date <= endDate())

                        if(isTRUE(input$search)){
                                DFaShow <- DFaShow[grep(pattern = input$wordsearch, DFaShow$Text, ignore.case = TRUE),]

                        }

                        if (dim(DFaShow)[1] != 0) {


                                if (DFaShow$Date[1] < DFaShow$Date[nrow(DFaShow)]) {
                                        DFaShow <- DFaShow[nrow(DFaShow):1,] # here I want the youngest on top of course
                                }

                                # DFaShow <- dplyr::arrange(DFaShow, desc(Date))
                                #DFkShow$Week <- paste0("W_", strftime(DFkShow$startTime, format = "%V", tz = "CET"), sep = "")
                                #DFkShow$Wday <- lubridate::wday(DFkShow$startTime, label = TRUE)
                                DFaShow$Date <- format(DFaShow$Date, format='%d-%m-%Y')
                                rv$accountTable <- head(DFaShow, input$NoEntries)
                        } else {
                                rv$accountTable <- NULL
                        }
                }

        })
        # --
        
        
        
        # - use render Table to display account data -
        output$accountTable <- renderTable({
                rv$accountTable}, sanitize.text.function = function(x) x)
        
        # --
        
        
        
        
        # - update the selectInput options for the currencyConverter -
        observe({
                if(!is.null(rv$account_list)){
                        
                        account_list <- rv$account_list
                        Currencies <- unique(unlist(lapply(1:length(account_list), function(i){account_list[[i]]$Currency[1]})))
                        
                        updateSelectInput(session, inputId = "fromCurrency",
                                          choices = unique(c("DKK", "EUR", Currencies)))
                        
                        updateSelectInput(session, inputId = "toCurrency",
                                          choices = unique(c("DKK", "EUR", Currencies)))
                }
        })
        # --
        
        
        
        # - The currency converter -
        observeEvent(input$changeCurrency, {
                
                if (is.null(rv$account_list)){
                        rv$infoText <- "There are no accounts in your account_list yet to change any currencies"
                        return()
                }
                
                account_list <- rv$account_list
                
                fromCurrency <- input$fromCurrency
                toCurrency <- input$toCurrency
                
                if (fromCurrency == "" || toCurrency == ""){
                        rv$infoText <- "Either fromCurrency or toCurrency is empty"
                        return() 
                }
                
                if (fromCurrency == toCurrency){
                        rv$infoText <- "fromCurrency equals toCurrency. Conversion makes no sense. Change input."
                        return()
                        
                }
                
                changeRate <- as.numeric(input$changeRate)
                
                if (is.na(changeRate) || changeRate <= 0){
                        rv$infoText <- "The given changeRate muste be a numeric value above 0. This was not the case, please change it."
                        return()
                        
                }
                
                account_list <- lapply(account_list, function(df){
                        if (df$Currency[1] == fromCurrency){
                                df$Amount <- df$Amount*changeRate
                                df$Saldo <- df$Saldo*changeRate
                                df$Currency <- toCurrency
                        } 
                        df
                })
                
                rv$account_list <- account_list
                
                rv$infoText <- paste("Changed all accounts that had currency: ", fromCurrency, " to currency: ", toCurrency, " using the given exchange rate of: ", changeRate, sep = "")
                
        })
        # --
        
        
        
        
}

shinyApp(ui = ui, server = server)