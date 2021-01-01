rv <- list()
datapath <- "/Users/jvb740/Coursera_MOOC/20161202_LearningShiny_FantasySports/shinyy/Apps/Shinyappsio/AccountViewer/IngDiba"
df_in <- read.csv2(file = file.path(datapath, "IngDiba_Extra.csv"), sep = ";", header = TRUE, stringsAsFactors = FALSE)
colIndexes <- match(c("Date", "Text", "Saldo", "Amount"), colnames(df_in))
colIndexes <- colIndexes[!is.na(colIndexes)]
df_in <- df_in[, colIndexes]
df_in$Date <- lubridate::parse_date_time(df_in$Date, orders = "dmy", tz = "CET")
df_in$Text <- as.character(df_in$Text)
df_in$Saldo <- as.numeric(df_in$Saldo)
df_in$Amount <- as.numeric(df_in$Amount)
if (df_in$Date[1] > df_in$Date[nrow(df_in)]) {
        df_in <- df_in[nrow(df_in):1,] # I just like to have the oldest value on top, also for following Amount check
}



if (!all.equal(df_in$Amount[2:nrow(df_in)], diff(df_in$Saldo))) {
        warning("!!!!!!!your Amounts did not fit to your Saldo's, this was corrected here but you should check it in your csv!!!! ")
        df_in$Amount[2:nrow(df_in)] <- diff(df_in$Saldo)
}


# - new thing the account name for multiple account version -
account_name <- basename(file.path(datapath, "FaellesKonto.csv"))
account_name <- strsplit(x = account_name, split = ".csv")[[1]][1]
df_in$Account <- account_name
# --


# - generate an account list -
account_list <- list()
account_list[[1]] <- df_in
names(account_list)[1] <- account_name
# -

# - make up loading another account -
df_in2 <- df_in
df_in2$Saldo <- df_in2$Saldo + 150
account_name <- "Fritz"
df_in2$Account <- account_name

index <- length(account_list) + 1
account_list[[index]] <- df_in2
names(account_list)[index] <- account_name
# --




rv$DFa <- df_in

# - set the startDate and endDate -
startDate <- df_in$Date[1]
endDate <- df_in$Date[nrow(df_in)]
# startDate <- "2017-03-20"
# endDate <- date(now())
# startDate <- lubridate::parse_date_time(startDate, orders = "ymd", tz = "CET")
# endDate <- lubridate::parse_date_time(endDate, orders = "ymd", tz = "CET")
# --



# - generate the plot -
DFaPlot <- rv$DFa
DFaPlot <- dplyr::filter(DFaPlot, Date >= startDate, Date <= endDate)

rleDates <- rle(as.character(DFaPlot$Date))[[1]]


DFaPlot$Minute <- unlist(lapply(rleDates, function(i){minute_spreader(i)}))
DFaPlot$ActionTime <- DFaPlot$Date + minutes(DFaPlot$Minute)
DFaPlot$NextTime <- c(DFaPlot$ActionTime[2:nrow(DFaPlot)], DFaPlot$ActionTime[nrow(DFaPlot)] + minutes(5))


Tr <- ggplot(DFaPlot, aes(x = ActionTime, y = Saldo, text = paste("Date: ", as.Date(ActionTime), 
                                                                  "<br>Amount: ", Amount,
                                                                  "<br>Text:", Text)))
Tr <- Tr + 
        geom_segment(aes(x = ActionTime, xend = NextTime, yend = Saldo), linetype = 3) +
        geom_segment(aes(x = ActionTime, xend = ActionTime, yend = Saldo - Amount), linetype = 1) +
        geom_point(col = cbPalette[2]) +
        theme_bw() +
        xlab("") +
        ylab("Saldo [currency]")

rv$Tra <- Tr
# --

# - render the plot -

print(ggplotly(rv$Tra, tooltip = c("Saldo", "text")))
# --


