# - generate the calendar plots -
observeEvent(input$plot, { 
        
        if(is.null(rv$DFk)){
                
                dayTr <- dayPlotMock(plotDate(), plotWidth = 16)
                weekTr <- weekPlotMock(plotDate(), plotWidth = 5)
                # or:
                # weekTr <- weekPlot2Mock(plotDate(), plotWidth = 5)
                monthTr <- monthPlotMock(plotDate(), plotWidth = 5)
                rv$TrL <- list(Tr1 = dayTr, Tr2 = weekTr, Tr3 = monthTr)
                rv$infoText <- "Plots were generated: There are no events yet in your calendar :)."
                
        } else {
                
                DFkPlot <- rv$DFk
                
                # - restrict DFkPlot to entries that overlap with the month of the plotDate plus 1 week on each side -
                plotMonth <- interval(start = update(plotDate(), day = 1) - weeks(1), 
                                      end = update(plotDate(), day = 1) + months(1) + weeks(1)) 
                DFkPlot <- DFkPlot[int_overlaps(interval(start = DFkPlot$startTime, end = DFkPlot$endTime), plotMonth),, drop = FALSE]
                # --
                
                if (dim(DFkPlot)[1] == 0) {
                        
                        dayTr <- dayPlotMock(plotDate(), plotWidth = 16)
                        weekTr <- weekPlotMock(plotDate(), plotWidth = 5)
                        # or:
                        # weekTr <- weekPlot2Mock(plotDate(), plotWidth = 5)
                        monthTr <- monthPlotMock(plotDate(), plotWidth = 5)
                        rv$TrL <- list(Tr1 = dayTr, Tr2 = weekTr, Tr3 = monthTr)
                        rv$infoText <- "Plots were generated: No events around the requested plot date."
                        
                } else {
                        
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
                        
                        # - Find Blocks of overlapping events using blockFinder()-
                        DFkPlot <- blockFinder(DFkPlot)
                        # --
                        
                        # - determine position and width of each element using positionAndWidthAssigner()
                        DFkPlot <- positionAndWidthAssigner(DFkPlot)
                        # --
                        
                        # - generate day plots -
                        # add day specific info
                        DFkPlot$Wday <- lubridate::wday(DFkPlot$startTime, label = TRUE)
                        DFkPlot$Week <- strftime(DFkPlot$startDate, format = "%V", tz = "CET") # to use ISO 8601 (while lubridate uses US)
                        DFkPlot$Hours <- as.numeric(as.duration(DFkPlot$startTime - update(DFkPlot$startTime, hour = 0, minute = 0)), "hours")
                        DFkPlot$dayLabel <- paste(DFkPlot$Wday, " ", format.Date(DFkPlot$startDate, "%d"), ".", format.Date(DFkPlot$startDate, "%m"), ".", format.Date(DFkPlot$startDate, "%y"), ", W", DFkPlot$Week, sep = "")
                        DFkPlot$shortName <- substring(as.character(DFkPlot$Name), first = 1, last = 18)
                        # use dayPlots()
                        dayTr <- dayPlot(DFkPlot, plotDate = plotDate(), plotWidth = 16)
                        # --
                        
                        # - generate week plot - (NB there is also weekPlot2()) -
                        weekTr <- weekPlot(DFkPlot, plotDate = plotDate(), plotWidth = 5)
                        # or:
                        # weekTr <- weekPlot2(DFkPlot, plotDate = plotDate(), plotWidth = 5)
                        # --
                        
                        # - generate month plot -
                        monthTr <- monthPlot(DFkPlot, plotDate = plotDate(), plotWidth = 5)
                        # or:
                        # monthTr <- monthPlot2(DFkPlot, plotDate = plotDate(), plotWidth = 5)
                        # --
                        
                        rv$TrL <- list(Tr1 = dayTr, Tr2 = weekTr, Tr3 = monthTr)
                        rv$infoText <- "Calendar plots have been generated."
                }
                
        }
        
})
# --