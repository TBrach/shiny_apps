# - Save WeekPlot as pdf -
output$savePlot <- downloadHandler(
        filename = function(){
                
                if(is.null(rv$TrL)){
                        "EmptyWeekPlot.pdf"
                } else {
                        "WeekPlot.pdf"
                }
        },
        
        content = function(file) {
                pdf(file, width = 12, height = 8)
                print(rv$TrL[["Tr2"]])
                dev.off()
        })
# --