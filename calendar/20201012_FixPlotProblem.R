~/Shiny_in_Use/Calendar

Faelles <- readRDS(file = file.path("~/Shiny_in_Use/Calendar", "Faelles.rds"))
source(file.path("~/Shiny_in_Use/Calendar","calendarFunctions.R"))

rv <- list()
rv$DFk <- Faelles

DFkPlot <- rv$DFk

plotDate <- lubridate::parse_date_time("20201011", orders = "ymd", tz = "CET")

# - restrict DFkPlot to entries that overlap with the month of the plotDate plus 1 week on each side -
plotMonth <- interval(start = update(plotDate, day = 1) - weeks(1), 
                      end = update(plotDate, day = 1) + months(1) + weeks(1)) 
DFkPlot <- DFkPlot[int_overlaps(interval(start = DFkPlot$startTime, end = DFkPlot$endTime), plotMonth),]
# --