# - output planner plots -
output$itPlot <- renderPlot({
    rv$Tr
}, height = reactive({85*rv$PlotHeight}))
# --