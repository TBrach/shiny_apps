# - use render Table to display itinerary -
output$husTable <- renderTable({
        if(!is.null(rv$DFhus)){
                DFhusShow <- cbind(No = 1:nrow(rv$DFhus), rv$DFhus)
                
                # if(isTRUE(input$search)){
                #         DFkShow <- DFkShow[grep(pattern = input$wordsearch, DFkShow$Name),] 
                #         
                # }
                
                # if(isTRUE(input$filter) && dim(DFkShow)[1] != 0){
                #     cat <- input$catfilt
                #     DFkShow <- DFkShow[DFkShow$Color == cat,] 
                #     
                # }
                
                if (dim(DFhusShow)[1] != 0) {
                        
                        # New show newest on top
                        DFhusShow <- dplyr::arrange(DFhusShow, desc(DateTime))
                        DFhusShow$DateTime <- format(DFhusShow$DateTime, format='%Y-%m-%d %H:%M:%S')
                        DFhusShow
                } else {
                        NULL
                }
        } else {
                NULL
        }}, sanitize.text.function = function(x) x)
# --