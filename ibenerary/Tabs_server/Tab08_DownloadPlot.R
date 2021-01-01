# - allow ot download plot as pdf --
output$savePlot <- downloadHandler(
        filename = function(){
                
                if(is.null(rv$Tr)){
                        "EmptyPlot.pdf"
                } else {
                        ItName <- input$itname
                        if(ItName == ""){ItName <- "Itinerary"}
                        # paste(date(now()), "_", ItName, ".csv", sep = "")
                        paste("Plot_", ItName, ".pdf", sep = "")
                }
        },
        
        content = function(file) {
                # pdf(file, width = 12, height = rv$PlotHeight)
                pdf(file, width = 8.20, height = rv$PlotHeight) # decided to always go for DINA4 width (8.27 inches)
                # The PlotHeight should be so that 4 days fill a DINA4 height (11.69 inches), 11.69/4 = 2.9225, >> 2.9 per dayCovered 
                print(rv$Tr)
                dev.off()
        })
# --