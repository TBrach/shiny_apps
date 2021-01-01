# - Load all required packages -
library(shiny)
library(shinyTime)
library(lubridate)
library(tidyr)
library(dplyr)
library(rdrop2)
library(ggplot2)
library(gridExtra)
library(ggrepel)
# --

# - load functions -
source("IbeneraryFunctions.R")
# --

# - do the dropbox authentication -
# <https://github.com/karthik/rdrop2/issues/61>
drop_auth(rdstoken = "token.rds")
# --

# - load the ui files -
source("Ibenerary_ui.R")
# --

# - load the server function -
source("Ibenerary_server.R")
# --

# - run the app -
shinyApp(ui = ui, server = server)
# --



