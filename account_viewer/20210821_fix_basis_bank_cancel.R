library(lubridate)
library(tidyverse)

al <- readRDS("~/Downloads/account_list.rds")
bb <- al[["BasisBank_Loen"]]

last_moves <- read.delim("~/shiny_apps/account_viewer/BankFolders/BasisBank/20210821_last_movements.txt", header = FALSE)

last_moves <- tidyr::separate(data = last_moves, col = V1, into = c("Date1", "Date", "Rest"), sep = " ", extra = "merge")
last_moves$Saldo <- str_extract(last_moves$Rest, " [^ ]+$")
last_moves$Rest <- str_remove(last_moves$Rest, " [^ ]+$")
last_moves$Amount <- str_extract(last_moves$Rest, " [^ ]+$")
last_moves$Text <- str_remove(last_moves$Rest, " [^ ]+$")

last_moves <- dplyr::select(last_moves, any_of(names(bb)))
last_moves[] <- lapply(last_moves, str_trim)
last_moves$Date <- lubridate::parse_date_time(last_moves$Date, orders = "dmy", tz = "CET")
last_moves$Amount <- str_remove(last_moves$Amount, "\\.")
last_moves$Amount <- str_replace(last_moves$Amount, ",", "\\.")
last_moves$Amount <- as.numeric(last_moves$Amount)
last_moves$Saldo <- str_remove_all(last_moves$Saldo, "\\.")
last_moves$Saldo <- str_replace(last_moves$Saldo, ",", "\\.")
last_moves$Saldo <- as.numeric(last_moves$Saldo)
last_moves$Currency <- "DKK"
last_moves$Account <- "BasisBank_Loen"
str(last_moves)
# - remove duplicates -
last_moves <- last_moves[12:nrow(last_moves),]
testi <- rbind(bb, last_moves)
# --
al[["BasisBank_Loen"]] <- testi
saveRDS(al, "~/Downloads/account_list.rds")
