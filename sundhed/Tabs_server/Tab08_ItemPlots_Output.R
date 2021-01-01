# - output planner plots -
output$Item <- renderPlot({
        rv$Tr
})

output$itemPlot <- renderUI({
        plotOutput("Item", height = if(is.null(rv$itemPlotHeight)){10}else{rv$itemPlotHeight})
})
# --