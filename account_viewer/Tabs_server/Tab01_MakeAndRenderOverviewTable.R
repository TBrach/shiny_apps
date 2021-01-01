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
                minDates <- sapply(1:length(account_list), function(i){as.character(min(account_list[[i]]$Date))})
                maxDates <- sapply(1:length(account_list), function(i){as.character(max(account_list[[i]]$Date))})
                Entries <- sapply(account_list, "nrow")
                minAmount <- sapply(1:length(account_list), function(i){min(account_list[[i]]$Saldo)})
                maxAmount <- sapply(1:length(account_list), function(i){max(account_list[[i]]$Saldo)})
                lastAmount <- sapply(1:length(account_list), function(i){
                        if (account_list[[i]]$Date[1] > account_list[[i]]$Date[nrow(account_list[[i]])]){
                                account_list[[i]]$Saldo[1]
                                
                        } else {
                                account_list[[i]]$Saldo[nrow(account_list[[i]])]
                        }
                })
                Currencies <- sapply(1:length(account_list), function(i){paste(unique(account_list[[i]]$Currency), collapse = "_")})
                DF <- data.frame(Index = Indexes, Name = Names, minDate = minDates, maxDate = maxDates, NoEntries = Entries,
                                 minAmount = minAmount, maxAmount = maxAmount, lastAmount = lastAmount, Currency = Currencies)
                rv$overviewTable <- DF
        }
        
})
# --


# - render the overviewViews table -
output$overviewTable <- renderTable({
        rv$overviewTable
}, sanitize.text.function = function(x) x, caption = "Overview of loaded accounts", caption.placement = getOption("xtable.caption.placement", "top"))
# --

# - output infoText -
output$infoText <- renderText({
        rv$infoText
})

# output$infoText2 <- renderText({
#         rv$infoText
# })
# --
