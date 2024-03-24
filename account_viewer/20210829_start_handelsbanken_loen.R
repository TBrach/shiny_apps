library(tidyverse)
al <- readRDS("~/Downloads/account_list.rds")
hl <- al[["Handelsbanken_Loen"]]
df <- read.csv2(file = "~/Downloads/start_nem.csv", header = FALSE, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
df <- df[,1:4]
account <- "Handelsbanken_Loen"
colnames(df) <- c("Date", "Text", "Amount", "Saldo")
df$Currency <- "DKK"
df$Date <- lubridate::parse_date_time(df$Date, orders = "dmy", tz = "CET")
df$Account <- account
if (df$Date[1] > df$Date[nrow(df)]) {
    df <- df[nrow(df):1,] # make sure oldest is on top for following Amount check
}
al[["Handelsbanken_Loen"]] <- df
saveRDS(al, "~/Downloads/account_list.rds")
