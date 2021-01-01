functionpath <- "~/Shiny_in_Use/AccountViewer"
source(file.path(functionpath, "accountViewerFunctions.R"))
datapath <- "~/Shiny_in_Use/AccountViewer/account_list"
filename <- "account_list.rds"
account_list <- readRDS(file.path(datapath, filename))

df <- account_list[[3]]
startDate <- lubridate::parse_date_time("20200201", orders = "ymd", tz = "CET")
endDate <- lubridate::parse_date_time("20200228", orders = "ymd", tz = "CET")
df_filt <- dplyr::filter(df, Date >= startDate, Date <= endDate)

