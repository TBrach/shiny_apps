# - upload pattern to category file -
observeEvent(input$addHaushalt, {
        rv$infoText <- NULL
        rv$patternCategory <- NULL
        rv$TrHB <- NULL
        rv$TrHB2 <- NULL
        plotHeightHB = 0
        plotHeightHB2 = 0
        inFile <- input$addHaushalt
        df <- read.csv(file = inFile$datapath, header = TRUE, stringsAsFactors = FALSE, sep = ";")
        df[] <- lapply(df[], str_trim)
        df <- unique(df)
        if (ncol(df) != 2 || !all(colnames(df) == c("category", "pattern"))){
                rv$infoText <- "pattern to category file must have only two columns pattern and category. No file loaded"
                return()
        }
        catetgories_patterns <- arrange(select(filter(as.data.frame(table(unique(df))), Freq != 0), category, pattern), category)
        rv$patternCategory <- df
        rv$infoText <- paste0("loaded new pattern to category file with categories: ", paste(unique(catetgories_patterns$category), collapse = ", "))
})
# --


# - plot household plot 1, simple version -
observeEvent(input$plotHB, { 
        
        rv$TrHB <- NULL
        rv$TrHB2 <- NULL
        rv$infoText <- NULL
        plotHeightHB = 0
        plotHeightHB2 = 0
        
        if(is.null(rv$account_list)){
                rv$infoText <- "There is no account data to plot, please upload account data first."
                return()
        }
        if(is.null(rv$patternCategory)){
                rv$infoText <- "There is not pattern to category file yet, no plot possible."
                return()
        }
        
        account_list <- rv$account_list
        df <- rv$patternCategory
        account_colors <- rv$account_colors
        # - restrict accounts -
        if(isTRUE(input$restrictItem)){
                accountNames <- input$itemNames
                account_list <- account_list[names(account_list) %in% accountNames]
        }
        if (length(account_list) == 0){
                rv$infoText <- "No accounts selected, no plot possible"
                return()
        }
        # --
        # - filter all account dfs based on the given start and end dates and only keep accounts with entries in this time span!! -
        account_list2 <- lapply(account_list, function(df){dplyr::filter(df, Date >= startDate(), Date <= endDate())})
        # account_list2 <- lapply(account_list, function(df){dplyr::filter(df, Date >= startDate, Date <= endDate)})
        remainingEntries <- lapply(account_list2, nrow)
        account_list2 <- account_list2[remainingEntries > 0]
        if (length(account_list2) == 0){
                rv$infoText <- "In none of your selected accounts there was an entry between the given start and end dates, therefore no plot was generated."
                # minDate <- lapply(1:length(account_list), function(i){min(account_list[[i]]$Date)})
                # minDate <- do.call("min", minDate)
                # maxDate <- lapply(1:length(account_list), function(i){max(account_list[[i]]$Date)})
                # maxDate <- do.call("max", maxDate)
                # updateDateInput(session, inputId = "startDate", value = as.character(minDate))
                # updateDateInput(session, inputId = "endDate", value = as.character(maxDate))
                return()
        }
        # --
        # - put all remaining account entries in one df -
        account_df <- do.call("rbind", account_list2) %>% dplyr::arrange(Date)
        # --
        # - make for each category one regular expression combining all patterns -
        categories <- sort(unique(df$category))
        names(categories) <- categories
        catPatternList <- lapply(categories, function(category){
                data.frame(pattern = paste(df$pattern[df$category == category], collapse = "|"), category = category, stringsAsFactors = FALSE)
        })
        # --
        # - list account entries for each category and make plot_df -
        account_list_patterns <- lapply(catPatternList, function(cp){
                out_df <- account_df[str_detect(string = account_df$Text, pattern =  regex(cp$pattern, ignore.case = TRUE)), ]
                if (nrow(out_df) > 0){
                        out_df$category <- cp$category
                }
                out_df
        })
        if (sum(sapply(account_list_patterns, nrow)) == 0){
                rv$infoText <- "Not a single entry in the chosen time matched a given pattern, therefore no plot was generated."
                return()
        }
        plot_df <- do.call("rbind", account_list_patterns)
        plot_df <- dplyr::select(plot_df, Date, Amount, Currency:category) %>% arrange(Date)
        plot_df2 <- plot_df # for HB2
        if (!input$individualItems){
                plot_df <- group_by(plot_df, category, Account) %>% dplyr::summarize(Amount = sum(Amount), Currency = Currency[1])
        }
        # --
        # - plot barplot -
        Tr <- ggplot(plot_df, aes(x = category, y = Amount))
        Tr <- Tr +
                geom_bar(aes(fill = Account), position = position_stack(), stat = "identity") +
                scale_fill_manual("", values = account_colors) +
                theme_bw(10) +
                xlab("") +
                ylab(paste0("Amount [", sort(unique(plot_df$Currency)), "]")) +
                ggtitle(paste0("From ", startDate(), " to ", endDate())) +
                theme(legend.position = "bottom")
        Tr <- ggplotly(Tr, tooltip = "Amount", height = 400)
        # --
        
        #lubridate::wday(plot_df2$Date, label = TRUE)
        #
        plot_df2$Month <- lubridate::month(plot_df2$Date, label = TRUE, abbr = TRUE)
        plot_df2$Year <- lubridate::year(plot_df2$Date)
        #plot_df2$Week <- strftime(plot_df2$Date, format = "%V", tz = "CET") # don't use isoweek, check 31.12
        #plot_df2$Week <- sprintf(fmt = "%0.2d", plot_df2$Week)
        plot_df2$Month_Year <- apply(plot_df2[c("Month", "Year")], 1, paste, collapse=" ")
        plot_df2$Month_Year <- factor(plot_df2$Month_Year, levels = paste(levels(plot_df2$Month), rep(sort(unique(plot_df2$Year)), each = length(levels(plot_df2$Month)))))
        
        if (!input$individualItems){
                plot_df2 <- group_by(plot_df2, category, Account, Month_Year) %>% dplyr::summarize(Amount = sum(Amount), Currency = Currency[1])
        }
        
        # - plot barplot -
        Tr1 <- ggplot(plot_df2, aes(x = Month_Year, y = Amount))
        Tr1 <- Tr1 +
                geom_bar(aes(fill = Account), stat = "identity") +
                facet_grid(category ~ ., scales = "free_y") +
                scale_fill_manual("", values = account_colors) +
                theme_bw(10) +
                xlab("") +
                ylab(paste0("Amount [", sort(unique(plot_df$Currency)), "]")) +
                theme(legend.position = "bottom")
        Tr1 <- ggplotly(Tr1, tooltip = "Amount", height = length(unique(plot_df2$category))*200)
        

        rv$plotHeightHB = 400
        rv$TrHB <- Tr
        rv$plotHeightHB2 = length(unique(plot_df2$category))*200
        rv$TrHB2 <- Tr1
        rv$infoText <- "Generated amounts per category plots."
        
})
# --

# - plot the first HB plot -
output$plotUI_HB <- renderUI({
        plotlyOutput(outputId = "hbPlot", height = paste0(rv$plotHeightHB,"px")) # rv$plotHeightHB
})

output$hbPlot <- renderPlotly({
        if (is.null(rv$TrHB)) {
                return()
                rv$infoText = "no plot generated yet"
        } else {
                print(rv$TrHB)
        }
})
# --

# - plot the second HB plot -
output$plotUI_HB2 <- renderUI({
        plotlyOutput(outputId = "hbPlot2", height = paste0(rv$plotHeightHB2,"px")) # rv$plotHeightHB
})

output$hbPlot2 <- renderPlotly({
        if (is.null(rv$TrHB2)) {
                return()
                rv$infoText = "no plot generated yet"
        } else {
                print(rv$TrHB2)
        }
})
# --



