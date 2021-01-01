# - Pick an event and set inputs to the values of the events -
observeEvent(input$pick, { 
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFk)){
                rv$infoText <- "There are no events to pick from."
        } else if (is.na(No)){
                rv$infoText <- "No of event must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFk))) {
                rv$infoText <- "The given No does not fit to any event in your calendar"
        } else if (No %in% 1:nrow(rv$DFk)) {
                # pick event
                Event <- rv$DFk[No,]
                
                updateDateInput(session, inputId = "date",
                                value = format(Event$startTime, "%Y-%m-%d")
                )
                
                updateTimeInput(session, inputId = "time", value = Event$startTime)
                
                updateDateInput(session, inputId = "endDate",
                                value = format(Event$endTime, "%Y-%m-%d")
                )
                
                updateTimeInput(session, inputId = "endTime", value = Event$endTime)
                
                updateTextInput(session, inputId = "eventName",
                                value = as.character(Event$Name)
                )
                
                updateTextInput(session, inputId = "comment",
                                value = as.character(Event$Comment)
                )
                
                updateSelectInput(session, inputId = "color",
                                  selected = as.character(Event$Color))
                
                # updateCheckboxInput(session, inputId = "wholeDay", value = FALSE)
                
                updateTextInput(session, inputId = "duration", value = "")
                
                
                rv$infoText <- "Event has been picked."
                
        } else {
                rv$infoText <- "No matching event was found to pick."
        }
})
# --