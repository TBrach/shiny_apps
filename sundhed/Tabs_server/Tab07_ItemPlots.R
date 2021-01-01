# - generate the planner plots -
observeEvent(input$plot, { 
        
        rv$itemPlotHeight <- NULL
        rv$Tr <- NULL
        
        if(is.null(rv$DFi)){
                
                rv$planPlotHeight <- NULL
                rv$infoText <- "No items yet to plot"
                return()
                
        } else {
                
                DFiPlot <- rv$DFi
                
                if(isTRUE(input$restrictItem)){
                        itemNames <- input$itemNames
                        DFiPlot <- DFiPlot[DFiPlot$Item %in% itemNames,]
                        
                }
                
                if (nrow(DFiPlot) == 0){
                        rv$planPlotHeight <- NULL
                        rv$infoText <- "No items to plot after item restriction"
                        return()
                }
                
                if(isTRUE(input$restrictDate)){
                        DFiPlot <- DFiPlot[DFiPlot$Time >= startDatePoint(),]
                        DFiPlot <- DFiPlot[DFiPlot$Time <= endDatePoint() + days(1),]
                        
                }
                
                if (nrow(DFiPlot) == 0){
                        rv$planPlotHeight <- NULL
                        rv$infoText <- "No items to plot after date restriction"
                        return()
                }
                
                # - Plot only the items that are there in the order defined by itemLevels -
                # --NB: I correct here potentially wrongly assigned units, so never allow 2 units --
                DFiPlot$Unit <- unitLevels[DFiPlot$Item]
                # ----
                DFiPlot$ItemUnit <- paste(as.character(DFiPlot$Item), " [", as.character(DFiPlot$Unit), "]", sep = "")
                ItemsUnit <- DFiPlot$ItemUnit
                ItemsUnit <- unique(ItemsUnit)
                ItemLevels <- paste(itemLevels, " [", unitLevels, "]", sep = "")
                ItemLevels <- ItemLevels[ItemLevels %in% ItemsUnit]
                DFiPlot$ItemUnit <- factor(DFiPlot$ItemUnit, levels = ItemLevels, ordered = TRUE)
                DFiPlot$Goal <- itemGoals[DFiPlot$Item]
                # --
                
                Tr <- ggplot(DFiPlot)
                Tr <- Tr +
                        geom_hline(aes(yintercept = Goal), lty = 4, col = "red", size = 1.5) +
                        geom_point(aes(x = Time, y = Value), size = 3) +
                        facet_grid(ItemUnit ~ ., scales = "free") +
                        xlab("") +
                        ylab("") +
                        theme_bw() +
                        theme(strip.background = element_rect(fill="#660033"),
                              strip.text = element_text(size = 10, colour="white"))
                
                rv$itemPlotHeight <- 200 * length(ItemLevels)
                rv$Tr <- Tr
                rv$infoText <- "Plot has been generated"
                
        }
        
})
# --