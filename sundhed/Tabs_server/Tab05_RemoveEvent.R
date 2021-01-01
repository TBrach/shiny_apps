# - Remove an item  -
observeEvent(input$removeItem, { 
        
        rv$Tr <- NULL
        rv$itemPlotHeight <- NULL
        
        No <- suppressWarnings(as.numeric(input$no))
        
        if(is.null(rv$DFi)){
                rv$infoText <- "There are no items to remove."
        } else if (is.na(No)){
                rv$infoText <- "No of item must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFi))) {
                rv$infoText <- "The given No does not fit to any item in your list"
        } else if (No %in% 1:nrow(rv$DFi)) {
                
                rv$DFi <- rv$DFi[-No,]
                
                if(nrow(rv$DFi) == 0){
                        rv$DFi <- NULL
                }
                
                
                rv$infoText <- "Item has been removed."
                
        } else {
                rv$infoText <- "No matching item was found to remove."
        }
})
# --