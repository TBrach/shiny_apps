# - Pick an item and set inputs to the values of the events -
observeEvent(input$pick, { 
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFl)){
                rv$infoText <- "There are no items to pick from."
        } else if (is.na(No)){
                rv$infoText <- "No of item must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFl))) {
                rv$infoText <- "The given No does not fit to any item in your learn list"
        } else if (No %in% 1:nrow(rv$DFl)) {
                # pick item
                Item <- rv$DFl[No,]
                
                updateTextInput(session, inputId = "category",
                                value = as.character(Item$Category)
                )
                
                updateDateInput(session, inputId = "date",
                                value = format(Item$startTime, "%Y-%m-%d")
                )
                
                updateTimeInput(session, inputId = "time", value = Item$startTime)
                
                
                updateTextInput(session, inputId = "itemName",
                                value = as.character(Item$Name)
                )
                
                updateTextInput(session, inputId = "description",
                                value = as.character(Item$Description)
                )
                
                updateTextInput(session, inputId = "comment",
                                value = as.character(Item$Comment)
                )
                
                updateTextInput(session, inputId = "files",
                                value = as.character(Item$Files)
                )
                
                
                rv$infoText <- "Item has been picked."
                
        } else {
                rv$infoText <- "No matching item was found to pick."
        }
})
# --