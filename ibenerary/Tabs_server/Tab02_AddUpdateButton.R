# - Add or update button -
observeEvent(input$AddUpdate, { 
        
        # reset infoText when button is pressed
        rv$infoText <- NULL
        rv$Tr <- NULL
        
        Name <- input$name
        if(Name == "") {
                rv$infoText <- "A Name is needed for every event"
                return()
        }
        
        startTime <- update(datePoint(), hour = hour(timePoint()), minute = minute(timePoint()))
        Duration <- as.numeric(input$duration)
        
        if(is.na(Duration) || Duration < 5){
                endTime <- update(endDatePoint(), hour = hour(endTimePoint()), minute = minute(endTimePoint()))
                Duration <- as.numeric(as.duration(endTime-startTime), "minutes")
                if(Duration < 5){
                        rv$infoText <- "Sorry events have to last at least 5 minutes"
                        return()
                }
        } else {
                endTime <- startTime + minutes(Duration)
        }
        
        Category <- input$category
        Link <- input$link
        if (Link == ""){
                Ref <- ""
        } else {
                Ref <- paste0("<a href='",Link,"' target='_blank'>",Name,"</a>")
                # Ref <- as.character(tags$a(href = Link, target = Name)) # alternative via tags, but needed to be corrected
        }
        Cost <- suppressWarnings(as.numeric(input$cost))
        Comment <- input$comment
        Rate <- Rating()
        if(is.null(Rate)){
                Rate <- ""
        } else if(Rate == 1) {
                Rate <- "*"
        } else if(Rate == 2) {
                Rate <- "**"
        } else if(Rate == 3) {
                Rate <- "***"
        } else if(Rate == 4) {
                Rate <- "****"
        } else if(Rate == 5) {
                Rate <- "*****"
        }
        
        event <- data.frame(Name = Name, Category = Category, Start = startTime, End = endTime, Duration = Duration,  Link = Ref,
                            Comment = Comment, estCost = Cost, Rate = Rate)
        if(is.null(rv$DFi)){
                rv$DFi <- event
                rv$infoText <- "Event has been added."
        } else {
                rv$DFi <- rbind(rv$DFi, event)
                rv$infoText <- "Event has been added."
                if(anyDuplicated(rv$DFi[, c("Name", "Start")])){
                        IndexDuplicated <- anyDuplicated(rv$DFi[, c("Name", "Start")], fromLast = TRUE)
                        rv$DFi[IndexDuplicated,] <- rv$DFi[nrow(rv$DFi),]
                        rv$DFi <- rv$DFi[-nrow(rv$DFi),]
                        rv$infoText <- "Event has been updated."
                }
                
                rv$DFi <- dplyr::arrange(rv$DFi, Start)
                
        }
        
})
# --