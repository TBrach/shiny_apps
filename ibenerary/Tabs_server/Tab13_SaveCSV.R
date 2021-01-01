# - save itinerary as csv -
output$save <- downloadHandler(
        # downloadHandler takes two arguments, both functions
        # the filename function:
        filename = function(){
                
                if(is.null(rv$DFi)){
                        "EmptyItinerary.csv"
                } else {
                        ItName <- input$itname
                        if(ItName == ""){ItName <- "Itinerary"}
                        # paste(date(now()), "_", ItName, ".csv", sep = "")
                        paste(ItName, ".csv", sep = "")
                }
        },
        
        content = function(file) {
                # rv$infoText <- NULL # does not work
                if(is.null(rv$DFi)){
                        rv$infoText <- "Downloaded an empty csv"
                        DFiSave <- NULL
                } else {
                        rv$infoText <- "Downloaded itinerary as csv"
                        DFiSave <- rv$DFi
                        DFiSave <- data.frame(lapply(DFiSave, as.character), stringsAsFactors=FALSE)
                        # extract actual links from Link column
                        # extract actual links from Link column
                        Links <- DFiSave$Link[DFiSave$Link != ""]
                        Links <- strsplit(Links, split = "' target")
                        Links <- sapply(Links, `[`, 1)
                        Links <- substring(Links, first =  10, last = 1000000L)
                        DFiSave$Link[DFiSave$Link != ""] <- Links
                }
                write.table(DFiSave, file, sep = ";", row.names = FALSE)
                #write.csv(DFiSave, file)
        }
)
# --