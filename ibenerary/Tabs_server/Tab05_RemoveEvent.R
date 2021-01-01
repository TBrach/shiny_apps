# - Remove an event  -
observeEvent(input$pickRemove, { 
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFi)){
                rv$infoText <- "There are no events to remove."
        } else if (is.na(No)){
                rv$infoText <- "No of event must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFi))) {
                rv$infoText <- "The given No does not fit to any event in your itinerary"
        } else if (No %in% 1:nrow(rv$DFi)) {
                
                rv$DFi <- rv$DFi[-No,]
                
                
                rv$infoText <- "Event has been removed."
                
        } else {
                rv$infoText <- "No matching event was found to remove."
        }
})
# --