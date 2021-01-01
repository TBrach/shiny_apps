# - Load all required packages -
library(shiny)
library(lubridate)
library(tidyverse)
library(rdrop2)
library(viridis)
library(plotly)
# --


# - 20190926: To access your dropbox account this had to be done: -
# It's based on the rdrop2 package, the critical info is given here: <https://github.com/karthik/rdrop2#accessing-dropbox-on-shiny-and-remote-servers>
# So you have to do once the part that is under "Authentication" on that page, i.e.:
# library(rdrop2)
# drop_auth() # then accept in browser
# NB: this gives you the .httr-oauth file, that works locally but not always on shinyapps.io. So delete it!
# instead continue with:
# token <- drop_auth()
# saveRDS(token, file = "token.rds")
# so now you have token.rds in your app folder
# To make things work smoothly on shinyapps.io, I got the key info here: <https://github.com/karthik/rdrop2/issues/61>
# you do 1.) drop_auth(rdstoken = "token.rds") in the general part of the app here, then use all drop_* functions without 
# dtoken argument. 
# --

# - 20190926: Uploading app to shinyapps.io -
# Thats' were the rsconnect folder comes from.
# see <https://docs.rstudio.com/shinyapps.io/getting-started.html#deploying-applications>
# --

# - 20190926: the app friendly timeInput from shinyTime package -
# This cost me some nerves, see now I use: see ShinyTime folder or shinyTimeExample() if you want
# The problem was that it always changed the time to UTC, so 2 hours wrong from CET.
# The problem is the minute.steps argument, don't use it, even if it appears interesting, it rounds and must call 
# a time function that changes the tz. So just stick to:
# timeInput(inputId = "time", label = "Start Time", value = now(tzone = "CET"), seconds = FALSE),
# --

# - load functions -
source("accountViewerFunctions.R")
# --

# - do the dropbox authentication -
# <https://github.com/karthik/rdrop2/issues/61>
# drop_auth(rdstoken = "token.rds")
# --

# - load the ui files -
source("AccountViewer_ui.R")
# --

# - load the server function -
source("AccountViewer_server.R")
# --

# - run the app -
shinyApp(ui = ui, server = server)
# --





