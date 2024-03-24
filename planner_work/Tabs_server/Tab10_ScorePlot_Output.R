# - output the score plot -
output$ScorePlot <- renderPlot({ # Not defined in ui, just for the following plot
        rv$TrS
})

output$scorePlot <- renderUI({
        plotOutput("ScorePlot", height = if(is.null(rv$ScoreRows)){100}else{rv$ScoreRows})
})
# --