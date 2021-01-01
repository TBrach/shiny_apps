# - get planner from your dropbox -
observeEvent(input$getDropbox, {
        
        suppressMessages(filesInfo <- drop_dir(path = 'apps/sundhed'))
        filePaths <- filesInfo$path_display
        
        if(input$listName == ""){
                rv$infoText = "Please give your item list to upload a name without .rds"
                return(NULL)
        } else {
                Name <- paste(input$listName, ".rds", sep = "")
        }
        
        if(Name %in% basename(filePaths)) {
                filePath <- filePaths[which(basename(filePaths) %in% Name)]
                # copied this code from drop_read_csv code!
                localfile = paste0(tempdir(), "/", basename(filePath))
                drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
                rv$DFi <- readRDS(file = localfile)
                # set the name input field (important if loaded Dansk.rds)
                updateTextInput(session, inputId = "listName",
                                value = strsplit(Name, ".rds")[[1]]
                )
                # Make sure TZ is on CET
                rv$DFi$Time <- force_tz(rv$DFi$Time, tz = "CET")
                
                rv$infoText = "Loaded item list from Dropbox"
        } else {
                rv$infoText = "Did not find an item list with this name in your Dropbox folder"
        }
        
})
# --