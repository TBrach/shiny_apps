# - Remove an event  -
observeEvent(input$rmEntry, { 
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFhus)){
                rv$infoText <- "There are no entries to remove."
        } else if (is.na(No)){
                rv$infoText <- "No of entry must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFhus))) {
                rv$infoText <- "The given No does not fit to any entry in hus list"
        } else if (No %in% 1:nrow(rv$DFhus)) {
                
                rv$DFhus <- rv$DFhus[-No,]
                
                if (nrow(rv$DFhus) == 0){rv$DFhus <- NULL}
                
                rv$infoText <- "Entry has been removed."
                
        } else {
                rv$infoText <- "No matching entry was found to remove."
        }
})
# --