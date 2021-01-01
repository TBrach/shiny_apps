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