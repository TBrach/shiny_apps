# - Add or update button -
observeEvent(input$addItem, {
        
        
        rv$Tr <- NULL
        rv$itemPlotHeight <- NULL
        
        Item <- input$item
        if(Item == "") {
                rv$infoText <- "An item has to be chosen"
                return()
        }
        
        Unit <- input$unit
        if(Unit == "") {
                rv$infoText <- "A unit has to be chosen"
                return()
        }
        
        Value <- input$value
        
        Time <- update(datePoint(), hour = hour(timePoint()), minute = minute(timePoint()))
        
        
        Comment <- input$comment
        
        Event <- data.frame(Time = Time, Item = Item, Unit = Unit, Value = Value, Comment = Comment)
        
        if(is.null(rv$DFi)){
                rv$DFi <- Event
                rv$infoText <- "Item has been added."
        } else {
                rv$DFi <- rbind(rv$DFi, Event)
                if(anyDuplicated(rv$DFi[, c("Time", "Item")])){
                        IndexDuplicated <- anyDuplicated(rv$DFi[, c("Time", "Item")], fromLast = TRUE)
                        rv$DFi[IndexDuplicated,] <- rv$DFi[nrow(rv$DFi),]
                        rv$DFi <- rv$DFi[-nrow(rv$DFi),]
                        rv$infoText <- "Item has been updated."
                } else {
                        rv$infoText <- "Item has been added."
                }
                
                rv$DFi$Item <- factor(rv$DFi$Item, levels = itemLevels, ordered = TRUE) # for plots and table ordering
                rv$DFi <- dplyr::arrange(rv$DFi, Time, Item)
                
        }
        
})
# --