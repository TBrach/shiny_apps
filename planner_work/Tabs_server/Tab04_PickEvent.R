# - Pick an event and set inputs to the values of the events -
observeEvent(input$pick, { 
        
        # reset infoText when button is pressed
        rv$infoText <- NULL
        # rv$Tr <- NULL
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFk)){
                # rv$DFi <- NULL
                rv$infoText <- "There are no events in your plan to pick from."
        } else if (is.na(No)){
                rv$infoText <- "No must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFk))) {
                rv$infoText <- "The given No does not fit to any event in your plan"
        } else if (No %in% 1:nrow(rv$DFk)) {
                # pick event
                event <- rv$DFk[No,]
                
                # name input
                updateTextInput(session, inputId = "eventName",
                                value = as.character(event$Name)
                )
                
                # category input
                updateSelectInput(session, inputId = "color",
                                  selected = as.character(event$Color))
                
                # set date input
                updateDateInput(session, inputId = "date",
                                value = format(event$startTime, "%Y-%m-%d")
                )
                
                # set time input
                # updateTextInput(session, inputId = "time",
                #                 value = as.character(paste(strftime(event$Start, "%H", tz = "CET"), ":", strftime(event$Start, "%M", tz = "CET"), sep = ""))
                # )
                updateTimeInput(session, inputId = "time", value = event$startTime)
                
                
                updateTextInput(session, inputId = "duration", value = as.character(event$Duration))
                
                
                # set endDate input
                updateDateInput(session, inputId = "endDate",
                                value = format(event$endTime, "%Y-%m-%d")
                )
                
                # set endTime input
                # updateTextInput(session, inputId = "endTime",
                #                 value = as.character(paste(strftime(event$End, "%H", tz = "CET"), ":", strftime(event$End, "%M", tz = "CET"), sep = ""))
                # )
                updateTimeInput(session, inputId = "endTime", value = event$endTime)
                
                
                # comment input
                updateTextInput(session, inputId = "comment",
                                value = as.character(event$Comment)
                )
                
                rv$infoText <- "Event has been picked."
                
        } else {
                rv$infoText <- "No matching event was found to pick."
        }
})
# --