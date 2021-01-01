datapath <- "~/Shinyappsio/Ibenerary2"
source(file.path(datapath, "IbeneraryFunctions.R"))
rv <- list()
rv$DFi <- readRDS(file.path(datapath, "20200328_SriLanka.rds"))


DFiPlot <- rv$DFi    #[,c("DateTime", "Date", "Time", "Category", "Name")]
earliest <- min(DFiPlot$Start)
latest <- max(DFiPlot$End)
# daysCovered <- interval(earliest, latest)/days(1)
daysCovered <- length(seq(date(earliest), date(latest), by = "day"))
#DFiPlot$startDate <- date(DFiPlot$Start)
DFiPlot$startDate <- format(DFiPlot$Start, "%Y-%m-%d")
DFiPlot$startDate <- lubridate::parse_date_time(DFiPlot$startDate, orders = "ymd", tz = "CET")
# not sure if necessary, but date(DFiPlot$Start) results in a class "Date" object, while this way it is still POSIXct
DFiPlot$endDate <- format(DFiPlot$End, "%Y-%m-%d")
DFiPlot$endDate <- lubridate::parse_date_time(DFiPlot$endDate, orders = "ymd", tz = "CET")
if(any(DFiPlot$endDate > DFiPlot$startDate)){
    DFiPlot <- splitMultidayEntries(DFiPlot)
}
DFiPlotList <- split(DFiPlot, DFiPlot$Category)
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

DFiPlot$wday <- lubridate::wday(DFiPlot$Start, label = TRUE)
# DFiPlot$Week <- strftime(DFiPlot$Start, format = "%V", tz = "CET")
DFiPlot$Hours <- as.numeric(as.duration(DFiPlot$Start - update(DFiPlot$Start, hour = 0, minute = 0)), "hours")
# NB: Check: ISNT THERE A BUG WITH MULTI DAY ENTRIES?? HOW IS IT SOLVED IN CALENDAR MONTH THING

DFiPlot$dayLabel <- paste(DFiPlot$wday, " (", DFiPlot$startDate, ")", sep = "")
# DFiPlot$dayLabel <- paste(DFiPlot$wday, " (", DFiPlot$startDate, ", W", DFiPlot$Week, ")", sep = "")
DFiPlot$shortName <- substring(as.character(DFiPlot$Name), first = 1, last = 22)



Dates <- seq(date(multiDayEntry$startDate), date(multiDayEntry$endDate), by = 'days')






