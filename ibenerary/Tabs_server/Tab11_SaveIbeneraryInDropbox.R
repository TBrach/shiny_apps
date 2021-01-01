# - save Planner in your dropbox -
observeEvent(input$Drop, {
    
    if(is.null(rv$DFi)){
        rv$infoText = "You can not upload empty itineraries, makes no sense"
        return(NULL)
    } else {
        
        if(input$itname == ""){
            Name <- "Itinerary"
        } else {
            #Name <- make.names(gsub(" ", "_", input$itname))
            Name <- gsub(" ", "_", input$itname) # removed the make.names because it changes 2017... to X2017...
        }
        
        filename = paste(Name, ".rds", sep = "")
        file_path <- file.path(tempdir(), filename)
        saveRDS(rv$DFi, file_path)
        drop_upload(file_path, path = 'apps/itineraries')
        rv$infoText = paste("Saved itinerary: ", Name, ".rds to Dropbox", sep = "")
    }
})
# --