# - Remove an item  -
observeEvent(input$removeItem, { 
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFl)){
                rv$infoText <- "There are no items to remove."
        } else if (is.na(No)){
                rv$infoText <- "No of item must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFl))) {
                rv$infoText <- "The given No does not fit to any item in your calendar"
        } else if (No %in% 1:nrow(rv$DFl)) {
                
                rv$DFl <- rv$DFl[-No,]
                
                
                rv$infoText <- "Item has been removed."
                
        } else {
                rv$infoText <- "No matching item was found to remove."
        }
})
# --