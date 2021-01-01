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