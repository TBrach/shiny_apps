# - output planner plots -
output$Calendar <- renderPlot({
        if (is.null(rv$TrL)) {
                rv$TrL
        } else {
                # lay <- rbind(c(NA,1,NA), c(2,2,2), c(3,3,3), c(3,3,3), c(3,3,3)) # https://cran.r-project.org/web/packages/gridExtra/vignettes/arrangeGrob.html
                lay <- rbind(c(NA,1,NA), c(2,2,2))
                grid.arrange(rv$TrL[[1]], rv$TrL[[2]], layout_matrix = lay)
        }
})

output$calendar <- renderUI({
        plotOutput("Calendar", height = if(is.null(rv$planPlotHeight)){10}else{rv$planPlotHeight})
})
# --