# - define cbPalette and QuantColors15 schemes -
# R color blind palette is used for group comparisons (unless more than 8 groups)
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7") # ref: http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/
# QuantColors15 is used for phyla comparisons as long as there are < 15 phyla, each color is easy to distinguish from the two colors surrounding it
tol15rainbow=c("#114477", "#4477AA", "#77AADD", "#117755", "#44AA88", "#99CCBB", "#777711", "#AAAA44", "#DDDD77", "#771111", "#AA4444", "#DD7777", "#771144", "#AA4477", "#DD77AA") # ref: https://tradeblotter.wordpress.com/2013/02/28/the-paul-tol-21-color-salute/
QuantColors15 <- tol15rainbow[c(1, 12, 4, 7, 13, 2, 11, 5, 8, 14, 3, 10, 6, 9, 15)]

pal <- function(col, border = "light gray", ...){
        n <- length(col)
        plot(0, 0, type="n", xlim = c(0, 1), ylim = c(0, 1),
             axes = FALSE, xlab = "", ylab = "", ...)
        rect(0:(n-1)/n, 0, 1:n/n, 1, col = col, border = border)
}
# --

# - make a ggplot version of pal -
pal_ggplot <- function(col){
        col <- unname(col) # the naming could cause trouble if NA somehow
        n <- length(col)
        df <- data.frame(xstart = 0:(n-1)/n, xend = 1:n/n, ystart = 0, yend = 1, Fill = sprintf(fmt = "%.5d", 1:n)) # you only end in ordering issues if you want to see more than 10000 colors:)
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




# --
#################################
### minute_spreader ############
################################

minute_spreader <- function(entries) {
        stretch <- floor(1440/(entries + 1))
        Minutes <- 1:entries * stretch
        Minutes
}
# --


# --
#################################
### generate_Total_account ############
################################

generate_Total_account <- function(account_list) {
        
        # - generate the Total account and add it to account list -
        total_account <- do.call("rbind", account_list)
        total_account <- dplyr::arrange(total_account, Date)
        
        # -- first find the indexes at which the different accounts appear first: --
        accounts <- names(account_list)
        FirstAppearance <- sapply(1:length(accounts), function(i){which(total_account$Account == accounts[i])[1]})
        # ----
        # -- generate an AmountSaldo variable where the FirstAppearance Indexes equal Saldo value --
        total_account$AmountSaldo <- total_account$Amount
        total_account$AmountSaldo[FirstAppearance] <- total_account$Saldo[FirstAppearance]
        # ----
        # -- calculate TotalSaldo using cumsum --
        total_account$TotalSaldo <- cumsum(total_account$AmountSaldo)
        # ----
        # -- adjust the Text and then the Account --
        total_account$Text <- paste0(total_account$Account, ": ", total_account$Text)
        total_account$Text[FirstAppearance] <- paste0(total_account$Account[FirstAppearance], ": First appearance")
        total_account$Account <- "Total"
        # ----
        # -- reduce to a normal account, i.e. keep the normal columns --
        total_account$Saldo <- total_account$TotalSaldo
        total_account$Amount <- total_account$AmountSaldo
        total_account <- dplyr::select(total_account, Date:Account)
        total_account
}
# --



# --
#################################
### upload_creation ############
################################

upload_creation <- function(inFile, requiredColumns = c("Date", "Text", "Amount", "Saldo", "Currency")) {
        
        # validate(need(!is.null(inFile), "No correct csv file was selected"))
        if(is.null(inFile)){
                return("No correct csv file was selected. Try again.")
        }
        
        
        
        df_in <- read.csv2(file = inFile$datapath, sep = ";", header = TRUE, stringsAsFactors = FALSE)
        
        colIndexes <- match(requiredColumns, colnames(df_in))
        
        colIndexes <- colIndexes[!is.na(colIndexes)]
        if (length(colIndexes) != 5){
                return(paste("Loaded csv did not contain the required columns: ", requiredColumns, ". Please adjust your csv file.", sep = ""))
        }
        
        df_in <- df_in[, colIndexes]
        
        # -- set classes of the 5 columns in df_in and perform tests --
        if(any(is.na(lubridate::parse_date_time(df_in$Date, orders = "dmy", tz = "CET")))){
                return("Could not parse all Dates, must be in day month year format!")
        }
        
        df_in$Date <- lubridate::parse_date_time(df_in$Date, orders = "dmy", tz = "CET")
        df_in$Text <- as.character(df_in$Text)
        
        if(any(is.na(as.numeric(df_in$Saldo)))){
                return("Could not parse all Saldo entries to numeric numbers, make sure they only contain commas as delimiter. Correct and load csv again.")
        }
        df_in$Saldo <- as.numeric(df_in$Saldo)
        
        if(any(is.na(as.numeric(df_in$Amount)))){
                return("Could not parse all Amount entries to numeric numbers, make sure they only contain commas as delimiter. Correct and load csv again.")
        }
        df_in$Amount <- as.numeric(df_in$Amount)
        
        df_in$Currency <- as.character(df_in$Currency)
        
        if (df_in$Date[1] > df_in$Date[nrow(df_in)]) {
                df_in <- df_in[nrow(df_in):1,] # make sure oldest is on top for following Amount check
        }
        
        df_in
}
# --









