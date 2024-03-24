library(tidyverse)
rv <- list()
rv$account_list <- readRDS("~/shiny_apps/account_viewer/account_list/account_list.rds")

# - make the budget_categories.rds file -
# budget_categories <- read_tsv(file = "/Users/jvb740/Downloads/yearly costs - budget_file_app.tsv")
# saveRDS(budget_categories, file = "/Users/jvb740/shiny_apps/account_viewer/budget_categories.rds")
rv$budget_categories <- readRDS("~/shiny_apps/account_viewer/budget_categories.rds")
# --
