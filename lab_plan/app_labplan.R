# - Load all required packages -
library(shiny)
library(shinyTime)
library(shinyFiles)
#library(rdrop2)
#library(gridExtra)
#library(ggrepel)
library(lubridate)
library(tidyverse)
library(flextable)
library(officer)
# --

# - load functions -
source("app_labplan_functions.R")
# --


# - load the ui files -
source("labplan_ui.R")
# --

# - load the server function -
source("labplan_server.R")
# --

# - run the app -
shinyApp(ui = ui, server = server)
# --

