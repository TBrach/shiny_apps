# - get planner from your dropbox -
observeEvent(input$getDropbox, {
        
        suppressMessages(filesInfo <- drop_dir(path = 'apps/calendar'))
        filePaths <- filesInfo$path_display
        
        if(input$calendarName == ""){
                Name <- "Planner_work.rds"
        } else {
                Name <- paste(input$calendarName, ".rds", sep = "")
        }
        
        if(Name %in% basename(filePaths)) {
                filePath <- filePaths[which(basename(filePaths) %in% Name)]
                # copied this code from drop_read_csv code!
                localfile = paste0(tempdir(), "/", basename(filePath))
                drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
                rv$DFk <- readRDS(file = localfile)
                # set the name input field (important if loaded Dansk.rds)
                updateTextInput(session, inputId = "calendarName",
                                value = strsplit(Name, ".rds")[[1]]
                )
                # Make sure TZ is on CET
                rv$DFk$startTime <- force_tz(rv$DFk$startTime, tz = "CET")
                rv$DFk$endTime <- force_tz(rv$DFk$endTime, tz = "CET")
                
                rv$infoText = "Loaded calendar list from Dropbox"
        } else {
                rv$infoText = "Did not find a calendar with this name in your Dropbox folder"
        }
        
})
# --