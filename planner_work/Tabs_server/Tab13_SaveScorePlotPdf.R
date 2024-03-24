# - Save ScorePlot as pdf -
output$savePlot <- downloadHandler(
        filename = function(){
                
                if(is.null(rv$TrS)){
                        "EmptyWeekPlot.pdf"
                } else {
                        "ScorePlot.pdf"
                }
        },
        
        content = function(file) {
                pdf(file, width = 12, height = (rv$ScoreRows/185)*3)
                print(rv$TrS)
                dev.off()
        })
# --