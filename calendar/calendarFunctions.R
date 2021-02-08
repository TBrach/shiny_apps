# Set the colors!:
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
colorLevels <- c("Faelles", "Iben", "Thorsten", "Maise", "Other")
colorValues <- c(Faelles = cbPalette[4], Iben = cbPalette[7], Thorsten = cbPalette[2], Maise = "#dccaec", Other = cbPalette[6]) # "#006633"

# - make a ggplot version of pal -
pal_ggplot <- function(col){
        col <- unname(col) # the naming could cause trouble if NA somehow
        n <- length(col)
        df <- data.frame(xstart = 0:(n-1)/n, xend = 1:n/n, ystart = 0, yend = 1, Fill = as.character(1:n))
        Tr <- ggplot(df)
        Tr <- Tr +
                geom_rect(aes(xmin = xstart, xmax = xend, ymin = ystart, ymax = yend, fill = Fill)) +
                scale_fill_manual(values = col) + 
                theme_minimal() +
                theme(legend.position = "none",
                      axis.text = element_blank(),
                      panel.grid = element_blank()) 
        Tr
        
}
# --

###############################
## splitMultidayEntries ##
###############################

splitMultidayEntries <- function(PlotDF){
        
        Indexes <- which(PlotDF$endDate > PlotDF$startDate)
        DFAll <- data.frame()
        for(i in Indexes){
                multiDayEntry <- PlotDF[i,]
                # Dates <- seq.Date(as.Date(multiDayEntry$startDate), as.Date(multiDayEntry$endDate), by = "day") # gave tz problems, always changing to UTC therefore replaced by
                Dates <- seq(ymd(multiDayEntry$startDate, tz = "CET"), ymd(multiDayEntry$endDate, tz = "CET"), by = 'days')
                DF <- multiDayEntry[rep(1, length(Dates)),]
                DF$startDate <- Dates
                DF$endDate[1:(nrow(DF)-1)] <- Dates[1:(nrow(DF)-1)]+days(1)
                DF$startTime[2:nrow(DF)] <- update(DF$startDate[2:nrow(DF)], hour = 0, minute = 0)
                DF$endTime[1:(nrow(DF)-1)] <- update(DF$endDate[1:(nrow(DF)-1)], hour = 0, minute = 0)
                DF$Duration <- as.numeric(as.duration(DF$endTime-DF$startTime), "minutes")
                # kill if Duration is 0 here!! NOT IN YET
                #.e.g. DF <- DF[DF$Duration!=0,]
                DFAll <- rbind(DFAll, DF)
        }
        PlotDF <- rbind(PlotDF, DFAll)
        PlotDF <- PlotDF[-Indexes,]
        # PlotDF <- dplyr::arrange(PlotDF, startTime, Name, Urgency)
        PlotDF <- dplyr::arrange(PlotDF, startTime, Name, Color)
}




###############################
## blockFinder ##
###############################
# NB: function should only be called when PlotDF has at least one entry!
blockFinder <- function(PlotDF){
        if(nrow(PlotDF) > 1){
                DFkBloFind <- data.frame(Time = c(PlotDF$startTime, PlotDF$endTime), Type = c(rep("S", nrow(PlotDF)), rep("E", nrow(PlotDF))), Id = as.integer(rep(rownames(PlotDF),2))) #NB: changes the tz to CEST!!
                #NB: In the following it is important that in case of equal time between an ending and starting event, the ending event comes first, therefore Type is included in the order
                DFkBloFind <- DFkBloFind[order(DFkBloFind$Time, DFkBloFind$Type),]
                DFkBloFind$Adds <- DFkBloFind$Id
                DFkBloFind$Adds[DFkBloFind$Type == "E"] <- -1*DFkBloFind$Adds[DFkBloFind$Type == "E"]
                DFkBloFind$cumSumAdds <- cumsum(DFkBloFind$Adds)
                # every time there is a zero a block ends
                DFkBloFind <- DFkBloFind[DFkBloFind$Type == "E",]
                # constructing a vector where you add 1 after each 0 in DFkBloFind$cumSumAdds
                DFkBloFind$BlockNo <- cumsum(c(1, DFkBloFind$cumSumAdds[1:(nrow(DFkBloFind)-1)]) == 0)
                rleV <- rle(DFkBloFind$BlockNo)
                DFkBloFind$BlockSizes <- rep(rleV$lengths, rleV$lengths)
                DFkBloFind$BlockId <- 0
                DFkBloFind$BlockId[DFkBloFind$BlockSizes != 1] <- rep(order(unique(DFkBloFind$BlockNo[DFkBloFind$BlockSizes != 1])), times = rle(DFkBloFind$BlockNo[DFkBloFind$BlockSizes != 1])[[1]])
                
                PlotDF$blockId <- DFkBloFind$BlockId
                # PlotDF$blockSize <- DFkBloFind$BlockSizes # probably not needed
        } else {
                PlotDF$blockId <- 0
        }
        
        PlotDF
}


###############################
## positionAndWidthAssigner ##
###############################
# you do so by looping through the blocks, assigning each element of a block a slot (which also finds the overall numbers of
# slots). You then find for each elelment of a block the slot of the right side neighbor. 
# Then the startPosition is just (slot of the element - 1) / number of slots (e.g. 3 slots, element is on 2, it should start at 0.33).
# The width is 

positionAndWidthAssigner <- function(PlotDF){
        PlotDF$startPosition <- 0
        PlotDF$Width <- 1
        
        if(any(PlotDF$blockId != 0)){ # if there are no overlapping events, i.e. blocks, this code is skipped
                for(BloId in unique(PlotDF$blockId[PlotDF$blockId>0])){
                        #BloId <- 1
                        # Pick the Block and order Starts and Ends of events
                        DFkBlock <- PlotDF[PlotDF$blockId == BloId,]
                        DFkBlock <- data.frame(Time = c(DFkBlock$startTime, DFkBlock$endTime), Type = c(rep("S", nrow(DFkBlock)), rep("E", nrow(DFkBlock))), Id = as.integer(rep(rownames(DFkBlock),2)))
                        DFkBlock <- DFkBlock[order(DFkBlock$Time, DFkBlock$Type),]
                        # = assign to each entry the slot and thus also find the total number of slots needed for the block =
                        DFkBlock$Slot <- 0
                        DFkBlock$Slot[1] <- 1
                        for(i in 2:nrow(DFkBlock)){
                                if(DFkBlock$Type[i] == "S"){
                                        # check if a slot is free, which is the case when the number the slot occurs is even
                                        SlotOccurs <- sapply(unique(DFkBlock$Slot[1:(i-1)]), function(x){sum(DFkBlock$Slot[1:(i-1)] == x)})
                                        if(any(SlotOccurs %% 2 == 0)){
                                                # if so put the new element in the smallest free slot
                                                DFkBlock$Slot[i] <- unique(DFkBlock$Slot[1:(i-1)])[which(SlotOccurs %% 2 == 0)[1]] 
                                        } else { # open a new slot
                                                DFkBlock$Slot[i] <- max(DFkBlock$Slot[1:(i-1)]) + 1
                                        }
                                        
                                } else if (DFkBlock$Type[i] == "E"){
                                        DFkBlock$Slot[i] <- DFkBlock$Slot[which(DFkBlock$Id == DFkBlock$Id[i])[1]]
                                }
                        }
                        rm(i)
                        # ==
                        # = then find for each entry the right hand neighbor =
                        DFkBlock$Neighbor <- max(DFkBlock$Slot)+1 # makes it easy to calculate the width of the events later
                        for(i in unique(DFkBlock$Slot)){
                                Indexes <- which(DFkBlock$Slot == i) # NB: always an even number of indixes
                                for(e in 1:(length(Indexes)/2)){
                                        OverlappingSlots <- DFkBlock$Slot[Indexes[2*e-1]:Indexes[2*e]] # Includes the own slot
                                        if(any(OverlappingSlots > i)){
                                                DFkBlock$Neighbor[c(Indexes[2*e-1], Indexes[2*e])] <- min(OverlappingSlots[OverlappingSlots > i])
                                        }
                                }
                        }
                        # ==
                        # == calculate startPosition and Width and put them into PlotDF ==
                        DFkBlock <- DFkBlock[DFkBlock$Type == "S",]
                        PlotDF$startPosition[as.numeric(rownames(PlotDF)) %in% DFkBlock$Id] <- (DFkBlock$Slot-1)/max(DFkBlock$Slot)
                        PlotDF$Width[as.numeric(rownames(PlotDF)) %in% DFkBlock$Id] <- (DFkBlock$Neighbor-DFkBlock$Slot)/max(DFkBlock$Slot)
                }
        }
        PlotDF
        
}

###############################
## dayPlot ##
###############################



dayPlot <- function(PlotDF, plotDate, plotWidth = 10) {
        
        DFkDayPlot <- PlotDF[PlotDF$startDate == plotDate,]
        if(nrow(DFkDayPlot) != 0){
                DFkDayPlot$Width <- DFkDayPlot$Width * plotWidth
                DFkDayPlot$startPosition <- DFkDayPlot$startPosition * plotWidth 
                DFkDayPlot$Color <- factor(DFkDayPlot$Color, levels = colorLevels, ordered = TRUE)
                Tr <- ggplot(DFkDayPlot, aes(x = startPosition, y = Hours, label = shortName, fill = Color))
                Tr <- Tr + 
                        geom_rect(mapping=aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), alpha=0.85) + 
                        geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 3) + # https://stackoverflow.com/questions/17311917/ggplot2-the-unit-of-size
                        scale_fill_manual("", values = colorValues) +
                        scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
                        scale_y_reverse(limits = c(24, 0), breaks = seq(from = 22, to = 0, by = -2), expand = c(0,0)) +
                        facet_grid(facets = .~dayLabel, drop = FALSE)+
                        xlab("") +
                        ylab("") +
                        theme_bw() +
                        theme(legend.position = "none",
                              strip.background = element_rect(fill="#660033"),
                              strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
                              strip.text.y = element_text(margin = margin(0,.08,0,.08, "cm")),
                              strip.text = element_text(size = 10, colour="white"))
                ymax <- ceiling(max(DFkDayPlot$Hours+DFkDayPlot$Duration/60)) + .5
                if (ymax > 24) { ymax <- 24}
                ymin <- floor(min(DFkDayPlot$Hours)) -.5
                if (ymin < 0) { ymin <- 0} 
                Tr <- Tr + coord_cartesian(ylim = c(ymax, ymin)) 
        } else {
                Tr <- dayPlotMock(plotDate, plotWidth = plotWidth)
        }
        
        Tr
}


###############################
## dayPlotMock ##
###############################
# function is called when DFkPlot contains no events

dayPlotMock <- function(plotDate, plotWidth = 10) {
 
        DFkDayPlotMock <- data.frame(Wday = lubridate::wday(plotDate, label = TRUE), Week = strftime(plotDate, format = "%V", tz = "CET"), startPosition = 0,
                                     Hours = 0, shortName = "")
        DFkDayPlotMock$dayLabel <- paste(DFkDayPlotMock$Wday, " ", format.Date(plotDate, "%d"), ".", format.Date(plotDate, "%m"), ".", format.Date(plotDate, "%y"), ", W", DFkDayPlotMock$Week, sep = "")
        Tr <- ggplot(DFkDayPlotMock, aes(x = startPosition, y = Hours, label = shortName))
        Tr <- Tr + 
                geom_blank() + 
                scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
                scale_y_reverse(limits = c(24, 0), breaks = seq(from = 22, to = 0, by = -2), expand = c(0,0)) +
                facet_grid(.~dayLabel, drop = FALSE)+
                xlab("") +
                ylab("") +
                theme_bw() +
                theme(legend.position = "none",
                      strip.background = element_rect(fill="#660033"),
                      strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
                      strip.text.y = element_text(margin = margin(0,.08,0,.08, "cm")),
                      strip.text = element_text(size = 10, colour="white"))
        
}


###############################
## weekPlot ##
###############################


weekPlot <- function(PlotDF, plotDate, plotWidth = 5) {
        
        # remember: PlotDF is already restricted to 1 Month plus 2 weeks, so no trouble with same week in different years
        DFkWeekPlot <- PlotDF[PlotDF$Week == strftime(plotDate, format = "%V", tz = "CET"),] 
        
        if(nrow(DFkWeekPlot) != 0){
                # you have to get the dayLabel and weekLabel factors right for correct faceting =
                # the weekLabel should only have one factor level
                DFkWeekPlot$weekLabel <- factor(paste("W ", DFkWeekPlot$Week, sep = "")) # to make sure only the 1 level remains
                DFkWeekPlot$dayLabel <- paste(DFkWeekPlot$Wday, " ", format.Date(DFkWeekPlot$startDate, "%d"), ".", format.Date(DFkWeekPlot$startDate, "%m"), sep = "")
                # the factor levels of the dayLabel should go from the first day of that week to the last
                # this is tricky: here my trick 
                # SurrounderDays <- seq.Date(from = date(plotDate-days(8)), to = date(plotDate+days(8)), by = "day") # would change tz again to UTC
                SurrounderDays <- seq(ymd(plotDate-days(8)), ymd(plotDate+days(8)), by = 'day') # also changes tz to UTC therefore
                SurrounderDays <- ymd(SurrounderDays, tz = "CET")
                SurrounderDays <- SurrounderDays[strftime(SurrounderDays, format = "%V", tz = "CET") == strftime(plotDate, format = "%V", tz = "CET")]
                SurrounderDays <- paste(wday(SurrounderDays, label = TRUE), " ", format.Date(SurrounderDays, "%d"), ".", format.Date(SurrounderDays, "%m"), sep = "")
                DFkWeekPlot$dayLabel <- factor(DFkWeekPlot$dayLabel, levels = SurrounderDays, ordered = TRUE)
                DFkWeekPlot$Width <- DFkWeekPlot$Width * plotWidth
                DFkWeekPlot$startPosition <- DFkWeekPlot$startPosition * plotWidth 
                # DFkWeekPlot$Color <- factor(DFkWeekPlot$Color, levels = colorLevels, ordered = TRUE)
                # add mock data.frame to mark the background of the plotDate day, see https://stackoverflow.com/questions/9847559/conditionally-change-panel-background-with-facet-grid
                dayIndicatorDF <- data.frame(startPosition = 0, Hours = 0, shortName = "",
                                             weekLabel = DFkWeekPlot$weekLabel[1], dayLabel = paste(wday(plotDate, label = T), " ", format.Date(plotDate, "%d"), ".", format.Date(plotDate, "%m"), sep = ""))
                dayIndicatorDF$dayLabel <- factor(dayIndicatorDF$dayLabel, levels = SurrounderDays, ordered = TRUE)
                
                Tr <- ggplot(DFkWeekPlot, aes(x = startPosition, y = Hours, label = shortName))
                Tr <- Tr +
                        facet_grid(facets = weekLabel~dayLabel, drop = FALSE) +
                        geom_rect(data = dayIndicatorDF, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, alpha = 0.3, fill = "lightgray") +
                        geom_rect(mapping=aes(fill = Color, xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), alpha=1) + 
                        geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "white", size = 3) +
                        # geom_text_repel(nudge_y = 0, col = "black", size = 3, segment.size = NA, box.padding = 0, xlim = c(0, Inf)) +
                        scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
                        scale_y_reverse(limits = c(24, 0), breaks = seq(from = 22, to = 0, by = -2), expand = c(0,0)) +
                        scale_fill_manual("", values = colorValues) +
                        xlab("") +
                        ylab("") +
                        theme_bw() +
                        theme(legend.position = "none",
                              strip.background = element_rect(fill="#660033"),
                              strip.text.x = element_text(margin = margin(.06,0,.06,0, "cm")),
                              strip.text.y = element_text(margin = margin(0,.06,0,.06, "cm")),
                              strip.text = element_text(size = 8, colour="white"))
                
        } else {
                Tr <- weekPlotMock(plotDate, plotWidth = plotWidth)
        }
        
        Tr
}

###############################
## weekPlotMock ##
###############################


weekPlotMock <- function(plotDate, plotWidth = 5) {
        
        DFkWeekPlotMock <- data.frame(Wday = lubridate::wday(plotDate, label = TRUE), Week = strftime(plotDate, format = "%V", tz = "CET"), startPosition = 0,
                                      Hours = 0, shortName = "")
        DFkWeekPlotMock$weekLabel <- factor(paste("W ", DFkWeekPlotMock$Week, sep = "")) # to make sure only the 1 level remains
        DFkWeekPlotMock$dayLabel <- paste(DFkWeekPlotMock$Wday, " ", format.Date(plotDate, "%d"), ".", format.Date(plotDate, "%m"), sep = "")
        SurrounderDays <- seq(ymd(plotDate-days(8)), ymd(plotDate+days(8)), by = 'day') # also changes tz to UTC therefore
        SurrounderDays <- ymd(SurrounderDays, tz = "CET")
        SurrounderDays <- SurrounderDays[strftime(SurrounderDays, format = "%V", tz = "CET") == strftime(plotDate, format = "%V", tz = "CET")]
        SurrounderDays <- paste(wday(SurrounderDays, label = TRUE), " ", format.Date(SurrounderDays, "%d"), ".", format.Date(SurrounderDays, "%m"), sep = "")
        DFkWeekPlotMock$dayLabel <- factor(DFkWeekPlotMock$dayLabel, levels = SurrounderDays, ordered = TRUE)
        
        Tr <- ggplot(DFkWeekPlotMock, aes(x = startPosition, y = Hours, label = shortName))
        Tr <- Tr + 
                geom_rect(fill = "#999999", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, alpha = 0.3) +
                scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
                scale_y_reverse(limits = c(24, 0), breaks = seq(from = 22, to = 0, by = -2), expand = c(0,0)) +
                facet_grid(facets = weekLabel~dayLabel, drop = FALSE)+
                xlab("") +
                ylab("") +
                theme_bw() +
                theme(legend.position = "none",
                      strip.background = element_rect(fill="#660033"),
                      strip.text.x = element_text(margin = margin(.06,0,.06,0, "cm")),
                      strip.text.y = element_text(margin = margin(0,.06,0,.06, "cm")),
                      strip.text = element_text(size = 8, colour="white"))
}






###############################
## monthPlot ##
###############################
# plots all days that fall into the ISO 8601 weeks of the month of the plotDate
# Attention: that can give a different number of rows 5 or 6,

monthPlot <- function(PlotDF, plotDate, plotWidth = 5){
        
        # == select the days that fall into the weeks that fall into the plotDate month ==
        # NB: see actually monthPlot2, there is a faster version to get the MonthDays (check with microbenchmark)
        FirstWeek <- strftime(update(plotDate, day = 1), format = "%V", tz = "CET")
        LastWeek <- strftime(update(plotDate, day = 1) + months(1) - days(1), format = "%V", tz = "CET") 
        MonthDays <- seq(from = ymd(update(plotDate, day = 1) - days(8)), to = ymd(update(plotDate, day = 1) + months(1) + days(7)), by = "day")
        MonthDays <- ymd(MonthDays, tz = "CET")
        FirstDay <- which(strftime(MonthDays, format = "%V", tz = "CET") == FirstWeek)[1]
        LastDay <- which(strftime(MonthDays, format = "%V", tz = "CET") == LastWeek)[length(which(strftime(MonthDays, format = "%V", tz = "CET") == LastWeek))]
        MonthDays <- MonthDays[FirstDay:LastDay]
        
        DFkMonthPlot <- PlotDF[PlotDF$startDate %in% MonthDays,]
        # ==== 
        
        if(nrow(DFkMonthPlot) != 0){
                # == adjust factor levels for plot ==
                # NB: for ISO 8601 used now for the week, each week starts at a Monday!
                # however lubridate:wkday uses US convention starting weeks on Sundays, therefore
                
                DFkMonthPlot$Wday <- factor(DFkMonthPlot$Wday, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"), ordered = T)        
                
                monthWeeksAll <- strftime(MonthDays, format = "%V", tz = "CET")
                MondayIndexes <- !duplicated(monthWeeksAll) 
                monthWeeks <- monthWeeksAll[MondayIndexes]
                monthYearsAll <- year(MonthDays)
                monthYears <- monthYearsAll[MondayIndexes]
                weekLabelLevels <- paste("W ", monthWeeks, sep = "")
                
                DFkMonthPlot$weekLabel <- factor(paste("W ", monthWeeks[match(DFkMonthPlot$Week, monthWeeks)], sep = ""), levels = weekLabelLevels, ordered = TRUE)
                DFkMonthPlot$Color <- factor(DFkMonthPlot$Color, levels = colorLevels, ordered = TRUE)
                # dayLabel will be put into an extra data frame and will be used in plot with geom_label
                dayLabelLevels <- paste(format.Date(MonthDays, "%d"), format.Date(MonthDays, "%m"), sep = ".")
                DFkMonthPlotLabel <- data.frame(Label = dayLabelLevels, Hours = 22, startPosition = 0.87, Wday = wday(MonthDays, label = TRUE),
                                                Week = strftime(MonthDays, format = "%V", tz = "CET"))
                DFkMonthPlotLabel$weekLabel = factor(paste("W ", monthWeeks[match(DFkMonthPlotLabel$Week, monthWeeks)], sep = ""), levels = weekLabelLevels, ordered = TRUE)
                DFkMonthPlotLabel$Wday <- factor(DFkMonthPlotLabel$Wday, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"), ordered = T)
                # ====
                DFkMonthPlot$Width <- DFkMonthPlot$Width * plotWidth
                DFkMonthPlot$startPosition <- DFkMonthPlot$startPosition * plotWidth
                DFkMonthPlotLabel$startPosition <- DFkMonthPlotLabel$startPosition * plotWidth
                # add mock data.frame to mark the background of the plotDate day, see https://stackoverflow.com/questions/9847559/conditionally-change-panel-background-with-facet-grid
                dayIndicatorDF <- data.frame(startPosition = 0, Hours = 0, shortName = "",
                                             Wday = wday(plotDate, label = T),
                                             weekLabel = paste("W ", monthWeeks[match(strftime(plotDate, format = "%V", tz = "CET"), monthWeeks)], sep = ""))
                
                Tr <- ggplot(DFkMonthPlot, aes(x = startPosition, y = Hours, label = shortName))
                Tr <- Tr +
                        geom_rect(data = dayIndicatorDF, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, fill = "#999999", alpha = 0.3) +
                        geom_rect(mapping = aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60, fill = Color), alpha=0.85) + 
                        geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 2.5) +
                        # geom_text_repel(nudge_y = 0, col = "black", size = 2.5, segment.size = NA, box.padding = 0) +
                        scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
                        scale_y_reverse(limits = c(24, 0), breaks = c(24, 18, 12, 6), expand = c(0,0)) +
                        scale_fill_manual("", values = colorValues) +
                        facet_grid(facets = weekLabel ~ Wday, drop = FALSE)+
                        #facet_wrap(weekLabel~Wday, ncol = 7, drop = FALSE)
                        xlab("") +
                        ylab("") +
                        # geom_text_repel(data = DFkMonthPlotLabel, aes(label = Label), col = "#660033", size = 2) +
                        geom_text(data = DFkMonthPlotLabel, aes(label = Label), col = "#660033", size = 2.5) +
                        #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
                        theme_bw() +
                        theme(legend.position = "none",
                              strip.background = element_rect(fill="#660033"),
                              strip.text.x = element_text(margin = margin(.06,0,.06,0, "cm")),
                              strip.text.y = element_text(margin = margin(0,.06,0,.06, "cm")),
                              strip.text = element_text(size = 8, colour="white"))
        } else {
                
                Tr <- monthPlotMock(plotDate, plotWidth = plotWidth)
        
        }
}

###############################
## monthPlotMock ##
###############################

monthPlotMock <- function(plotDate, plotWidth = 5){
        
        FirstWeek <- strftime(update(plotDate, day = 1), format = "%V", tz = "CET")
        LastWeek <- strftime(update(plotDate, day = 1) + months(1) - days(1), format = "%V", tz = "CET") 
        MonthDays <- seq(from = ymd(update(plotDate, day = 1) - days(8)), to = ymd(update(plotDate, day = 1) + months(1) + days(7)), by = "day")
        MonthDays <- ymd(MonthDays, tz = "CET")
        FirstDay <- which(strftime(MonthDays, format = "%V", tz = "CET") == FirstWeek)[1]
        LastDay <- which(strftime(MonthDays, format = "%V", tz = "CET") == LastWeek)[length(which(strftime(MonthDays, format = "%V", tz = "CET") == LastWeek))]
        MonthDays <- MonthDays[FirstDay:LastDay]

        monthWeeksAll <- strftime(MonthDays, format = "%V", tz = "CET")
        MondayIndexes <- !duplicated(monthWeeksAll) 
        monthWeeks <- monthWeeksAll[MondayIndexes]
        monthYearsAll <- year(MonthDays)
        monthYears <- monthYearsAll[MondayIndexes]
        weekLabelLevels <- paste("W", monthWeeks, " ", monthYears, sep = "")
        
        dayLabelLevels <- paste(format.Date(MonthDays, "%d"), format.Date(MonthDays, "%m"), sep = ".")
        DFkMonthPlotLabel <- data.frame(Label = dayLabelLevels, Hours = 22, startPosition = 0.87, Wday = wday(MonthDays, label = TRUE),
                                        Week = strftime(MonthDays, format = "%V", tz = "CET"))
        DFkMonthPlotLabel$weekLabel = factor(paste("W", monthWeeks[match(DFkMonthPlotLabel$Week, monthWeeks)], " ", monthYears[match(DFkMonthPlotLabel$Week, monthWeeks)], sep = ""), levels = weekLabelLevels, ordered = TRUE)
        DFkMonthPlotLabel$Wday <- factor(DFkMonthPlotLabel$Wday, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"), ordered = T)
        
        DFkMonthPlotLabel$startPosition <- DFkMonthPlotLabel$startPosition * plotWidth
        
        dayIndicatorDF <- data.frame(startPosition = 0, Hours = 0, Label = "",
                                     Wday = wday(plotDate, label = T),
                                     weekLabel = paste("W", monthWeeks[match(strftime(plotDate, format = "%V", tz = "CET"), monthWeeks)], " ", monthYears[match(strftime(plotDate, format = "%V", tz = "CET"), monthWeeks)], sep = ""))
        
        Tr <- ggplot(DFkMonthPlotLabel, aes(x = startPosition, y = Hours, label = Label))
        Tr <- Tr + 
                # geom_blank()+
                geom_rect(data = dayIndicatorDF, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, fill = "#999999", alpha = 0.3) +
                scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
                scale_y_reverse(limits = c(24, 0), breaks = c(22, 18, 12, 6), expand = c(0,0)) +
                facet_grid(facets = weekLabel~Wday, drop = FALSE)+
                #facet_wrap(weekLabel~Wday, ncol = 7, drop = FALSE)
                xlab("") +
                ylab("") +
                geom_text(col = "#660033", size = 2.5) +
                #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
                theme_bw() +
                theme(legend.position = "none",
                      strip.background = element_rect(fill="#660033"),
                      strip.text.x = element_text(margin = margin(.06,0,.06,0, "cm")),
                      strip.text.y = element_text(margin = margin(0,.06,0,.06, "cm")),
                      strip.text = element_text(size = 8, colour="white"))
        
}


######################################################################################






















####### older currently not used functions that are also not up to date
# ###############################
# ## weekPlot2 ##
# ###############################
# 
# # produces a plot where the plotDate is always in the middle, i.e. on position 4 of the 7 days
# # since this can spread over two different ISO 8601 weeks, the week label is in the header
# 
# weekPlot2 <- function(PlotDF, plotDate, plotWidth = 5) {
#         
#         WeekDays <- seq(from = plotDate-days(3), to = plotDate+days(3), by = "days")
#         
#         DFkWeekPlot <- PlotDF[PlotDF$startDate %in% WeekDays,] 
#         
#         if(nrow(DFkWeekPlot) != 0){
#                 
#                 DFkWeekPlot$dayLabel <- factor(paste(DFkWeekPlot$Wday, " ", DFkWeekPlot$startDate, '; W', DFkWeekPlot$Week, sep = ""), 
#                                                levels = paste(wday(WeekDays, label = T), " ", WeekDays, '; W', strftime(WeekDays, format = "%V", tz = "CET"), sep = ""),
#                                                ordered = T)
#                 
#                 DFkWeekPlot$Width <- DFkWeekPlot$Width * plotWidth
#                 DFkWeekPlot$startPosition <- DFkWeekPlot$startPosition * plotWidth 
#                 DFkWeekPlot$Color <- factor(DFkWeekPlot$Color, levels = colorLevels, ordered = TRUE)
#                 # add mock data.frame to mark the background of the plotDate day, see https://stackoverflow.com/questions/9847559/conditionally-change-panel-background-with-facet-grid
#                 dayIndicatorDF <- data.frame(startPosition = 0, Hours = 0, shortName = "", Color = "background",
#                                              dayLabel = paste(wday(plotDate, label = T), " ", plotDate, "; W", strftime(plotDate, format = "%V", tz = "CET"), sep = ""))
#                 
#                 Tr <- ggplot(DFkWeekPlot, aes(x = startPosition, y = Hours, label = shortName, fill = Color))
#                 Tr <- Tr + 
#                         geom_rect(data = dayIndicatorDF, xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, alpha = 0.3) +
#                         geom_rect(mapping=aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), alpha=0.75) + 
#                         geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 4) +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = 23:0, expand = c(0,0)) +
#                         scale_fill_manual("", values = colorValues) +
#                         facet_grid(facets = ~dayLabel, drop = FALSE)+
#                         xlab("") +
#                         ylab("") +
#                         theme_bw() +
#                         theme(legend.position = "none",
#                               strip.background = element_rect(fill="#660033"), 
#                               strip.text = element_text(size=10, colour="white"))
#                 
#         } else {
#                 Tr <- weekPlot2Mock(plotDate, plotWidth = plotWidth)
#         }
#         
#         Tr
# }
# 
# 
# ###############################
# ## weekPlot2Mock ##
# ###############################
# 
# weekPlot2Mock <- function(plotDate, plotWidth = 5) {
#         
#         DFkWeekPlotMock <- data.frame(Wday = lubridate::wday(plotDate, label = TRUE), Week = strftime(plotDate, format = "%V", tz = "CET"), 
#                                       startDate = plotDate, startPosition = 0,
#                                       Hours = 0, shortName = "")
#         
#         WeekDays <- seq(from = plotDate-days(3), to = plotDate+days(3), by = "days")
#         
#         DFkWeekPlotMock$dayLabel <- factor(paste(DFkWeekPlotMock$Wday, " ", DFkWeekPlotMock$startDate, '; W', DFkWeekPlotMock$Week, sep = ""), 
#                                            levels = paste(wday(WeekDays, label = T), " ", WeekDays, '; W', strftime(WeekDays, format = "%V", tz = "CET"), sep = ""),
#                                            ordered = T)
#         Tr <- ggplot(DFkWeekPlotMock, aes(x = startPosition, y = Hours, label = shortName))
#         Tr <- Tr + 
#                 geom_rect(fill = "#999999", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf, alpha = 0.3) +
#                 scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                 scale_y_reverse(limits = c(24, 0), breaks = 23:0, expand = c(0,0)) +
#                 facet_grid(facets = ~dayLabel, drop = FALSE)+
#                 xlab("") +
#                 ylab("") +
#                 theme_bw() +
#                 theme(strip.background = element_rect(fill="#660033"), 
#                       strip.text = element_text(size=10, colour="white"))
#         
# }



###############################
## monthPlot2 ##
################################ 
# # THIS FUNCTION IS NOT YET DONE
# # I would like to have the dayLabels as column labels, but with column labels in each row, e.g. Mon 2.Jan
# # But then I would like to have thw Week labels as row labels just as in monthPlot
# # However, facet_grid does not allow different column labels in different rows (i.e. no ncol)
# # and facet_wrap does not allow row labels
# # so I could only add the Week labels to the dayLabels and use facet_wrap, which on top seems much slower than
# # facet grid
# 
# # so the function has to be continued on GET RID OF ALL date() functions since they change tz to UTC!
#  
# monthPlot2 <- function(PlotDF, plotDate, plotWidth = 5){
#         
#         # == find the surrounding dates of the plotMonth, i.e. the Mo before, and the Sunday after ==
#         # microbenchmark({ # was slightly faster than the code in monthPlot
#         First <- update(plotDate, day = 1)
#         if(wday(First)>1){
#                 Monday <- date(First - days(wday(First)-2))
#         } else {
#                 Monday <- date(First - days(6))
#         }
#         Last <- update(plotDate, day = 1) + months(1) - days(1)
#         
#         if(wday(Last)>1){
#                 Sunday <- date(Last + days(8-wday(Last)))
#         } else {
#                 Sunday <- Last
#         }
#         MonthDays <- seq.Date(from = date(Monday), to = date(Sunday), by = "days")
#         # })
#         DFkMonthPlot <- PlotDF[PlotDF$startDate %in% MonthDays,] 
#         # ====
#         
#         if(nrow(DFkMonthPlot) != 0){
#                 # generate dayLabels (colum labels)
#                 dayLabelLevels <- paste(wday(MonthDays, label = TRUE), paste(day(MonthDays), month(MonthDays, label = TRUE), sep = "."), sep = " ")
#                 DFkMonthPlot$dayLabel <- factor(paste(DFkMonthPlot$Wday, paste(day(DFkMonthPlot$startDate), month(DFkMonthPlot$startDate, label = TRUE), sep = "."), sep = " "),
#                                                 levels = dayLabelLevels, ordered = T)
#                 
#                 # generate weekLabels
#                 monthWeeksAll <- strftime(MonthDays, format = "%V", tz = "CET")
#                 MondayIndexes <- !duplicated(monthWeeksAll) 
#                 monthWeeks <- monthWeeksAll[MondayIndexes]
#                 monthYearsAll <- year(MonthDays)
#                 monthYears <- monthYearsAll[MondayIndexes]
#                 weekLabelLevels <- paste("Week ", monthWeeks, " (", monthYears, ")", sep = "")
#                 DFkMonthPlot$weekLabel <- factor(paste("Week ", monthWeeks[match(DFkMonthPlot$Week, monthWeeks)], " (", monthYears[match(DFkMonthPlot$Week, monthWeeks)], ")", sep = ""), levels = weekLabelLevels, ordered = TRUE)
#                 
#                 # set color factor levels
#                 DFkMonthPlot$Color <- factor(DFkMonthPlot$Color, levels = colorLevels, ordered = TRUE)
#                 
#                 DFkMonthPlot$Width <- DFkMonthPlot$Width * plotWidth
#                 DFkMonthPlot$startPosition <- DFkMonthPlot$startPosition * plotWidth
#                 
#                 Tr <- ggplot(DFkMonthPlot, aes(x = startPosition, y = Hours, label = shortName, fill = Color))
#                 Tr <- Tr + 
#                         geom_rect(mapping=aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), alpha=0.5) + 
#                         geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 3) +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = c(23, 18, 12, 6), expand = c(0,0)) +
#                         scale_fill_manual("", values = colorLevels) +
#                         # facet_grid(facets = weekLabel ~ dayLabel, drop = FALSE)+
#                         facet_wrap(~ dayLabel, ncol = 7, drop = FALSE) +
#                         xlab("") +
#                         ylab("") +
#                         #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
#                         theme_bw() +
#                         theme(legend.position = "none",
#                               strip.background = element_rect(fill="#660033"), 
#                               strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
#                               strip.text = element_text(size=8, colour="white"))
#                 
#         } else {
#                 
#         }
# }






















########################### obsolete functions ######################################

####################
### old weekPlot2 ###
#####################

# weekPlot2 <- function(PlotDF, plotDate, plotWidth = 5) {
#         
#         if(wday(plotDate)>1){
#                 MotoSuPlotDate <- seq.Date(from = date(plotDate - days(wday(plotDate)-2)), to = date(plotDate + days(8-wday(plotDate))), by = "days")
#         } else {
#                 MotoSuPlotDate <- seq.Date(from = date(plotDate - days(6)), to = date(plotDate), by = "days")
#         }
#         
#         DFkWeekPlot <- PlotDF[PlotDF$startDate %in% MotoSuPlotDate,] 
#         
#         if(nrow(DFkWeekPlot) != 0){
#                 
#                 DFkWeekPlot$dayLabel <- factor(paste(DFkWeekPlot$Wday, " ", DFkWeekPlot$startDate, '; W', DFkWeekPlot$Week, sep = ""), 
#                                                levels = paste(wday(MotoSuPlotDate, label = T), " ", MotoSuPlotDate, '; W', week(MotoSuPlotDate), sep = ""),
#                                                ordered = T)
#                 
#                 DFkWeekPlot$Width <- DFkWeekPlot$Width * plotWidth
#                 DFkWeekPlot$startPosition <- DFkWeekPlot$startPosition * plotWidth 
#                 DFkWeekPlot$Color <- factor(DFkWeekPlot$Color, levels = c("gray", "Thorsten", "lightBlue","Faelles", "yellow", "blue", "Iben", "pink"), ordered = TRUE)
#                 Tr <- ggplot(DFkWeekPlot, aes(x = startPosition, y = Hours, label = shortName, fill = Color))
#                 Tr <- Tr + 
#                         geom_rect(mapping=aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), alpha=0.65) + 
#                         geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 3) +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = 23:0, expand = c(0,0)) +
#                         scale_fill_manual("", values = c(gray = cbPalette[1], Thorsten = cbPalette[2], lightBlue = cbPalette[3], Faelles = cbPalette[4],
#                                                          yellow = cbPalette[5], blue = cbPalette[6], Iben = cbPalette[7], pink = cbPalette[8])) +
#                         facet_grid(facets = ~dayLabel, drop = FALSE)+
#                         xlab("") +
#                         ylab("") +
#                         # theme_bw() +
#                         theme(legend.position = "none",
#                               strip.background = element_rect(fill="#660033"), 
#                               strip.text = element_text(size=8, colour="white"))
#                 
#         } else {
#                 DFkWeekPlotMock <- data.frame(Wday = lubridate::wday(plotDate, label = TRUE), Week = lubridate::week(plotDate), 
#                                               startDate = date(plotDate), startPosition = 0,
#                                               Hours = 0, shortName = "")
#                 DFkWeekPlotMock$dayLabel <- factor(paste(DFkWeekPlotMock$Wday, " ", DFkWeekPlotMock$startDate, '; W', DFkWeekPlotMock$Week, sep = ""), 
#                                                    levels = paste(wday(MotoSuPlotDate, label = T), " ", MotoSuPlotDate, '; W', week(MotoSuPlotDate), sep = ""),
#                                                    ordered = T)
#                 Tr <- ggplot(DFkWeekPlotMock, aes(x = startPosition, y = Hours, label = shortName))
#                 Tr <- Tr + 
#                         geom_blank() + 
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = 23:0, expand = c(0,0)) +
#                         facet_grid(facets = ~dayLabel, drop = FALSE)+
#                         xlab("") +
#                         ylab("") +
#                         theme(strip.background = element_rect(fill="#660033"), 
#                               strip.text = element_text(size=8, colour="white"))
#         }
#         
#         Tr
# }


# monthPlot <- function(PlotDF, plotDate, plotWidth = 5){
#         
#         # == select the days that fall into the weeks that fall into the plotDate month ==
#         FirstWeek <- strftime(update(plotDate, day = 1), format = "%V")
#         LastWeek <- strftime(update(plotDate, day = 1) + months(1) - days(1), format = "%V") 
#         MonthDays <- seq.Date(from = date(update(plotDate, day = 1)-days(8)), to = date(update(plotDate, day = 1) + months(1) + days(7)), by = "day" )
#         FirstDay <- which(strftime(MonthDays, format = "%V") == FirstWeek)[1]
#         LastDay <- which(strftime(MonthDays, format = "%V") == LastWeek)[length(which(strftime(MonthDays, format = "%V") == LastWeek))]
#         MonthDays <- MonthDays[FirstDay:LastDay]
#         
#         DFkMonthPlot <- PlotDF[PlotDF$startDate %in% MonthDays,]
#         # ==== 
#         
#         if(nrow(DFkMonthPlot) != 0){
#                 # == adjust factor levels for plot ==
#                 FirstDayOfYear <- wday(update(plotDate, day = 1, month = 1)) # 1 is Sun, 7 is Sat
#                 # first of a year is alwyas the weekday at which the weeks start
#                 # NB: could also be done via FirstDay, i.e. wday(MonthDays[1]) 
#                 if(FirstDayOfYear > 1){
#                         DFkMonthPlot$Wday <- factor(DFkMonthPlot$Wday, levels = levels(DFkMonthPlot$Wday)[c(FirstDayOfYear:7,1:(FirstDayOfYear-1))])        
#                 }
#                 
#                 #DFkPlot$weekLabel <- paste("W", DFkMonthPlot$Week, " (", year(DFkMonthPlot$startTime), ")", sep = "")
#                 weekLabelLevels <- paste("Week ", FirstWeek:LastWeek, " (", year(plotDate), ")", sep = "")
#                 DFkMonthPlot$weekLabel <- factor(DFkMonthPlot$weekLabel, levels = weekLabelLevels, ordered = TRUE)
#                 
#                 # dayLabel will be put into an extra data frame and will be used in plot with geom_label
#                 dayLabelLevels <- paste(day(MonthDays), month(MonthDays, label = TRUE), sep = ".")
#                 DFkMonthPlotLabel <- data.frame(Label = dayLabelLevels, Hours = 22, startPosition = 0.3, Wday = wday(MonthDays, label = TRUE), 
#                                                 weekLabel = paste("Week ", week(MonthDays), " (", year(MonthDays), ")", sep = ""))
#                 if(FirstDayOfYear > 1){
#                         DFkMonthPlotLabel$Wday <- factor(DFkMonthPlotLabel$Wday, levels = levels(DFkMonthPlotLabel$Wday)[c(FirstDayOfYear:7,1:(FirstDayOfYear-1))])        
#                 }
#                 # ====
#                 DFkMonthPlot$Width <- DFkMonthPlot$Width * plotWidth
#                 DFkMonthPlot$startPosition <- DFkMonthPlot$startPosition * plotWidth
#                 DFkMonthPlotLabel$startPosition <- DFkMonthPlotLabel$startPosition * plotWidth
#                 
#                 Tr <- ggplot(DFkMonthPlot, aes(x = startPosition, y = Hours, label = shortName))
#                 Tr <- Tr + 
#                         geom_rect(mapping=aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), color="black", alpha=0.5) + 
#                         geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 3) +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = c(23, 18, 12, 6), expand = c(0,0)) +
#                         facet_grid(facets = weekLabel~Wday, drop = FALSE)+
#                         #facet_wrap(weekLabel~Wday, ncol = 7, drop = FALSE)
#                         xlab("") +
#                         ylab("") +
#                         geom_text(data = DFkMonthPlotLabel, aes(label = Label), col = "#660033", size = 2) +
#                         #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
#                         theme(strip.background = element_rect(fill="#660033"),
#                               strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
#                               strip.text = element_text(size=6, colour="white"))
#         } else {
#                 
#                 FirstDayOfYear <- wday(update(plotDate, day = 1, month = 1)) 
#                 dayLabelLevels <- paste(day(MonthDays), month(MonthDays, label = TRUE), sep = ".")
#                 DFkMonthPlotLabel <- data.frame(Label = dayLabelLevels, Hours = 22, startPosition = 0.3, Wday = wday(MonthDays, label = TRUE), 
#                                                 weekLabel = paste("Week ", week(MonthDays), " (", year(MonthDays), ")", sep = ""))
#                 if(FirstDayOfYear > 1){
#                         DFkMonthPlotLabel$Wday <- factor(DFkMonthPlotLabel$Wday, levels = levels(DFkMonthPlotLabel$Wday)[c(FirstDayOfYear:7,1:(FirstDayOfYear-1))])        
#                 }
#                 DFkMonthPlotLabel$startPosition <- DFkMonthPlotLabel$startPosition * plotWidth
#                 Tr <- ggplot(DFkMonthPlotLabel, aes(x = startPosition, y = Hours, label = Label))
#                 Tr <- Tr + 
#                         geom_blank()+
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = c(23, 18, 12, 6), expand = c(0,0)) +
#                         facet_grid(facets = weekLabel~Wday, drop = FALSE)+
#                         #facet_wrap(weekLabel~Wday, ncol = 7, drop = FALSE)
#                         xlab("") +
#                         ylab("") +
#                         geom_text(col = "#660033", size = 2) +
#                         #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
#                         theme(strip.background = element_rect(fill="#660033"),
#                               strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
#                               strip.text = element_text(size=6, colour="white"))
#                 
#                 
#         }
# }


# monthPlot2 <- function(PlotDF, plotDate, plotWidth = 5){
#         
#         # == find the surrounding dates of the plotMonth, i.e. the Mo before, and the Sunday after ==
#         First <- update(plotDate, day = 1)
#         if(wday(First)>1){
#                 Monday <- date(First - days(wday(First)-2))
#         } else {
#                 Monday <- date(First - days(6))
#         }
#         Last <- update(plotDate, day = 1) + months(1) - days(1)
#         
#         if(wday(Last)>1){
#                 Sunday <- date(Last + days(8-wday(Last)))
#         } else {
#                 Sunday <- Last
#         }
#         MonthDays <- seq.Date(from = date(Monday), to = date(Sunday), by = "days")
#         DFkMonthPlot <- PlotDF[PlotDF$startDate %in% MonthDays,] 
#         # ====
#         
#         if(nrow(DFkMonthPlot) != 0){
#                 DFkMonthPlot$Label <- paste(substr(wday(DFkMonthPlot$startDate, label = TRUE), 1, 2), " ", day(DFkMonthPlot$startDate), ".", 
#                                             month(DFkMonthPlot$startDate), ".", year(DFkMonthPlot$startDate),
#                                             "; W", week(DFkMonthPlot$startDate), sep = "")
#                 DFkMonthPlot$Label <- factor(DFkMonthPlot$Label, levels = 
#                                                      paste(substr(wday(MonthDays, label = TRUE),1,2), " ", day(MonthDays), ".", 
#                                                            month(MonthDays), ".", year(MonthDays),
#                                                            "; W", week(MonthDays), sep = ""), ordered = TRUE)
#                 
#                 DFkMonthPlot$Width <- DFkMonthPlot$Width * plotWidth
#                 DFkMonthPlot$startPosition <- DFkMonthPlot$startPosition * plotWidth
#                 
#                 
#                 Tr <- ggplot(DFkMonthPlot, aes(x = startPosition, y = Hours, label = shortName))
#                 Tr <- Tr + 
#                         geom_rect(mapping=aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), color="black", alpha=0.5) + 
#                         geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 3) +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = c(23, 18, 12, 6), expand = c(0,0)) +
#                         # facet_grid(facets = ~Label, ncol = 7, drop = FALSE)+
#                         facet_wrap(~Label, ncol = 7, drop = FALSE) +
#                         xlab("") +
#                         ylab("") +
#                         #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
#                         theme(strip.background = element_rect(fill="#660033"), 
#                               strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
#                               strip.text = element_text(size=6, colour="white"))
#                 
#         } else {
#                 DFkMonthPlotMock <- data.frame(Wday = lubridate::wday(plotDate, label = TRUE), 
#                                                startDate = date(plotDate), startPosition = 0,
#                                                Hours = 0, shortName = "", 
#                                                Label = paste(substr(wday(plotDate, label = TRUE), 1, 2), " ", day(plotDate), ".", 
#                                                              month(plotDate), ".", year(plotDate),
#                                                              "; W", week(plotDate), sep = ""))
#                 DFkMonthPlotMock$Label <- factor(DFkMonthPlotMock$Label, levels = 
#                                                          paste(substr(wday(MonthDays, label = TRUE),1,2), " ", day(MonthDays), ".", 
#                                                                month(MonthDays), ".", year(MonthDays),
#                                                                "; W", week(MonthDays), sep = ""), ordered = TRUE)
#                 
#                 DFkMonthPlotMock$startPosition <- DFkMonthPlotMock$startPosition * plotWidth
#                 
#                 
#                 Tr <- ggplot(DFkMonthPlotMock, aes(x = startPosition, y = Hours, label = shortName))
#                 Tr <- Tr + 
#                         geom_blank() +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = c(23, 18, 12, 6), expand = c(0,0)) +
#                         # facet_grid(facets = ~Label, ncol = 7, drop = FALSE)+
#                         facet_wrap(~Label, ncol = 7, drop = FALSE) +
#                         xlab("") +
#                         ylab("") +
#                         #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
#                         theme(strip.background = element_rect(fill="#660033"),
#                               strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
#                               strip.text = element_text(size=6, colour="white"))
#         }
# }





###############################
## monthPlot3 ##
###############################
# the same as monthPlot2 for what days will be plotted, but facet_grid instead of facet_wrap,
# so a bit a mixture between plot1 and plot2

# monthPlot3 <- function(PlotDF, plotDate, plotWidth = 5){
#         
#         # == find the surrounding dates of the plotMonth, i.e. the Mo before, and the Sunday after ==
#         First <- update(plotDate, day = 1)
#         if(wday(First)>1){
#                 Monday <- date(First - days(wday(First)-2))
#         } else {
#                 Monday <- date(First - days(6))
#         }
#         Last <- update(plotDate, day = 1) + months(1) - days(1)
#         
#         if(wday(Last)>1){
#                 Sunday <- date(Last + days(8-wday(Last)))
#         } else {
#                 Sunday <- Last
#         }
#         MonthDays <- seq.Date(from = date(Monday), to = date(Sunday), by = "days")
#         DFkMonthPlot <- PlotDF[PlotDF$startDate %in% MonthDays,] 
#         # ====
#         
#         if(nrow(DFkMonthPlot) != 0){
#                 
#                 DFkMonthPlot$Wday <- factor(DFkMonthPlot$Wday, levels = levels(DFkMonthPlot$Wday)[c(2:7, 1)], ordered = TRUE)
#                 # add pseudo week levels
#                 DFkMonthPlot$weekPs <- sapply(DFkMonthPlot$startDate, function(x){which(MonthDays == x)})
#                 mapdf <- data.frame(old=1:35,new=c(rep(1,7),rep(2,7),rep(3,7), rep(4,7), rep(5,7)))
#                 DFkMonthPlot$weekPs <- mapdf$new[match(DFkMonthPlot$weekPs,mapdf$old)]
#                 DFkMonthPlot$weekPs <- factor(DFkMonthPlot$weekPs, levels = 1:(length(MonthDays)/7), ordered = TRUE)
#                 
#                 dayLabels <- paste(day(MonthDays), ".", month(MonthDays, label = TRUE), ".", year(MonthDays), "; W", week(MonthDays),
#                                    sep = "")
#                 DFkMonthPlotLabel <- data.frame(Label = dayLabels, Hours = 22, startPosition = 0.3*plotWidth, Wday = wday(MonthDays, label = TRUE),
#                                                 weekPs = c(rep(1,7),rep(2,7),rep(3,7), rep(4,7), rep(5,7)))
#                 DFkMonthPlotLabel$Wday <- factor(DFkMonthPlotLabel$Wday, levels = levels(DFkMonthPlotLabel$Wday)[c(2:7, 1)], ordered = TRUE)
#                 
#                 
#                 
#                 DFkMonthPlot$Width <- DFkMonthPlot$Width * plotWidth
#                 DFkMonthPlot$startPosition <- DFkMonthPlot$startPosition * plotWidth
#                 
#                 
#                 Tr <- ggplot(DFkMonthPlot, aes(x = startPosition, y = Hours, label = shortName))
#                 Tr <- Tr + 
#                         geom_rect(mapping=aes(xmin=startPosition, xmax=startPosition+Width, ymin=Hours, ymax=Hours+Duration/60), color="black", alpha=0.5) + 
#                         geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 3) +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = c(23, 18, 12, 6), expand = c(0,0)) +
#                         # facet_grid(facets = ~Label, ncol = 7, drop = FALSE)+
#                         facet_grid(weekPs~Wday, drop = FALSE) +
#                         xlab("") +
#                         ylab("") +
#                         geom_text(data = DFkMonthPlotLabel, aes(label = Label), col = "#660033", size = 2) +
#                         #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
#                         theme(strip.text.y = element_blank(),
#                               strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
#                               strip.background = element_rect(fill="#660033"), 
#                               strip.text = element_text(size=6, colour="white"))
#                 
#         } else {
#                 dayLabels <- paste(day(MonthDays), ".", month(MonthDays, label = TRUE), ".", year(MonthDays), "; W", week(MonthDays),
#                                    sep = "")
#                 DFkMonthPlotLabel <- data.frame(Label = dayLabels, Hours = 22, startPosition = 0.3*plotWidth, Wday = wday(MonthDays, label = TRUE),
#                                                 weekPs = c(rep(1,7),rep(2,7),rep(3,7), rep(4,7), rep(5,7)))
#                 DFkMonthPlotLabel$Wday <- factor(DFkMonthPlotLabel$Wday, levels = levels(DFkMonthPlotLabel$Wday)[c(2:7, 1)], ordered = TRUE)
#                 Tr <- ggplot(DFkMonthPlotLabel, aes(x = startPosition, y = Hours, label = Label))
#                 Tr <- Tr + 
#                         geom_blank() +
#                         scale_x_continuous(limits = c(0,plotWidth), breaks = c(), labels = c()) +
#                         scale_y_reverse(limits = c(24, 0), breaks = c(23, 18, 12, 6), expand = c(0,0)) +
#                         # facet_grid(facets = ~Label, ncol = 7, drop = FALSE)+
#                         facet_grid(weekPs~Wday, drop = FALSE) +
#                         xlab("") +
#                         ylab("") +
#                         geom_text(col = "#660033", size = 2) +
#                         #geom_label(data = DFkMonthPlotLabel, aes(label = Label), col = "black", size = 2) +
#                         theme(strip.text.y = element_blank(),
#                               strip.text.x = element_text(margin = margin(.08,0,.08,0, "cm")),
#                               strip.background = element_rect(fill="#660033"), 
#                               strip.text = element_text(size=6, colour="white"))
#         }
# }
