# - Load all required packages -
library(shiny)
#library(shinyTime)
library(shinyFiles)
library(lubridate)
library(rdrop2)
library(cm.analysis)
library(ggtree)
library(treeio)
library(ape)
library(Biostrings)
library(gridExtra)
library(cowplot)
# library(ggrepel)
library(tidyverse)
# --


# - load the ui files -
source("asv_check_ui.R")
# --

# - load the server function -
source("asv_check_server.R")
# --

# - run the app -
shinyApp(ui = ui, server = server)
# --

