# - Pick an event and set inputs to the values of the events -
observeEvent(input$pick, { 
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFi)){
                rv$infoText <- "There are no items to pick from."
        } else if (is.na(No)){
                rv$infoText <- "No of item must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFi))) {
                rv$infoText <- "The given No does not fit to any item in your calendar"
        } else if (No %in% 1:nrow(rv$DFi)) {
                # pick event
                Event <- rv$DFi[No,]
                
                updateSelectInput(session, inputId = "item",
                                  selected = as.character(Event$Item))
                
                updateSelectInput(session, inputId = "unit",
                                  selected = as.character(Event$Unit))
                
                updateDateInput(session, inputId = "date",
                                value = format(Event$Time, "%Y-%m-%d")
                )
                
                updateTimeInput(session, inputId = "time", value = Event$Time)
                
                updateNumericInput(session, inputId = "value", value = Event$Value)
                
                updateTextInput(session, inputId = "comment",
                                value = as.character(Event$Comment)
                )
                
                
                rv$infoText <- "Item has been picked."
                
        } else {
                rv$infoText <- "No matching item was found to pick."
        }
})
# --