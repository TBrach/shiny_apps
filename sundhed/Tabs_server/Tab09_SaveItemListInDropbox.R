# - save Planner in your dropbox -
observeEvent(input$saveDropbox, {
        
        if(is.null(rv$DFi)){
                rv$infoText = "I do not think you want to upload an empty item list to your Dropbox"
                return(NULL)
        } else {
                
                if(input$listName == ""){
                        rv$infoText = "Please give your item list a name"
                        return(NULL)
                } else {
                        Name <- make.names(gsub(" ", "_", input$listName))
                }
                
                filename = paste(Name, ".rds", sep = "")
                file_path <- file.path(tempdir(), filename)
                saveRDS(rv$DFi, file_path)
                drop_upload(file_path, path = 'apps/sundhed')
                rv$infoText = paste("Uploaded item list ", Name, " to Dropbox", sep = "")
        }
})
# --