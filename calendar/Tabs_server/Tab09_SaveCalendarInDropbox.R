# - save calendar in your dropbox -
observeEvent(input$saveDropbox, {
        
        if(is.null(rv$DFk)){
                rv$infoText = "I do not think you want to upload an empty calendar to your Dropbox"
                return(NULL)
        } else {
                
                if(input$calendarName == ""){
                        Name <- "Calendar"
                } else {
                        Name <- make.names(gsub(" ", "_", input$calendarName))
                }
                
                filename = paste(Name, ".rds", sep = "")
                file_path <- file.path(tempdir(), filename)
                saveRDS(rv$DFk, file_path)
                drop_upload(file_path, path = 'apps/calendar')
                rv$infoText = paste("Uploaded calendar ", Name, " to Dropbox", sep = "")
        }
})
# --