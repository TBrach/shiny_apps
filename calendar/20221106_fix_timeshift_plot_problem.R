# Conclusions from this file
# (i) There is no easy way of fitting day time saving events in, think about it
# 1 day has only 23 hours, the one in fall 25, this is not acommodated for in your plots
# and I couldn't even find a simple solution in lubridate to get the right time 
# when starting 20221030 1:30 and adding 2 hours. --> basically just ignore the day time saving
# events, meaning if you come to set up an event 20221030 1:30 with a duration of 2h
# you simply end at 3:30, even though truth is you would have ended 2:30
# but noted below as.numeric(lubridate::as.duration(DF$endTime-DF$startTime), "minutes") actually considered it, i.e. gave 1500 minutes for a day saver day


# This resulted in conlcusion (2022-11-09) (ii): how to fix the code so at least it doesn't break
# When did it break: It broke when plotting at 2022-11-01, the initial break was in positionAndWidthAssigner
# in fact it turned out there were issues in splitMulti, positionAndWidthAssigner, and blockFinder.
# I now change in splitMultidayEntries to tz "UTC" for calculation of the durations to not get
# to 1500 minutes days on daylight saving days in autumn. Also made sure that the
# order of blocks on a day follows the original start time.


# - packages and functions -
library(tidyverse)
source("~/shiny_apps/calendar/calendarFunctions.R")
# --

# - settings -
input <- list()
input[["plotDate"]] <- "20230131"
input[["date"]] <- "20221030"
input[["endDate"]] <- "20221030"
input[["time"]] <- "02:30"
input[["duration"]] <- "120"
# Sonntag, 30. Oktober 2022: Zeitumstellung von Sommerzeit auf MEZ/Winterzeit. Die Uhr wird in der Nacht von Samstag auf Sonntag um 03:00 Uhr auf 02:00 zurückgestellt. Die Nacht ist also eine Stunde länger. 
# --

# - (the things that ended in conclusion i) first try to understand the situation when adding an event crossing the time shift -
datePoint <- lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")
endDatePoint <- lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")
timePoint <- lubridate::parse_date_time(input[["time"]], orders = "HM", tz = "CET")
startTime <- stats::update(datePoint, hour = hour(timePoint), minute = minute(timePoint))
Duration <- as.numeric(input$duration)
# first let's say duration is more than 5 minutes, then it should usually work to get the correct endTime
endTime <- startTime + lubridate::minutes(Duration)
endTime
# Clearly not what I expected, it seems it simply does ignore it!
# also in your plots you always expect to only have 24 hours
# so you are probably forced to ignore it, i.e. if you add 2 hours at 1 o clock of 
# 20221030, you will add at 3 o clock, even thouh in fact it was again 2 o clock
# that also means it will expect you to only have been on vacation 24 hours on that day.
# --> accept this, but don't get crashing plots
# --


# - (ii) trying to understand and fix the plotting issue -
# Code from Tab07_CalendarPlots
rv <- list()
rv[["DFk"]] <- readRDS("~/shiny_apps/calendar/Faelles.rds")
DFkPlot <- rv$DFk


plotDate <- lubridate::parse_date_time(input$plotDate, orders = "ymd", tz = "CET")
#lubridate::dst(plotDate)

plotMonth <- lubridate::interval(start = stats::update(plotDate, day = 1) - lubridate::weeks(1), 
                      end = stats::update(plotDate, day = 1) + base::months(1) + lubridate::weeks(1)) 
DFkPlot <- DFkPlot %>% filter(lubridate::int_overlaps(lubridate::interval(start = startTime, end = endTime), plotMonth))

# here you probably have to update the startTime of events starting before the plotMonth -


DFkPlot$startDate <- format(DFkPlot$startTime, "%Y-%m-%d")
DFkPlot$startDate <- lubridate::parse_date_time(DFkPlot$startDate, orders = "ymd", tz = "CET")
DFkPlot$endDate <- format(DFkPlot$endTime, "%Y-%m-%d")
DFkPlot$endDate <- lubridate::parse_date_time(DFkPlot$endDate, orders = "ymd", tz = "CET")
if(any(DFkPlot$endDate > DFkPlot$startDate)){
  DFkPlot <- splitMultidayEntries(PlotDF = DFkPlot)
  DFkPlot <- dplyr::filter(DFkPlot, Duration > 0)
}
DFkPlot <- blockFinder(PlotDF = DFkPlot)
# AND thats were the first error occurred, in positionAndWidthAssigner
DFkPlot <- positionAndWidthAssigner(PlotDF = DFkPlot)

DFkPlot$Wday <- lubridate::wday(DFkPlot$startTime, label = TRUE)
DFkPlot$Week <- strftime(DFkPlot$startDate, format = "%V", tz = "CET") # to use ISO 8601 (while lubridate uses US)
DFkPlot$Hours <- as.numeric(as.duration(DFkPlot$startTime - update(DFkPlot$startTime, hour = 0, minute = 0)), "hours")
DFkPlot$dayLabel <- paste(DFkPlot$Wday, " ", format.Date(DFkPlot$startDate, "%d"), ".", format.Date(DFkPlot$startDate, "%m"), ".", format.Date(DFkPlot$startDate, "%y"), ", W", DFkPlot$Week, sep = "")
DFkPlot$shortName <- substring(as.character(DFkPlot$Name), first = 1, last = 18)

dayTr <- dayPlot(DFkPlot, plotDate = plotDate, plotWidth = 16)
weekTr <- weekPlot(DFkPlot, plotDate = plotDate, plotWidth = 5)
monthTr <- monthPlot(DFkPlot, plotDate = plotDate, plotWidth = 5)

