# - Add or update button -
observeEvent(input$addItem, {
        
        rv$infoText <- NULL
        
        categories <- input$category
        if(categories == "") {
                rv$infoText <- "At least one category is needed for every item"
                return()
        }
        # to remove unwanted whitespaces -
        categories <- str_trim(unlist(str_split(categories, pattern = ",")))
        categories <- paste(categories, collapse = ", ")
        
        Name <- input$itemName
        if(Name == "") {
                rv$infoText <- "A Name is needed for every item"
                return()
        }
        
        startTime <- update(datePoint(), hour = hour(timePoint()), minute = minute(timePoint()))
        
        description <- input$description
        
        Comment <- input$comment
        
        files <- input$files
        # to remove unwanted whitespaces -
        files <- str_trim(unlist(str_split(files, pattern = ",")))
        files <- paste(files, collapse = ", ")
        
        
        Item <- data.frame(startTime = startTime, Category = categories, Name = Name, Description = description,
                            Comment = Comment, Files = files)
        
        if(is.null(rv$DFl)){
                rv$DFl <- Item
                rv$infoText <- "Item has been added."
        } else {
                rv$DFl <- rbind(rv$DFl, Item)
                if(anyDuplicated(rv$DFl[, c("startTime", "Name")])){
                        IndexDuplicated <- anyDuplicated(rv$DFl[, c("startTime", "Name")], fromLast = TRUE)
                        rv$DFl[IndexDuplicated,] <- rv$DFl[nrow(rv$DFl),]
                        rv$DFl <- rv$DFl[-nrow(rv$DFl),]
                        rv$infoText <- "Item has been updated."
                } else {
                        rv$infoText <- "Item has been added."
                }
                
                rv$DFl <- dplyr::arrange(rv$DFl, startTime, Name, Category)
                
        }
        
})
# --