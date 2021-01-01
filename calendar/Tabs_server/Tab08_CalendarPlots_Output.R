# - output calendar plots -
output$calendar <- renderPlot({
        if (is.null(rv$TrL)) {
                rv$TrL
        } else {
                lay <- rbind(c(NA,1,NA), c(2,2,2), c(3,3,3), c(3,3,3), c(3,3,3)) # https://cran.r-project.org/web/packages/gridExtra/vignettes/arrangeGrob.html
                grid.arrange(rv$TrL[[1]], rv$TrL[[2]], rv$TrL[[3]], layout_matrix = lay)
        }
}, 
height = 1250)
# --