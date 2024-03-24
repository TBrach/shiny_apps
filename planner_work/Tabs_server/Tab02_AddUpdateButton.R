# - Add or update button -
observeEvent(input$addEvent, {
        
        # reset infoText when button is pressed
        # rv$infoText <- NULL
        
        Name <- input$eventName
        if(Name == "") {
                rv$infoText <- "A Name is needed for every entry"
                return()
        }
        
        startTime <- update(datePoint(), hour = hour(timePoint()), minute = minute(timePoint()))
        Duration <- as.numeric(input$duration)
        
        # if(input$wholeDay){
        #         startTime <- update(datePoint(), hour = 0, minute = 0)
        #         Duration <- 1440
        # } 
        
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
        
        # Urgency <- input$urgency
        Color <- input$color
        Comment <- input$comment
        
        Event <- data.frame(startTime = startTime, Duration = Duration, endTime = endTime, Name = Name, Color = Color,
                            Comment = Comment)
        
        if(is.null(rv$DFk)){
                rv$DFk <- Event
                rv$infoText <- "Event has been added."
        } else {
                rv$DFk <- rbind(rv$DFk, Event)
                if(anyDuplicated(rv$DFk[, c("startTime", "Name")])){
                        IndexDuplicated <- anyDuplicated(rv$DFk[, c("startTime", "Name")], fromLast = TRUE)
                        rv$DFk[IndexDuplicated,] <- rv$DFk[nrow(rv$DFk),]
                        rv$DFk <- rv$DFk[-nrow(rv$DFk),]
                        rv$infoText <- "Event has been updated."
                } else {
                        rv$infoText <- "Event has been added."
                }
                
                rv$DFk <- dplyr::arrange(rv$DFk, startTime, Name, Color)
                
        }
        
})
# --