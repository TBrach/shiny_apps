# - generate the Ibenerary plot -
observeEvent(input$plot, { 
        
        # reset infoText when button is pressed
        
        if(is.null(rv$DFi)){
                
                rv$Tr <- NULL
                rv$infoText <- "Your itinerary is empty, so there is nothing to plot."
                rv$PlotHeight <- 2.7
                
        } else {
                
                DFiPlot <- rv$DFi    #[,c("DateTime", "Date", "Time", "Category", "Name")]
                
                earliest <- min(DFiPlot$Start)
                latest <- max(DFiPlot$End)
                # daysCovered <- interval(earliest, latest)/days(1)
                daysCovered <- length(seq(date(earliest), date(latest), by = "day"))
                
                # # only allow plotting for itineraries below 3 weeks in length
                # if (daysCovered > 21){
                #         rv$infoText <- "Plot function is only allowed for itineraries of max 3 weeks"
                #         return()
                # }
                
                
                
                # - split multiple day entries using splitMultidayEntries()-
                
                DFiPlot$startDate <- format(DFiPlot$Start, "%Y-%m-%d")
                DFiPlot$startDate <- lubridate::parse_date_time(DFiPlot$startDate, orders = "ymd", tz = "CET")
                # 20200209: the other way caused trouble when ibenerary covered time change
                # not sure if necessary, but date(DFiPlot$Start) results in a class "Date" object, while this way it is still POSIXct
                DFiPlot$endDate <- format(DFiPlot$End, "%Y-%m-%d")
                DFiPlot$endDate <- lubridate::parse_date_time(DFiPlot$endDate, orders = "ymd", tz = "CET")
                #DFiPlot$endDate <- date(DFiPlot$End)
                
                if(any(DFiPlot$endDate > DFiPlot$startDate)){
                        DFiPlot <- splitMultidayEntries(DFiPlot)
                }
                # --
                
                # - split DFiPlot into list of data.frames that are unique for one category -
                DFiPlotList <- split(DFiPlot, DFiPlot$Category)
                # --
                
                
                # - Find Blocks of overlapping events using blockFinder (for each category separately) -
                DFiPlotList <- lapply(DFiPlotList, blockFinder)
                # --
                
                # - determine position and width of each element using positionAndWidthAssigner()
                DFiPlotList <- lapply(DFiPlotList, positionAndWidthAssigner)
                # --
                
                # - unite the list again into ond DFiPlot -
                DFiPlot <- do.call("rbind", DFiPlotList)
                # not really necessary but I want it here
                DFiPlot <- dplyr::arrange(DFiPlot, Start, Name)
                # --
                
                # - prepare for the facet plot -
                DFiPlot$wday <- lubridate::wday(DFiPlot$Start, label = TRUE)
                # DFiPlot$Week <- strftime(DFiPlot$Start, format = "%V", tz = "CET")
                DFiPlot$Hours <- as.numeric(as.duration(DFiPlot$Start - update(DFiPlot$Start, hour = 0, minute = 0)), "hours")
                # NB: Check: ISNT THERE A BUG WITH MULTI DAY ENTRIES?? HOW IS IT SOLVED IN CALENDAR MONTH THING
                
                DFiPlot$dayLabel <- paste(DFiPlot$wday, " (", DFiPlot$startDate, ")", sep = "")
                # DFiPlot$dayLabel <- paste(DFiPlot$wday, " (", DFiPlot$startDate, ", W", DFiPlot$Week, ")", sep = "")
                DFiPlot$shortName <- substring(as.character(DFiPlot$Name), first = 1, last = 22)
                # --
                
                # - start the facet plot -
                plotWidth = 5
                # for faceting you need all days covered by the itinerary, remember you already have earliest and latest timepoint
                daysCoveredDates <- seq(from = date(earliest), to = date(latest), by = "days")
                # you need them as factor levels
                daysCoveredDates <- paste(lubridate::wday(daysCoveredDates, label = TRUE), " (", daysCoveredDates, ")", sep = "")
                DFiPlot$dayLabel <- factor(DFiPlot$dayLabel, levels = daysCoveredDates, ordered = TRUE)
                DFiPlot$Category <- factor(DFiPlot$Category, levels = colorLevels, ordered = TRUE)
                
                DFiPlot$Duration <- as.numeric(DFiPlot$Duration)
                
                DFiPlot$Width <- DFiPlot$Width * plotWidth
                DFiPlot$startPosition <- DFiPlot$startPosition * plotWidth
                
                Tr <- ggplot(DFiPlot, aes(x = startPosition, y = Hours, label = shortName, fill = Category))
                Tr <- Tr +
                        geom_rect(mapping=aes(xmin = startPosition, xmax = startPosition + Width, ymin = Hours, ymax=Hours+Duration/60), alpha=0.75, col = cbPalette[1], size = 0.2) + 
                        # size sets the line width and is by default 0.5, I want thinner lines if at all, maybe remove the col at all, so no line
                        facet_grid(dayLabel ~ Category, drop = FALSE) +
                        geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 4) +
                        scale_x_continuous(limits = c(0, plotWidth), breaks = c(), labels = c()) +
                        scale_y_reverse(limits = c(24, 0), breaks = 23:0, expand = c(0,0)) +
                        scale_fill_manual("", values = colorValues) +
                        xlab("") +
                        ylab("") +
                        theme_bw() +
                        theme(legend.position = "none",
                              strip.background = element_rect(fill = cbPalette[7]),
                              strip.text.x = element_text(margin = margin(.09,0,.09,0, "cm")),
                              strip.text.y = element_text(margin = margin(0,.09,0,.09, "cm")),
                              strip.text = element_text(size = 10, colour = "white"))
                
                rv$Tr <- Tr
                rv$PlotHeight <- daysCovered*2.9 # again should be inches, so 4 days fill one DINA4 = 11,69 inches
                rv$infoText <- "Your itinerary has been plotted."
                
        }
        
})
# --