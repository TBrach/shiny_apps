# - generate the plots when plot button is pressed -
observeEvent(input$plot, { 
        rv$TrHB <- NULL
        rv$TrHB2 <- NULL
        rv$plotHeightHB = 0
        rv$plotHeightHB2 = 0
        
        if(is.null(rv$account_list)){
                rv$infoText <- "There is no account data to plot, please upload account data first."
                rv$Tra <- NULL
                rv$plotHeight <- 0
        } else {
                
                account_list <- rv$account_list
                
                account_colors <- rv$account_colors
                
                if(isTRUE(input$restrictItem)){
                        accountNames <- input$itemNames
                        account_list <- account_list[names(account_list) %in% accountNames]
                }
                
                if (length(account_list) == 0){
                        rv$infoText <- "No accounts selected, no plot possible"
                        return()
                }
                
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
                # THIS IS WHERE THE ERROR CURRENTLY OCCURS
                df <- account_list2[[1]]
                account_list2 <- lapply(account_list2, function(df){
                        rleDates <- rle(as.character(df$Date))[[1]]
                        df$Minute <- unlist(lapply(rleDates, function(i){minute_spreader(i)}))
                        df$ActionTime <- df$Date + lubridate::minutes(df$Minute)
                        if (nrow(df) > 1){
                                df$NextTime <- c(df$ActionTime[2:nrow(df)], df$ActionTime[nrow(df)] + lubridate::minutes(5))
                        } else {
                                df$NextTime <- df$ActionTime[nrow(df)] + lubridate::minutes(5)
                        }
                        df
                        
                })
                
                # --
                # - define the colors for the accounts and order them - 
                accounts <- names(account_list2)
                if ("Total" %in% accounts) {
                        accounts <- c("Total", setdiff(accounts, "Total"))
                }
                # -- 
                # - put DFaPlot together -
                DFaPlot <- do.call("rbind", account_list2)
                DFaPlot$Account <- factor(DFaPlot$Account, levels = accounts, ordered = TRUE)
                # --
                # - remove weird characters -
                DFaPlot$Text <- str_replace_all(string = DFaPlot$Text, "[^[:alnum:][:space:][_\\-\\:\\*]]", "?")
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