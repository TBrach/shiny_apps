# - save Learn list in your dropbox -
observeEvent(input$saveDropbox, {
        
        if(is.null(rv$DFl)){
                rv$infoText = "I do not think you want to upload an empty learn list to your Dropbox"
                return(NULL)
        } else {
                
                if(input$calendarName == ""){
                        Name <- "NewLearn"
                } else {
                        Name <- make.names(gsub(" ", "_", input$calendarName))
                }
                
                filename = paste(Name, ".rds", sep = "")
                file_path <- file.path(tempdir(), filename)
                saveRDS(rv$DFl, file_path)
                drop_upload(file_path, path = 'apps/learn')
                rv$infoText = paste("Uploaded learn list ", Name, " to Dropbox", sep = "")
        }
})
# --