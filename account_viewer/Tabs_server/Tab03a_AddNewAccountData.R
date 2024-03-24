# - Directly add new data from downloaded csvs based -
# NB: this option is probably not yet fail-proof
observeEvent(input$addCSV, {
        
        rv$Tra <- NULL
        rv$infoText <- NULL
        inFile <- input$addCSV
        account <- input$select_account_to_add
        account_list <- rv$account_list
        
        if (account == "IngDiba_Giro"){
                # NB: fileEncoding: check with <http://osxdaily.com/2017/09/02/determine-file-encoding-mac-command-line/>
                df <- read.csv(file = inFile$datapath, header = TRUE, skip = 13, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
                # NB: intentionally not read.csv2!
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
                dff <- account_list[["IngDiba_Giro"]]
                before <- nrow(dff)
                df_all <- rbind(dff, df)
                df_all <- df_all[!duplicated(df_all),]
                if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
                        rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
                        return()
                }
                account_list[["IngDiba_Giro"]] <- df_all
                after <- nrow(df_all)
                rv$account_list <- account_list
                rv$infoText <- paste0("added ", after - before, " entries to IngDiba_Giro")
                rm(df, dff, df_all, after, before)
        } else if (account == "IngDiba_Extra"){
                # NB: fileEncoding: check with <http://osxdaily.com/2017/09/02/determine-file-encoding-mac-command-line/>
                df <- read.csv(file = inFile$datapath, header = TRUE, skip = 13, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
                # NB: intentionally not read.csv2
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
                before <- nrow(dff)
                df_all <- rbind(dff, df)
                df_all <- df_all[!duplicated(df_all[-2]),]
                if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
                        rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
                        return()
                }
                account_list[["IngDiba_Extra"]] <- df_all
                after <- nrow(df_all)
                rv$account_list <- account_list
                rv$infoText <- paste0("added ", after - before, " entries to IngDiba_Extra")
                rm(df, dff, df_all, after, before)
        } else if (account == "IngDiba_Depot"){
                # NB: fileEncoding: check with <http://osxdaily.com/2017/09/02/determine-file-encoding-mac-command-line/>
                df <- read.csv(file = inFile$datapath, header = TRUE, skip = 5, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
                # NB: intentionally not read.csv2
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
                before <- nrow(dff)
                df$Amount <- df$Saldo - dff$Saldo[nrow(dff)]
                df_all <- rbind(dff, df)
                if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
                        rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
                        return()
                }
                account_list[["IngDiba_Depot"]] <- df_all
                after <- nrow(df_all)
                rv$account_list <- account_list
                rv$infoText <- paste0("added ", after - before, " entries to IngDiba_Depot")
                rm(df, dff, df_all, after, before)
        } else if (account == "Handelsbanken_Faelles" || account == "Handelsbanken_Loen"){
                # df <- read.csv2(file = inFile$datapath, header = FALSE, stringsAsFactors = FALSE, sep = ";", fileEncoding="iso-8859-1")
                df <- read_csv2(file = inFile$datapath, col_names = TRUE, show_col_types = FALSE)
                df <- df[,1:4]
                colnames(df) <- c("Date", "Text", "Amount", "Saldo")
                df$Currency <- "DKK"
                df$Date <- lubridate::parse_date_time(df$Date, orders = "dmy", tz = "CET")
                df$Account <- account
                if (df$Date[1] > df$Date[nrow(df)]) {
                        df <- df[nrow(df):1,] # make sure oldest is on top for following Amount check
                }
                dff <- account_list[[account]]
                before <- nrow(dff)
                df_all <- rbind(dff, df)
                df_all <- df_all[!duplicated(df_all[-2]),] # because of the Danish later issue that I had when not using fileEncoding
                if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
                        rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
                        return()
                }
                account_list[[account]] <- df_all
                after <- nrow(df_all)
                rv$account_list <- account_list
                rv$infoText <- paste0("added ", after - before, " entries to ", account)
                
        } else if (account == "BasisBank_Loen") {
                df <- read.csv2(file = inFile$datapath, header = FALSE, stringsAsFactors = FALSE, sep = ";", fileEncoding="utf-8")
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
                before <- nrow(dff)
                df_all <- rbind(dff, df)
                df_all <- df_all[!duplicated(df_all[-2]),] # because of the Danish later issue that I had when not using fileEncoding
                if (max(df_all$Amount[2:nrow(df_all)] -  diff(df_all$Saldo)) > 1) {
                        rv$infoText <- "Problem that Saldo doesn't really fit to Amount, check!"
                        return()
                }
                account_list[["BasisBank_Loen"]] <- df_all
                after <- nrow(df_all)
                rv$account_list <- account_list
                rv$infoText <- paste0("added ", after - before, " entries to BasisBank_Loen")
                
        } else {
                rv$infoText <- "Don't know how to upload new data of the chosen account! Please choose the right account under Generate a table of your accounts"
        }
        
})
# --

