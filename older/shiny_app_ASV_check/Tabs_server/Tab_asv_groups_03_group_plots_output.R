# - output planner plots -
output$group_plot_input <- renderPlot({
        if (is.null(rv$c_group_name)) {
                NULL
        } else {
                # lay <- rbind(c(NA,1,NA), c(2,2,2), c(3,3,3), c(3,3,3), c(3,3,3)) # https://cran.r-project.org/web/packages/gridExtra/vignettes/arrangeGrob.html
                # lay <- rbind(c(NA,1,NA), c(2,2,2)) --> would be for layout_matrix
                grid.arrange(rv$group_counts_plots[[rv$c_group_name]], rv$group_tree_plots[[rv$c_group_name]], ncol = 2)
        }
})

output$group_plot <- renderUI({
        plotOutput("group_plot_input", height = if(is.null(rv$group_counts_plots)){"10px"}else{"400px"}) # if only number is given for height, "px" will be added
})
# --