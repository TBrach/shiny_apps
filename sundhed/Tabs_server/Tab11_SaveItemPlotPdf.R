# - Save ItemPlot as pdf -
output$savePlot <- downloadHandler(
        filename = function(){
                
                if(is.null(rv$Tr)){
                        "EmptyItemPlot.pdf"
                } else {
                        "ItemPlot.pdf"
                }
        },
        
        content = function(file) {
                pdf(file, width = 10, height = if(is.null(rv$itemPlotHeight)){5}else{3*rv$itemPlotHeight/200})
                print(rv$Tr)
                dev.off()
        })
# --