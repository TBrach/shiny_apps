# Fix Tab05_PlotAccount.R
# - load the newest account_list -
functionpath <- "~/Shiny_in_Use/AccountViewer"
source(file.path(functionpath, "accountViewerFunctions.R"))
datapath <- "~/Shiny_in_Use/AccountViewer/account_list"
filename <- "account_list.rds"
account_list <- readRDS(file.path(datapath, filename))
# --
# - account_colors should go to rv -
account_colors = c(Total = "#E69F00", IngDiba_Giro = "#117755", IngDiba_Extra = "#44AA88", IngDiba_Depot = "#99CCBB",
                   BasisBank_Loen = "#4477AA", Handelsbanken_Faelles = "#AA4477")
# --
# - restrict -
#accountNames <- "Handelsbanken_Faelles"
#account_list <- account_list[names(account_list) %in% accountNames]
# --
# filter for Dates -
startDate <- lubridate::parse_date_time("20200201", orders = "ymd", tz = "CET")
endDate <- lubridate::parse_date_time("20200228", orders = "ymd", tz = "CET")
account_list2 <- lapply(account_list, function(df){dplyr::filter(df, Date >= startDate, Date <= endDate)})
# --
# - remove no entry accounts -
remainingEntries <- lapply(account_list2, nrow)
account_list2 <- account_list2[remainingEntries > 0]
# --
# TURNED OUT THE ERROR WAS IN THE FOLLOWING CHUNK FOR ACCOUNTS WITH ONLY 1 entry, the df$NextTime code did not allow accounts with only 1 entry
account_list2 <- lapply(account_list2, function(df){
    rleDates <- rle(as.character(df$Date))[[1]]
    df$Minute <- unlist(lapply(rleDates, function(i){minute_spreader(i)}))
    df$ActionTime <- df$Date + lubridate::minutes(df$Minute)
    if (nrow(df) > 1){
        df$NextTime <- c(df$ActionTime[2:nrow(df)], df$ActionTime[nrow(df)] + lubridate::minutes(5))
    } else {
        df$NextTime <- df$ActionTime[nrow(df)] + lubridate::minutes(5)
    }
    
    df
    
})
# FIXED