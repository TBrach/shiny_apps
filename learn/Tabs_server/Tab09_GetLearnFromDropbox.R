# - get learn list from your dropbox -
observeEvent(input$getDropbox, {
        
        suppressMessages(filesInfo <- drop_dir(path = 'apps/learn'))
        filePaths <- filesInfo$path_display
        
        if(input$calendarName == ""){
                Name <- "Learn.rds"
        } else {
                Name <- paste(input$calendarName, ".rds", sep = "")
        }
        
        if(Name %in% basename(filePaths)) {
                filePath <- filePaths[which(basename(filePaths) %in% Name)]
                # copied this code from drop_read_csv code!
                localfile = paste0(tempdir(), "/", basename(filePath))
                drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
                rv$DFl <- readRDS(file = localfile)
                # set the name input field (important if loaded Dansk.rds)
                updateTextInput(session, inputId = "calendarName",
                                value = strsplit(Name, ".rds")[[1]]
                )
                # Make sure TZ is on CET
                rv$DFl$startTime <- force_tz(rv$DFl$startTime, tz = "CET")
                
                rv$infoText = "Loaded learn list from Dropbox"
        } else {
                rv$infoText = "Did not find a learn list with this name in your Dropbox folder"
        }
        
})
# --