# - save Planner in your dropbox -
observeEvent(input$saveDropbox, {
        
        if(is.null(rv$DFhus)){
                rv$infoText = "I do not think you want to upload an empty hus list to your Dropbox"
                return(NULL)
        } else {
                
                Name <- "Hus"
                filename = paste(Name, ".rds", sep = "")
                file_path <- file.path(tempdir(), filename)
                saveRDS(rv$DFhus, file_path)
                drop_upload(file_path, path = 'apps/hus')
                rv$infoText = "Uploaded hus list to Dropbox"
        }
})
# --