# - Pick an event and set inputs to the values of the events -
observeEvent(input$pick, { 
        
        # reset infoText when button is pressed
        rv$infoText <- NULL
        # rv$Tr <- NULL
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFi)){
                # rv$DFi <- NULL
                rv$infoText <- "There are no events in your itinerary to pick from."
        } else if (is.na(No)){
                rv$infoText <- "No must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFi))) {
                rv$infoText <- "The given No does not fit to any event in your itinerary"
        } else if (No %in% 1:nrow(rv$DFi)) {
                # pick event
                event <- rv$DFi[No,]
                
                # name input
                updateTextInput(session, inputId = "name",
                                value = as.character(event$Name)
                )
                
                # category input
                if(as.character(event$Category) == "Transport"){
                        updateSelectInput(session, inputId = "category",
                                          selected = "Transport")
                } else if(as.character(event$Category) == "Hotel"){
                        updateSelectInput(session, inputId = "category",
                                          selected = "Hotel")
                } else if(as.character(event$Category) == "Activity"){
                        updateSelectInput(session, inputId = "category",
                                          selected = "Activity")
                } else if(as.character(event$Category) == "Food"){
                        updateSelectInput(session, inputId = "category",
                                          selected = "Food")
                }
                
                # set date input
                updateDateInput(session, inputId = "date",
                                value = format(event$Start, "%Y-%m-%d")
                )
                
                # set time input
                # updateTextInput(session, inputId = "time",
                #                 value = as.character(paste(strftime(event$Start, "%H", tz = "CET"), ":", strftime(event$Start, "%M", tz = "CET"), sep = ""))
                # )
                updateTimeInput(session, inputId = "time", value = event$Start)
                
                
                updateTextInput(session, inputId = "duration", value = as.character(event$Duration))
                
                # set endDate input
                updateDateInput(session, inputId = "endDate",
                                value = format(event$End, "%Y-%m-%d")
                )
                
                # set endTime input
                # updateTextInput(session, inputId = "endTime",
                #                 value = as.character(paste(strftime(event$End, "%H", tz = "CET"), ":", strftime(event$End, "%M", tz = "CET"), sep = ""))
                # )
                updateTimeInput(session, inputId = "endTime", value = event$End)
                
                
                
                # link input
                Links <- strsplit(as.character(event$Link), split = "' target")[[1]][1]
                Links <- substring(Links, first = 10, last = 1000000L)
                
                updateTextInput(session, inputId = "link",
                                value = as.character(Links)
                )
                
                # comment input
                updateTextInput(session, inputId = "comment",
                                value = as.character(event$Comment)
                )
                
                # cost input
                updateTextInput(session, inputId = "cost",
                                value = as.character(event$estCost)
                )
                
                # rate input
                if(event$Rate == ""){
                        updateCheckboxInput(session, inputId = "ratedecide", value = FALSE)
                        updateSliderInput(session, inputId = "rate",
                                          value = 3)
                } else if (event$Rate == "*"){
                        updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                        updateSliderInput(session, inputId = "rate",
                                          value = 1)
                } else if (event$Rate == "**"){
                        updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                        updateSliderInput(session, inputId = "rate",
                                          value = 2)
                } else if (event$Rate == "***"){
                        updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                        updateSliderInput(session, inputId = "rate",
                                          value = 3)
                } else if (event$Rate == "****"){
                        updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                        updateSliderInput(session, inputId = "rate",
                                          value = 4)
                } else if (event$Rate == "*****"){
                        updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                        updateSliderInput(session, inputId = "rate",
                                          value = 5)
                }
                
                
                rv$infoText <- "Event has been picked."
                
        } else {
                rv$infoText <- "No matching event was found to pick."
        }
})
# --