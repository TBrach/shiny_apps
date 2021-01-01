# - get planner from your dropbox -
observeEvent(input$GetDrop, {
        
        suppressMessages(filesInfo <- drop_dir(path = 'apps/itineraries'))
        filePaths <- filesInfo$path_display
        
        if(input$itname == ""){
                Name <- "Itinerary.rds"
        } else {
                Name <- paste(input$itname, ".rds", sep = "")
        }
        
        if(Name %in% basename(filePaths)) {
                filePath <- filePaths[which(basename(filePaths) %in% Name)]
                # copied this code from drop_read_csv code!
                localfile = paste0(tempdir(), "/", basename(filePath))
                drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
                rv$DFi <- readRDS(file = localfile)
                # set the name input field (important if loaded Dansk.rds)
                updateTextInput(session, inputId = "itname",
                                value = strsplit(Name, ".rds")[[1]]
                )
                rv$infoText = "Loaded itinerary from DP"
        } else {
                rv$infoText = "Did not find an itinerary with this name in DP"
        }
        
})
# --