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