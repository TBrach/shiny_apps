functionpath <- "/Users/thorstenbrach/Shinyappsio/AccountViewer_Combined"
source(file.path(functionpath, "accountViewerFunctions.R"))
extent_accountList <- function(account_list, functionpath, filename){
    
    inFile <- list()
    inFile$datapath <- file.path(functionpath, filename)
    df_in <- upload_creation(inFile)
    # - you check Amount values in comparison to Saldos -
    if (!all.equal(df_in$Amount[2:nrow(df_in)], diff(df_in$Saldo))) {
        warning("!!!!!!!your Amounts did not fit to your Saldo's, this was corrected here but you should check it in your csv!!!! ")
        df_in$Amount[2:nrow(df_in)] <- diff(df_in$Saldo)
    }
    # --
    account_name <- basename(filename)
    account_name <- strsplit(x = account_name, split = ".csv")[[1]][1]
    if (account_name == "Total") { # to prevent a clash with the Total account being the total of all accounts!
        account_name <- "Total_uploaded"
    }
    df_in$Account <- account_name
    if (is.null(account_list)){
        account_list <- list()
        account_list[[1]] <- df_in
        names(account_list)[1] <- account_name
    } else {
        if (account_name %in% names(account_list)){
            index <- which(account_name == names(account_list))
            account_list[[index]] <- df_in
        } else {
            index <- length(account_list) + 1
            account_list[[index]] <- df_in
            names(account_list)[index] <- account_name
        }
    }
    account_list
}

filename <- "IngDiba/IngDiba_Giro.csv"
account_list <- extent_accountList(account_list = NULL, functionpath = functionpath, filename = filename)
filename <- "IngDiba/IngDiba_Extra.csv"
account_list <- extent_accountList(account_list = account_list, functionpath = functionpath, filename = filename)
filename <- "IngDiba/IngDiba_Depot.csv"
account_list <- extent_accountList(account_list = account_list, functionpath = functionpath, filename = filename)
filename <- "BasisBank/BasisBank_Loen.csv"
account_list <- extent_accountList(account_list = account_list, functionpath = functionpath, filename = filename)
filename <- "Handelsbanken/FaellesKonto.csv"
account_list <- extent_accountList(account_list = account_list, functionpath = functionpath, filename = filename)


savepath <- "/Users/thorstenbrach/Shinyappsio/AccountViewer_Combined/account_list/"
saveRDS(object = account_list, file = file.path(savepath, "account_list.rds"))
