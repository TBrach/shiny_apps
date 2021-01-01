# - Add or update button -
observeEvent(input$addComment, {
        
        No <- suppressWarnings(as.numeric(input$no2))
        
        Comment <- input$comment
        
        if(is.null(rv$DFhus)){
                rv$infoText <- "There are no entries to add a comment to."
        } else if (is.na(No)){
                rv$infoText <- "No of entry must be given as a number"
        } else if (!(No %in% 1:nrow(rv$DFhus))) {
                rv$infoText <- "The given No does not fit to any entry in hus list"
        } else if (No %in% 1:nrow(rv$DFhus)) {
                
                rv$DFhus$Comment[No] <- Comment
                
                
                rv$infoText <- "Comment has been added."
                
        } else {
                rv$infoText <- "No matching entry was found to add comment to."
        }
        
})
# --