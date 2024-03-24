# - generate the Score plot when plotScore button is pressed --
observeEvent(input$plotScore, { 
        
        if(is.null(rv$DFk)){
                
                rv$ScoreRows <- NULL
                TrS <- NULL
                rv$TrS <- TrS
                rv$infoText <- "There are no events yet in your calendar to  make a score plot of :)."
                
        } else {
                
                DFkPlot <- rv$DFk
                
                # - restrict DFkPlot to entries that overlap with the month of the plotDate plus 1 week on each side -
                plotMonth <- interval(start = update(plotDate(), day = 1) - weeks(1), 
                                      end = update(plotDate(), day = 1) + months(1) + weeks(1)) 
                DFkPlot <- DFkPlot[int_overlaps(interval(start = DFkPlot$startTime, end = DFkPlot$endTime), plotMonth),]
                # --
                
                if (dim(DFkPlot)[1] == 0) {
                        
                        rv$ScoreRows <- NULL
                        TrS <- NULL
                        rv$TrS <- TrS
                        rv$infoText <- "There are no events in the month around the requested plot data to make a score plot of."
                        
                } else {
                        
                        # - you want the bars always in the same order -
                        DFkPlot$Color <- factor(DFkPlot$Color, levels = rev(colorLevels), ordered = TRUE)
                        # --
                        
                        # - split multiple day entries using splitMultidayEntries()-
                        DFkPlot$startDate <- format(DFkPlot$startTime, "%Y-%m-%d")
                        DFkPlot$startDate <- lubridate::parse_date_time(DFkPlot$startDate, orders = "ymd", tz = "CET")
                        DFkPlot$endDate <- format(DFkPlot$endTime, "%Y-%m-%d")
                        DFkPlot$endDate <- lubridate::parse_date_time(DFkPlot$endDate, orders = "ymd", tz = "CET")
                        if(any(DFkPlot$endDate > DFkPlot$startDate)){
                                DFkPlot <- splitMultidayEntries(DFkPlot)
                                DFkPlot <- dplyr::filter(DFkPlot, Duration > 0)
                        }
                        # --
                        
                        # - add week and year info -
                        DFkPlot$Wday <- lubridate::wday(DFkPlot$startTime, label = TRUE)
                        DFkPlot$Week <- strftime(DFkPlot$startDate, format = "%V", tz = "CET") # to use ISO 8601 (while lubridate uses US)
                        DFkPlot$Year <- lubridate::year(DFkPlot$startTime)
                        #DFkPlot$Hours <- as.numeric(as.duration(DFkPlot$startTime - update(DFkPlot$startTime, hour = 0, minute = 0)), "hours")
                        #DFkPlot$dayLabel <- paste(DFkPlot$Wday, " ", format.Date(DFkPlot$startDate, "%d"), ".", format.Date(DFkPlot$startDate, "%m"), ".", format.Date(DFkPlot$startDate, "%y"), ", W", DFkPlot$Week, sep = "")
                        # DFkPlot$shortName <- substring(as.character(DFkPlot$Name), first = 1, last = 18)
                        DFkPlot$YearWeek <- paste(DFkPlot$Year, " W", DFkPlot$Week, sep = "")
                        # --
                        
                        # - summarise and plot -
                        DF_Summary <- group_by(DFkPlot, YearWeek, Color) %>% summarise(Duration_hours = sum(Duration)/60) 
                        DF_Summary$Color <- factor(DF_Summary$Color, levels = names(colorValues)) %>% fct_drop()
                        
                        TrS <- ggplot(DF_Summary, aes(x = Color, y = Duration_hours, fill = Color))
                        TrS <- TrS +
                                geom_col() +
                                facet_grid(YearWeek ~ .) +
                                scale_fill_manual("", values = colorValues[levels(DF_Summary$Color)]) +
                                scale_x_discrete(drop = FALSE) +
                                xlab("") +
                                ylab("Duration [hours]") +
                                theme_bw() +
                                coord_flip() +
                                theme(legend.position = "none",
                                      strip.background = element_rect(fill="#660033"),
                                      strip.text = element_text(size = 8, colour="white"),
                                      panel.grid.major.y = element_blank()) 
                        # --
                        
                        
                        rv$ScoreRows <- length(unique(DF_Summary$YearWeek))*185
                        rv$TrS <- TrS
                        rv$infoText <- "Score plot has been generated."
                }
                
        }
        
})
# --