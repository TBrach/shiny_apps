# - Remove an event  -
observeEvent(input$removeEvent, { 
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFk)){
                rv$infoText <- "There are no events to remove."
        } else if (is.na(No)){
                rv$infoText <- "No of event must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFk))) {
                rv$infoText <- "The given No does not fit to any event in your calendar"
        } else if (No %in% 1:nrow(rv$DFk)) {
                
                rv$DFk <- rv$DFk[-No,]
                
                
                rv$infoText <- "Event has been removed."
                
        } else {
                rv$infoText <- "No matching event was found to remove."
        }
})
# --