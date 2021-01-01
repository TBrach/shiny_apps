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