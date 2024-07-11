# - Load all required packages -
library(shiny)
library(shinyTime)
library(shinyFiles)
#library(rdrop2)
#library(gridExtra)
#library(ggrepel)
library(lubridate)
library(tidyverse)
# library(flextable)
# library(officer)
library(tidyverse)
library(readxl)
library(writexl)
library(cli) # to use 
# --

# - load functions -
source("app_bsl_functions.R")
# --


# - load the ui files -
source("bsl_ui.R")
# --

# - load the server function -
source("bsl_server.R")
# --

# - run the app -
shinyApp(ui = ui, server = server)
# --

