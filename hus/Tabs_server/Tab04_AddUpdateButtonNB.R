# - Add or update button -
observeEvent(input$addEntryNB, {
        
        URL <- input$urlNB
        
        # - here it would be nice with a url check -
        # --
        
        Comment <- ""
        Title = input$titleNB
        Link <- paste0("<a href='", URL, "' target='_blank'>", Title, "</a>")
        # Ref <- as.character(tags$a(href = Link, target = Name)) # alternative via tags, but needed to be corrected
        # --
        # - put into a data frame -
        
        entry <- data.frame(Title = Title,
                            Byggear = NA,
                            Pris = NA,
                            Bolig_m2 = NA,
                            PrisPerm2 = NA,
                            Grund_m2 = NA,
                            Energimaerke = NA,
                            Grund_m2 = NA,
                            Ejerudgift = NA,
                            Kaelder_m2 = NA,
                            AntalVaerelser = NA,
                            Comment = Comment,
                            Link = Link)
        
        DateTime <- now()
        Person <- input$personNB
        
        Entry <- cbind(data.frame(DateTime = DateTime, Person = Person), entry)
        
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