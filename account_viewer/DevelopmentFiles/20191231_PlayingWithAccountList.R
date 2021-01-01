functionpath <- "~/Shinyappsio/AccountViewer_Combined"
source(file.path(functionpath, "accountViewerFunctions.R"))
datapath <- "~/Shinyappsio/AccountViewer_Combined/account_list"
filename <- "account_list.rds"
account_list <- readRDS(file.path(datapath, filename))


# - read IngDiba Giro -
accountFile <- "Umsatzanzeige_DE82500105175401622490_20191231.csv"
df <- read.csv(file = file.path(datapath, accountFile), header = TRUE, skip = 14, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
df$Text <- paste(df[[3]], df[[5]], sep = " - ")
df <- dplyr::select(df, Date = Buchung, Text, Amount = Betrag, Saldo = Saldo, Currency = 7)
df$Date <- lubridate::parse_date_time(df$Date, orders = "dmy", tz = "CET")
df[3:4] <- lapply(df[3:4], function(amount){
    amount <- str_remove_all(string = amount, pattern = "\\.")
    amount <- str_replace_all(string = amount, pattern = ",", replacement = ".")
    as.numeric(amount)
})
df$Account <- "IngDiba_Giro"
if (df$Date[1] > df$Date[nrow(df)]) {
    df <- df[nrow(df):1,] # make sure oldest is on top for following Amount check
}
dff <- account_list[[1]]
df_all <- rbind(dff, df)
df_all <- df_all[!duplicated(df_all),]
if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
    rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
    return()
}
# --
# - read IngDiba Extra -
accountFile <- "Extra.csv"
df <- read.csv(file = file.path(datapath, accountFile), header = TRUE, skip = 14, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
df$Text <- paste(df[[3]], df[[4]], df[[5]], sep = " - ")
df <- dplyr::select(df, Date = Buchung, Text, Amount = Betrag, Saldo = Saldo, Currency = 7)
df$Date <- lubridate::parse_date_time(df$Date, orders = "dmy", tz = "CET")
df[3:4] <- lapply(df[3:4], function(amount){
    amount <- str_remove_all(string = amount, pattern = "\\.")
    amount <- str_replace_all(string = amount, pattern = ",", replacement = ".")
    as.numeric(amount)
})
df$Account <- "IngDiba_Extra"
if (df$Date[1] > df$Date[nrow(df)]) {
    df <- df[nrow(df):1,] # make sure oldest is on top for following Amount check
}
dff <- account_list[["IngDiba_Extra"]]
df_all <- rbind(dff, df)
df_all <- df_all[!duplicated(df_all),]
if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
    rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
    return()
}
# --
# - read IngDiba Depot -
accountFile <- "Depotbewertung_8003103024_20200101.csv"
df <- read.csv(file = file.path(datapath, accountFile), header = TRUE, skip = 5, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
df <- df[complete.cases(df),]
df$Text <- paste(df$Wertpapiername, collapse = " - ")
df <- dplyr::select(df, Date = Zeit, Text, Saldo = Kurswert, Currency = 6)
df["Saldo"] <- lapply(df["Saldo"], function(amount){
    amount <- str_remove_all(string = amount, pattern = "\\.")
    amount <- str_replace_all(string = amount, pattern = ",", replacement = ".")
    as.numeric(amount)
}) 
df <- data.frame(Date = df$Date[1], Text = df$Text[1], Amount = NA, Saldo = sum(df$Saldo), Currency = df$Currency[1], Account = "IngDiba_Depot")
df$Date <- lubridate::parse_date_time(df$Date, orders = "dmy", tz = "CET")
dff <- account_list[["IngDiba_Depot"]]
df$Amount <- df$Saldo - dff$Saldo[nrow(dff)]
df_all <- rbind(dff, df)
if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
    rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
    return()
}
# --

# - read Handelsbanken faelles -
accountFile <- "Posteringer.csv"
df <- read.csv2(file = file.path(datapath, accountFile), header = FALSE, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
df <- df[,1:4]
colnames(df) <- c("Date", "Text", "Amount", "Saldo")
df$Currency <- "DKK"
df$Date <- lubridate::parse_date_time(df$Date, orders = "dmy", tz = "CET")
df$Account <- "Handelsbanken_Faelles"
if (df$Date[1] > df$Date[nrow(df)]) {
    df <- df[nrow(df):1,] # make sure oldest is on top for following Amount check
}
dff <- account_list[["Handelsbanken_Faelles"]]
df_all <- rbind(dff, df)
df_all <- df_all[!duplicated(df_all[-2]),] # because of the Danish later issue that I had when not using fileEncoding
if (!all.equal(df_all$Amount[2:nrow(df_all)], diff(df_all$Saldo))) {
    warning("!!!!!!!your Amounts did not fit to your Saldo's, this was corrected here but you should check it in your file!!!! ")
    df_all$Amount[2:nrow(df_all)] <- diff(df_all$Saldo)
}
# --
# - read BasisBank_Loen -
accountFile <- "export.csv"
df <- read.csv2(file = file.path(datapath, accountFile), header = FALSE, stringsAsFactors = FALSE, sep = ";", fileEncoding="utf-8")
df <- dplyr::select(df, Date = 1, Text = 3, Amount = 4, Saldo = 5)
df$Currency <- "DKK"
df$Date <- lubridate::parse_date_time(df$Date, orders = "dmy", tz = "CET")
df[3:4] <- lapply(df[3:4], function(amount){
    amount <- str_remove_all(string = amount, pattern = "\\.")
    amount <- str_replace_all(string = amount, pattern = ",", replacement = ".")
    as.numeric(amount)
})
df$Account <- "BasisBank_Loen"
if (df$Date[1] > df$Date[nrow(df)]) {
    df <- df[nrow(df):1,] # make sure oldest is on top for following Amount check
}
dff <- account_list[["BasisBank_Loen"]]
df_all <- rbind(dff, df)
df_all <- df_all[!duplicated(df_all[-2]),] # because of the Danish later issue that I had when not using fileEncoding
if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
    warning("!!!!!!!your Amounts did not fit to your Saldo's, this was corrected here but you should check it in your file!!!! ")
    df_all$Amount[2:nrow(df_all)] <- diff(df_all$Saldo)
}

# --

