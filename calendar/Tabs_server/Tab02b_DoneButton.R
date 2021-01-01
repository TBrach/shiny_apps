# - Done button -
# I still think the idea is not stupid, so maybe it comes back at a timepoint
observeEvent(input$done, {
        
        if(is.null(rv$DFk)){
                rv$infoText <- "Sorry, for safety reasons, you can not start a calendar with Done"
                return()
        }
        
        
        Person <- input$person
        Task <- input$task
        Name <- paste(Task, "_", substr(Person, 1,2), sep = "")
        startTime <- update(doneDate(), hour = hour(doneTimePoint()), minute = minute(doneTimePoint()))
        Duration <- 20
        endTime <- startTime + minutes(Duration)
        if (Task == "legday") {
                Color <- "legday"
        } else if (Task == "abday"){
                Color <- "abday"
        } 
        Comment = ""
        
        Event <- data.frame(startTime = startTime, Duration = Duration, endTime = endTime, Name = Name, Color = Color,
                            Comment = Comment)
        
        rv$DFk <- rbind(rv$DFk, Event)
        if(anyDuplicated(rv$DFk[, c("startTime", "Name")])){
                IndexDuplicated <- anyDuplicated(rv$DFk[, c("startTime", "Name")], fromLast = TRUE)
                rv$DFk[IndexDuplicated,] <- rv$DFk[nrow(rv$DFk),]
                rv$DFk <- rv$DFk[-nrow(rv$DFk),]
                info <- "Done event has been updated"
        } else {
                info <- "Done event has been added"
        }
        
        rv$DFk <- dplyr::arrange(rv$DFk, startTime, Name, Color)
        
        if(input$calendarName == ""){
                Name <- "Calendar"
        } else {
                Name <- make.names(gsub(" ", "_", input$calendarName))
        }
        
        filename = paste(Name, ".rds", sep = "")
        file_path <- file.path(tempdir(), filename)
        saveRDS(rv$DFk, file_path)
        drop_upload(file_path, path = 'Public/Calendar')
        rv$infoText = paste(info, " and calendar ", Name, " has been send to Dropbox", sep = "")
        
})
# --