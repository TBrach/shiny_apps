# - Add or update button -
observeEvent(input$addEntry, {
        
        URL <- input$url
        
        # - here it would be nice with a url check -
        # --
        
        Entry <- extract_info_visBolig_boliga(url = URL)
        
        DateTime <- now()
        Person <- input$person
        
        Entry <- cbind(data.frame(DateTime = DateTime, Person = Person), Entry)
        
        if(is.null(rv$DFhus)){
                rv$DFhus <- Entry
                rv$infoText <- "Entry has been added."
        } else {
                rv$DFhus <- rbind(rv$DFhus, Entry)
                if(any(duplicated(dplyr::select(rv$DFhus, Person:AntalVaerelser)))){
                        IndexDuplicated <- anyDuplicated(dplyr::select(rv$DFhus, Person:AntalVaerelser), fromLast = TRUE)
                        rv$DFhus[IndexDuplicated,] <- rv$DFhus[nrow(rv$DFhus),]
                        rv$DFhus <- rv$DFhus[-nrow(rv$DFhus),]
                        rv$infoText <- "Event has been updated."
                } else {
                        rv$infoText <- "Event has been added."
                }
                
                rv$DFhus <- dplyr::arrange(rv$DFhus, DateTime)
                
        }
        
})
# --