library(shiny)
library(lubridate)
library(tidyr)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(rdrop2)
# library(ggrepel)
# library(DT)


# ---------------To save Data to your dropbox account this had to be done once ----------------
# # important: authentication to rdrop2 to submit data from shiny to dropbox
# install.packages("rdrop2")
# library(rdrop2)
# # has to be done once by hand
# drop_auth()
# # after you autnthicated in the browser this created a .httr-oauth file in your working directory
# # move the .httr-oauth file into your app folder via iTerm
# # In consequence putting things to dropbox only works when .httr-oauth is in your app folder
# ----------------------------------------------------------


######## Things to add


################ Alternatives

# output$itTable <- if(is.null(rv$event)){
#         renderPrint({"No event yet in your itenuary"})
# } else {
#         renderTable({rv$event}, sanitize.text.function = function(x) x)
# }


## ===== the fluidPage function to generate the html webpage ========
# == you also define here the input and output objects that will be assigned the the server function==


source("IbeneraryFunctions.R")


ui <- fluidPage(
        # change the style of the validation errors
        tags$head(
                tags$style(HTML("
                                .shiny-text-output {
                                color: blue;
                                }
                                ")),
                tags$style(HTML("
                                .shiny-output-error-validation {
                                color: red;
                                }
                                ")),
                # tags$style(HTML("
                #                 .tab-pane {
                #                 background-color: green;
                #                 }
                #                 "))
                tags$style(HTML("
                                h2 {
                                color: orange;
                                font-size: 25px;
                                font-weight: 900;
                                }
                                "))
                
        ),
        titlePanel("Plan and save your next itinerary"), # just creates <h2> object
        wellPanel(
                textInput(inputId = "itname", label = "Name of itinerary", value = "Itinerary"),
                tags$h6("Name will be used as file name for saved csv, pdf, rds files.")
        ),
        sidebarLayout(
                sidebarPanel(
                        tabsetPanel(
                                tabPanel("Add/remove events",
                                         tags$br(),
                                         textInput(inputId = "name", label = "Event Name", value = "Eventname", placeholder = "give your event a name"),
                                         selectInput(inputId = "category", label = "Event Category", choices = list("Transport", "Hotel", "Activity", "Food")),
                                         dateInput(inputId = "date", label = "Start Date", format = "yyyy-mm-dd"),
                                         textOutput(outputId = 'startDateStatus'),
                                         textInput(inputId = "time", label = "Start Time", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                                         textOutput(outputId = 'startTimeStatus'),
                                         textInput(inputId = "duration", label = "Duration (in minutes!)", placeholder = "duration in minutes"),
                                         # checkboxInput(inputId = "wholeDay", label = "Whole Day (Start Time = 00:00; Duration = 1440)"),
                                         dateInput(inputId = "endDate", label = "End Date (only considered if no duration is given)"),
                                         textOutput(outputId = 'endDateStatus'),
                                         textInput(inputId = "endTime", label = "End Time (only considered if no duration is given)", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                                         textOutput(outputId = 'endTimeStatus'),
                                         textInput(inputId = "link", label = "Link", placeholder = "Copy link here"),
                                         textInput(inputId = "comment", label = "Comment", placeholder = "write a short note"),
                                         textInput(inputId = "cost", label = "Cost", placeholder = "cost estimate"),
                                         tags$label("Rate the event"),
                                         wellPanel(
                                                 tags$h5("To rate the event: tick the box below, then use the slider to give 1 to 5 stars."),
                                                 checkboxInput(inputId = "ratedecide", label = "I want to rate the event", value = FALSE),
                                                 # tags$h6("1 = bad, 5 = excellent"),
                                                 sliderInput(inputId = "rate", label = NULL, min = 1, max = 5,
                                                             value = 3, width = "80%")),
                                         actionButton(inputId = "AddUpdate", label = "Add or Update Event"),
                                         #tags$br(),
                                         # actionButton(inputId = "remove", label = "Remove Event"),
                                         HTML('<hr style="color: black;">'),
                                         wellPanel(
                                                 actionButton(inputId = "pick", label = "Pick Event"),
                                                 actionButton(inputId = "pickRemove", label = "Remove Event"),
                                                 textInput(inputId = "no", label = "", placeholder = "No", width = "80px")
                                         )),
                                tabPanel("Load",
                                         h4("Upload an itinerary: NB: will override current itinerary!"),
                                         h5("Upload itinerary from drop box"),
                                         actionButton(inputId = "GetDrop", label = "Get itinerary from Dropbox"),
                                         h5("Upload itinerary from csv"),
                                         fileInput(inputId = "load", label = NULL, accept = c(
                                                 "text/csv",
                                                 "text/comma-separated-values,text/plain",
                                                 ".csv")))
                        ), 
                        width = 4
                ),
                # helpText("Uploading an itinerary kills your current itinerary")),
                mainPanel(wellPanel(
                        tags$h5("Info text"),
                        textOutput(outputId = "infoText"),
                        # textOutput(outputId = "DateStatus"),
                        # textOutput(outputId = "TimeStatus"),
                        HTML('<hr style="color: black;">'),
                        tags$h5("Save itinerary"),
                        actionButton(inputId = "Drop", label = "Save in DP"),
                        downloadButton(outputId = "save", label = "Save as csv"),
                        HTML('<hr style="color: black;">'),
                        tags$h5("Plot itinerary"),
                        actionButton(inputId = "plot", label = "Plot itinerary"),
                        downloadButton(outputId = "savePlot", label = "Save Plot as pdf"),
                        HTML('<hr style="color: black;">'),
                        textOutput(outputId = "TotalCost")
                ),
                textOutput(outputId = "DFiStatus"),
                # dataTableOutput(outputId = "itTable"),
                tableOutput(outputId = "itTable"),
                plotOutput(outputId = "itPlot", height = "600px")
                )
        )
)


## =========== Define your server function to create reactivity ==================================
server <- function(input, output, session) {
        
        # -- generate reactive Values that can be used in reactive functions and
        # changed via observe functions --
        
        rv <- reactiveValues(DFi = NULL, infoText = NULL, Tr = NULL, PlotHeight = 2.9) #Plot Height, see below
        # 2.9 inches is chosen per day of the itinerary, that way four days fill 1 DinA4 = 11,69 inches
        
        # ----
        
        # -- Separate input$time and input$date, endDate and endTime into reactive expressions
        # and run validation tests on these inputs to check user input --
        
        # TimePoint <- eventReactive(c(input$AddUpdate, input$remove, input$pick), {
        #         validate(need(!is.na(lubridate::parse_date_time(input$time, orders = "HM")), "Please add the time in hh:mm format!"))
        #         # if criterion is fulfilled code just continues, otherwise TimePoint becomes the string "Please..."
        #         lubridate::parse_date_time(input$time, orders = "HM")
        # })
        
        datePoint <- reactive({
                validate(need(!is.na(lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")), "Please add the date in year-month-day format!"))
                lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")
        })
        
        endDatePoint <- reactive({
                validate(need(!is.na(lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")), "Please add the end date in year-month-day format!"))
                lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")
        })
        
        
        # in case you wanted it to react directly (and also the error message would be removed when corrected), use reactive:
        timePoint <- reactive({
                validate(need(!is.na(lubridate::parse_date_time(input$time, orders = "HM", tz = "CET")), "Please add the end time in hh:mm format!"))
                # if criterion is fulfilled code just continues, otherwise TimePoint becomes the string "Please..."
                lubridate::parse_date_time(input$time, orders = "HM", tz = "CET")
        })
        
        
        endTimePoint <- reactive({
                validate(need(!is.na(lubridate::parse_date_time(input$endTime, orders = "HM", tz = "CET")), "Please add the end time in hh:mm format!"))
                # if criterion is fulfilled code just continues, otherwise endTimePoint becomes the string "Please..."
                lubridate::parse_date_time(input$endTime, orders = "HM", tz = "CET")
        })
        
        # ----
        
        # -- inform the user when validation tests on input$time and input$date failed --
        
        output$startDateStatus <- renderText({
                if(is.character(datePoint())) {
                        datePoint()} else {
                                NULL
                        }
        })
        
        output$endDateStatus <- renderText({
                if(is.character(endDatePoint())) {
                        endDatePoint()} else {
                                NULL
                        }
        })
        
        output$startTimeStatus <- renderText({
                if(is.character(timePoint())){
                        timePoint()} else {
                                NULL
                        }
        })
        
        output$endTimeStatus <- renderText({
                if(is.character(endTimePoint())){
                        endTimePoint()} else {
                                NULL
                        }
        })
        
        # ----
        
        # -- get the rating as reactive expression  --
        
        Rating <- reactive({
                if(isTRUE(input$ratedecide)){
                        input$rate
                } else {
                        NULL
                }
        })
        
        # ----
 
        
        # -- Change DFi when Add or Update Event button is pressed  --
        
        observeEvent(input$AddUpdate, { 
                
                # reset infoText when button is pressed
                rv$infoText <- NULL
                rv$Tr <- NULL
                
                Name <- input$name
                if(Name == "") {
                        rv$infoText <- "A Name is needed for every event"
                        return()
                }
                
                startTime <- update(datePoint(), hour = hour(timePoint()), minute = minute(timePoint()))
                Duration <- as.numeric(input$duration)
                
                if(is.na(Duration) || Duration < 5){
                        endTime <- update(endDatePoint(), hour = hour(endTimePoint()), minute = minute(endTimePoint()))
                        Duration <- as.numeric(as.duration(endTime-startTime), "minutes")
                        if(Duration < 5){
                                rv$infoText <- "Sorry events have to last at least 5 minutes"
                                return()
                        }
                } else {
                        endTime <- startTime + minutes(Duration)
                }
                
                Category <- input$category
                Link <- input$link
                if (Link == ""){
                        Ref <- ""
                } else {
                        Ref <- paste0("<a href='",Link,"' target='_blank'>",Name,"</a>")
                        # Ref <- as.character(tags$a(href = Link, target = Name)) # alternative via tags, but needed to be corrected
                }
                Cost <- suppressWarnings(as.numeric(input$cost))
                Comment <- input$comment
                Rate <- Rating()
                if(is.null(Rate)){
                        Rate <- ""
                        } else if(Rate == 1) {
                                Rate <- "*"
                        } else if(Rate == 2) {
                                Rate <- "**"
                        } else if(Rate == 3) {
                                Rate <- "***"
                        } else if(Rate == 4) {
                                Rate <- "****"
                        } else if(Rate == 5) {
                                Rate <- "*****"
                        }
                
                event <- data.frame(Name = Name, Category = Category, Start = startTime, End = endTime, Duration = Duration,  Link = Ref,
                                    Comment = Comment, estCost = Cost, Rate = Rate)
                if(is.null(rv$DFi)){
                        rv$DFi <- event
                        rv$infoText <- "Event has been added."
                } else {
                        rv$DFi <- rbind(rv$DFi, event)
                        rv$infoText <- "Event has been added."
                        if(anyDuplicated(rv$DFi[, c("Name", "Start")])){
                                IndexDuplicated <- anyDuplicated(rv$DFi[, c("Name", "Start")], fromLast = TRUE)
                                rv$DFi[IndexDuplicated,] <- rv$DFi[nrow(rv$DFi),]
                                rv$DFi <- rv$DFi[-nrow(rv$DFi),]
                                rv$infoText <- "Event has been updated."
                        }
                        
                        rv$DFi <- dplyr::arrange(rv$DFi, Start)
                        
                }
                
        })
        
        # ----
        
        # ---- use render Table to display itinerary ------
        
        output$itTable <- renderTable({
                if(!is.null(rv$DFi)){
                        DFiShow <- cbind(No = 1:nrow(rv$DFi), rv$DFi) 
                        DFiShow$Start <- format(DFiShow$Start, format='%Y-%m-%d %H:%M')
                        DFiShow$End <- format(DFiShow$End, format='%Y-%m-%d %H:%M')
                        DFiShow$Duration <- as.character(DFiShow$Duration)
                        DFiShow
                } else {
                        NULL
                        # data.frame(Date = "There are", Time = "no events", Category = "in your", Name = "itinerary", Link = "yet!")
                        # data.frame(Date = "", Time = "", Category = "", Name = "", Link = "")
                }}, sanitize.text.function = function(x) x)
        
        # ----
        
        # -- Pick an event --
        
        observeEvent(input$pick, { 
                
                # reset infoText when button is pressed
                rv$infoText <- NULL
                # rv$Tr <- NULL
                
                No <- suppressWarnings(as.numeric(input$no))
                
                if(is.null(rv$DFi)){
                        # rv$DFi <- NULL
                        rv$infoText <- "There are no events in your itinerary to pick from."
                } else if (is.na(No)){
                        rv$infoText <- "No must be given as a number"
                } else if (!(No %in% 1:nrow(rv$DFi))) {
                        rv$infoText <- "The given No does not fit to any event in your itinerary"
                } else if (No %in% 1:nrow(rv$DFi)) {
                        # pick event
                        event <- rv$DFi[No,]
                        
                        # name input
                        updateTextInput(session, inputId = "name",
                                        value = as.character(event$Name)
                        )
                        
                        # category input
                        if(as.character(event$Category) == "Transport"){
                                updateSelectInput(session, inputId = "category",
                                                  selected = "Transport")
                        } else if(as.character(event$Category) == "Hotel"){
                                updateSelectInput(session, inputId = "category",
                                                  selected = "Hotel")
                        } else if(as.character(event$Category) == "Activity"){
                                updateSelectInput(session, inputId = "category",
                                                  selected = "Activity")
                        } else if(as.character(event$Category) == "Food"){
                                updateSelectInput(session, inputId = "category",
                                                  selected = "Food")
                        }
                        
                        # set date input
                        updateDateInput(session, inputId = "date",
                                        value = format(event$Start, "%Y-%m-%d")
                        )
                        
                        # set time input
                        updateTextInput(session, inputId = "time",
                                        value = as.character(paste(strftime(event$Start, "%H", tz = "CET"), ":", strftime(event$Start, "%M", tz = "CET"), sep = ""))
                        )
                        
                        
                        updateTextInput(session, inputId = "duration", value = as.character(event$Duration))
                        
                        # set endDate input
                        updateDateInput(session, inputId = "endDate",
                                        value = format(event$End, "%Y-%m-%d")
                        )
                        
                        # set endTime input
                        updateTextInput(session, inputId = "endTime",
                                        value = as.character(paste(strftime(event$End, "%H", tz = "CET"), ":", strftime(event$End, "%M", tz = "CET"), sep = ""))
                        )
                        
                        
                        
                        # link input
                        Links <- strsplit(as.character(event$Link), split = "' target")[[1]][1]
                        Links <- substring(Links, first = 10, last = 1000000L)
                        
                        updateTextInput(session, inputId = "link",
                                        value = as.character(Links)
                        )
                        
                        # comment input
                        updateTextInput(session, inputId = "comment",
                                        value = as.character(event$Comment)
                        )
                        
                        # cost input
                        updateTextInput(session, inputId = "cost",
                                        value = as.character(event$estCost)
                        )
                        
                        # rate input
                        if(event$Rate == ""){
                                updateCheckboxInput(session, inputId = "ratedecide", value = FALSE)
                                updateSliderInput(session, inputId = "rate",
                                                  value = 3)
                        } else if (event$Rate == "*"){
                                updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                                updateSliderInput(session, inputId = "rate",
                                                  value = 1)
                        } else if (event$Rate == "**"){
                                updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                                updateSliderInput(session, inputId = "rate",
                                                  value = 2)
                        } else if (event$Rate == "***"){
                                updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                                updateSliderInput(session, inputId = "rate",
                                                  value = 3)
                        } else if (event$Rate == "****"){
                                updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                                updateSliderInput(session, inputId = "rate",
                                                  value = 4)
                        } else if (event$Rate == "*****"){
                                updateCheckboxInput(session, inputId = "ratedecide", value = TRUE)
                                updateSliderInput(session, inputId = "rate",
                                                  value = 5)
                        }
                        
                        
                        rv$infoText <- "Event has been picked."
                        
                } else {
                        rv$infoText <- "No matching event was found to pick."
                }
        })
        
        # ----
        
        # -- remove events from rv$DFi when remove button is pressed (i.e. based on start time) --
        # I removed this option, thought it was easier via the pick box to remove based on number (pickRemove!)
        # but would work when uncommented
        # observeEvent(input$remove, { 
        #         
        #         # reset infoText when button is pressed
        #         rv$infoText <- NULL
        #         rv$Tr <- NULL
        #         
        #         startTime <- update(datePoint(), hour = hour(timePoint()), minute = minute(timePoint()))
        #         
        #         if(is.null(rv$DFi)){
        #                 rv$DFi <- NULL
        #                 rv$infoText <- "There are no events in your itinerary."
        #         } else if (nrow(rv$DFi) == 1 && rv$DFi[1,"Start"] == startTime) {
        #                 rv$DFi <- NULL
        #                 rv$infoText <- "Event has been removed."
        #         } else if (nrow(rv$DFi) > 1 && startTime %in% rv$DFi[,"Start"]){
        #                 
        #                 rv$DFi <- rv$DFi[-which(rv$DFi[,"Start"] == startTime),]
        #                 rv$infoText <- "Event has been removed."
        #                 
        #         } else {
        #                 rv$infoText <- "No matching event was found to remove."
        #         }
        # })
        
        # ----
        
        # -- Remove an event by rowname  --

        observeEvent(input$pickRemove, { 
                
                No <- suppressWarnings(as.numeric(input$no))
                
                if(is.null(rv$DFi)){
                        rv$infoText <- "There are no events to remove."
                } else if (is.na(No)){
                        rv$infoText <- "No of event must be given as a number"
                } else if (!(No %in% 1:nrow(rv$DFi))) {
                        rv$infoText <- "The given No does not fit to any event in your itinerary"
                } else if (No %in% 1:nrow(rv$DFi)) {
                        
                        rv$DFi <- rv$DFi[-No,]
                        
                        
                        rv$infoText <- "Event has been removed."
                        
                } else {
                        rv$infoText <- "No matching event was found to remove."
                }
        })
        
        # ----
        
        # -- save itinerary in your dropbox --
        
        observeEvent(input$Drop, {
                
                if(is.null(rv$DFi)){
                        rv$infoText = "You can not upload empty itineraries, makes no sense"
                        return(NULL)
                } else {
                        
                        if(input$itname == ""){
                                Name <- "Itinerary"
                        } else {
                                #Name <- make.names(gsub(" ", "_", input$itname))
                                Name <- gsub(" ", "_", input$itname) # removed the make.names because it changes 2017... to X2017...
                        }

                        filename = paste(Name, ".rds", sep = "")
                        file_path <- file.path(tempdir(), filename)
                        saveRDS(rv$DFi, file_path)
                        drop_upload(file_path, path = 'Public/Itineraries')
                        rv$infoText = paste("Saved itinerary: ", Name, ".rds to Dropbox", sep = "")
                }
        })
        
        # ----
        

        # -- get itinerary from your dropbox --
        
        observeEvent(input$GetDrop, {
                
                suppressMessages(filesInfo <- drop_dir(path = 'Public/Itineraries'))
                filePaths <- filesInfo$path_display
                
                if(input$itname == ""){
                        Name <- "Itinerary.rds"
                } else {
                        Name <- paste(input$itname, ".rds", sep = "")
                }
                
                if(Name %in% basename(filePaths)) {
                        filePath <- filePaths[which(basename(filePaths) %in% Name)]
                        # copied this code from drop_read_csv code!
                        localfile = paste0(tempdir(), "/", basename(filePath))
                        drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
                        rv$DFi <- readRDS(file = localfile)
                        # set the name input field (important if loaded Dansk.rds)
                        updateTextInput(session, inputId = "itname",
                                        value = strsplit(Name, ".rds")[[1]]
                        )
                        rv$infoText = "Loaded itinerary from DP"
                } else {
                        rv$infoText = "Did not find an itinerary with this name in DP"
                }
                
        })
        
        # ----
        
        # -- Save the itinerary as csv --
        
        output$save <- downloadHandler(
                # downloadHandler takes two arguments, both functions
                # the filename function:
                filename = function(){
                        
                        if(is.null(rv$DFi)){
                                "EmptyItinerary.csv"
                        } else {
                                ItName <- input$itname
                                if(ItName == ""){ItName <- "Itinerary"}
                                # paste(date(now()), "_", ItName, ".csv", sep = "")
                                paste(ItName, ".csv", sep = "")
                        }
                },
                
                content = function(file) {
                        # rv$infoText <- NULL # does not work
                        if(is.null(rv$DFi)){
                                rv$infoText <- "Downloaded an empty csv"
                                DFiSave <- NULL
                        } else {
                                rv$infoText <- "Downloaded itinerary as csv"
                                DFiSave <- rv$DFi
                                DFiSave <- data.frame(lapply(DFiSave, as.character), stringsAsFactors=FALSE)
                                # extract actual links from Link column
                                # extract actual links from Link column
                                Links <- DFiSave$Link[DFiSave$Link != ""]
                                Links <- strsplit(Links, split = "' target")
                                Links <- sapply(Links, `[`, 1)
                                Links <- substring(Links, first =  10, last = 1000000L)
                                DFiSave$Link[DFiSave$Link != ""] <- Links
                        }
                        write.table(DFiSave, file, sep = ";", row.names = FALSE)
                        #write.csv(DFiSave, file)
                }
        )
        
        # ----
        
        # -- Allow to load a csv saved itinerary --
        # NB: this option is probably not yet fail-proof, but it works when the file has been created with the
        # app on my computer at least
        
        observeEvent(input$load, {
                rv$Tr <- NULL
                inFile <- input$load
                # validate(need(!is.null(inFile), "No correct csv file was selected"))
                if(is.null(inFile)){
                        rv$infoText <- "No correct csv file was selected. Old itinerary was kept."
                        return()
                }
                
                InTa <- read.csv(file = inFile$datapath, header = TRUE, sep = ";")
                # validate(need(ncol(InTable) == 5, "No correct csv file was selected"))
                if(!(ncol(InTa) %in% c(9))){
                        rv$infoText <- "Loaded csv had not 5, 6, 7, or 8 columns. Old itinerary was kept."
                        return()
                }
                
                Headers <- c("Name", "Category", "Start", "End", "Duration", "Link", "Comment", "estCost", "Rate")
                
                if(any(!(Headers %in% colnames(InTa)))) {
                        rv$infoText <- "Could not assign all columns, file was probably not generated by this app"
                        return()
                }
                
                colnames(InTa) <- Headers
                
                
                Costs <- suppressWarnings(as.numeric(InTa$estCost))
                
                InTa <- data.frame(lapply(InTa, as.character), stringsAsFactors=FALSE)
                
                InTa$estCost <- Costs
                
                if(any(is.na(lubridate::parse_date_time(InTa$Start, orders = "ymd HMS", tz = "CET")))){
                        rv$infoText <- "Could not parse all Start times in loaded itinerary. Old itinerary was kept."
                        return()
                }
                
                if(any(is.na(lubridate::parse_date_time(InTa$End, orders = "ymd HMS", tz = "CET")))){
                        rv$infoText <- "Could not parse all End times in loaded itinerary. Old itinerary was kept."
                        return()
                }
                
                InTa$Start <- lubridate::parse_date_time(InTa$Start, orders = "ymd HMS", tz = "CET")
                
                InTa$End <- lubridate::parse_date_time(InTa$End, orders = "ymd HMS", tz = "CET")
                
                
                # change the link format to real links
                InTa$Link[grep(pattern = ".",InTa$Link)] <- paste0("<a href='",InTa$Link[grep(pattern = ".",InTa$Link)],"' target='_blank'>",InTa$Name[grep(pattern = ".",InTa$Link)],"</a>")
                # InTa$Link <- tags$a(href = InTa$Link, target = InTa$Name)
                
                # make sure all Rates are appropriate
                InTa$Rate[!(InTa$Rate %in% c("","*", "**", "***", "****", "*****"))] <- ""
                
                # make sure all Categories are appropriate
                InTa$Category[!(InTa$Category %in% c("Transport", "Hotel", "Activity", "Food"))] <- "Activity"
                
                #rm(Times, Dates)
                rv$DFi <- InTa
                rv$infoText <- "Uploaded csv file with itinerary"
                
                # Attempt to set the Name when loading file
                NameGuess <- strsplit(inFile$name, split = "_")
                NameGuess <- strsplit(NameGuess[[length(NameGuess)]], split = ".csv")
                
                updateTextInput(session, inputId = "itname",
                                value = as.character(NameGuess[[length(NameGuess)]])
                )

        })
        
        # ----
        
        
        # -- Create Tr when plot action button is pressed --
        
        observeEvent(input$plot, { 
                
                # reset infoText when button is pressed
                
                if(is.null(rv$DFi)){
                        
                        rv$Tr <- NULL
                        rv$infoText <- "Your itinerary is empty, so there is nothing to plot."
                        rv$PlotHeight <- 2.7
                        
                } else {
                        
                        DFiPlot <- rv$DFi    #[,c("DateTime", "Date", "Time", "Category", "Name")]
                        
                        earliest <- min(DFiPlot$Start)
                        latest <- max(DFiPlot$End)
                        # daysCovered <- interval(earliest, latest)/days(1)
                        daysCovered <- length(seq(date(earliest), date(latest), by = "day"))
                        
                        # # only allow plotting for itineraries below 3 weeks in length
                        # if (daysCovered > 21){
                        #         rv$infoText <- "Plot function is only allowed for itineraries of max 3 weeks"
                        #         return()
                        # }
                        
                        
                        
                        # - split multiple day entries using splitMultidayEntries()-
                        
                        DFiPlot$startDate <- format(DFiPlot$Start, "%Y-%m-%d")
                        DFiPlot$startDate <- lubridate::parse_date_time(DFiPlot$startDate, orders = "ymd", tz = "CET")
                        # not sure if necessary, but date(DFiPlot$Start) results in a class "Date" object, while this way it is still POSIXct
                        DFiPlot$endDate <- format(DFiPlot$End, "%Y-%m-%d")
                        DFiPlot$endDate <- lubridate::parse_date_time(DFiPlot$endDate, orders = "ymd", tz = "CET")
                        
                        if(any(DFiPlot$endDate > DFiPlot$startDate)){
                                DFiPlot <- splitMultidayEntries(DFiPlot)
                        }
                        # --
                        
                        # - split DFiPlot into list of data.frames that are unique for one category -
                        DFiPlotList <- split(DFiPlot, DFiPlot$Category)
                        # --
                        
                        
                        # - Find Blocks of overlapping events using blockFinder (for each category separately) -
                        DFiPlotList <- lapply(DFiPlotList, blockFinder)
                        # --
                        
                        # - determine position and width of each element using positionAndWidthAssigner()
                        DFiPlotList <- lapply(DFiPlotList, positionAndWidthAssigner)
                        # --
                        
                        # - unite the list again into ond DFiPlot -
                        DFiPlot <- do.call("rbind", DFiPlotList)
                        # not really necessary but I want it here
                        DFiPlot <- dplyr::arrange(DFiPlot, Start, Name)
                        # --
                        
                        # - prepare for the facet plot -
                        DFiPlot$wday <- lubridate::wday(DFiPlot$Start, label = TRUE)
                        # DFiPlot$Week <- strftime(DFiPlot$Start, format = "%V", tz = "CET")
                        DFiPlot$Hours <- as.numeric(as.duration(DFiPlot$Start - update(DFiPlot$Start, hour = 0, minute = 0)), "hours")
                        # NB: Check: ISNT THERE A BUG WITH MULTI DAY ENTRIES?? HOW IS IT SOLVED IN CALENDAR MONTH THING
                        
                        DFiPlot$dayLabel <- paste(DFiPlot$wday, " (", DFiPlot$startDate, ")", sep = "")
                        # DFiPlot$dayLabel <- paste(DFiPlot$wday, " (", DFiPlot$startDate, ", W", DFiPlot$Week, ")", sep = "")
                        DFiPlot$shortName <- substring(as.character(DFiPlot$Name), first = 1, last = 22)
                        # --
                        
                        # - start the facet plot -
                        plotWidth = 5
                        # for faceting you need all days covered by the itinerary, remember you already have earliest and latest timepoint
                        daysCoveredDates <- seq(from = date(earliest), to = date(latest), by = "days")
                        # you need them as factor levels
                        daysCoveredDates <- paste(lubridate::wday(daysCoveredDates, label = TRUE), " (", daysCoveredDates, ")", sep = "")
                        DFiPlot$dayLabel <- factor(DFiPlot$dayLabel, levels = daysCoveredDates, ordered = TRUE)
                        DFiPlot$Category <- factor(DFiPlot$Category, levels = colorLevels, ordered = TRUE)
                        
                        DFiPlot$Duration <- as.numeric(DFiPlot$Duration)
                        
                        DFiPlot$Width <- DFiPlot$Width * plotWidth
                        DFiPlot$startPosition <- DFiPlot$startPosition * plotWidth
                        
                        Tr <- ggplot(DFiPlot, aes(x = startPosition, y = Hours, label = shortName, fill = Category))
                        Tr <- Tr +
                                geom_rect(mapping=aes(xmin = startPosition, xmax = startPosition + Width, ymin = Hours, ymax=Hours+Duration/60), alpha=0.75, col = cbPalette[1], size = 0.2) + 
                                # size sets the line width and is by default 0.5, I want thinner lines if at all, maybe remove the col at all, so no line
                                facet_grid(dayLabel ~ Category, drop = FALSE) +
                                geom_text(vjust = 1, nudge_y = 0, hjust = -0.08, check_overlap = TRUE, col = "black", size = 4) +
                                scale_x_continuous(limits = c(0, plotWidth), breaks = c(), labels = c()) +
                                scale_y_reverse(limits = c(24, 0), breaks = 23:0, expand = c(0,0)) +
                                scale_fill_manual("", values = colorValues) +
                                xlab("") +
                                ylab("") +
                                theme_bw() +
                                theme(legend.position = "none",
                                      strip.background = element_rect(fill = cbPalette[7]),
                                      strip.text.x = element_text(margin = margin(.09,0,.09,0, "cm")),
                                      strip.text.y = element_text(margin = margin(0,.09,0,.09, "cm")),
                                      strip.text = element_text(size = 10, colour = "white"))
                        
                        rv$Tr <- Tr
                        rv$PlotHeight <- daysCovered*2.9 # again should be inches, so 4 days fill one DINA4 = 11,69 inches
                        rv$infoText <- "Your itinerary has been plotted."
                        
                }
                
        })
        
        # ----
        
        # -- Allow to save the plot --
        
        output$savePlot <- downloadHandler(
                filename = function(){
                        
                        if(is.null(rv$Tr)){
                                "EmptyPlot.pdf"
                        } else {
                                ItName <- input$itname
                                if(ItName == ""){ItName <- "Itinerary"}
                                # paste(date(now()), "_", ItName, ".csv", sep = "")
                                paste("Plot_", ItName, ".pdf", sep = "")
                        }
                },
                
                content = function(file) {
                        # pdf(file, width = 12, height = rv$PlotHeight)
                        pdf(file, width = 8.20, height = rv$PlotHeight) # decided to always go for DINA4 width (8.27 inches)
                        # The PlotHeight should be so that 4 days fill a DINA4 height (11.69 inches), 11.69/4 = 2.9225, >> 2.9 per dayCovered 
                        print(rv$Tr)
                        dev.off()
                })
        
        
        # ----

        
        # -- Text messages to inform the user --
        
        output$infoText <- renderText({
                if(is.null(rv$infoText)){
                        NULL} else {
                                rv$infoText
                        }
        })
        
        output$DFiStatus <- renderText({
                if(is.null(rv$DFi)){
                        return("There are currently no events in your itinerary")
                } else {
                        return(NULL)
                }
        })
        
        output$TotalCost <- renderText({
                TotalCost <- sum(rv$DFi$Cost, na.rm = TRUE)
                if(TotalCost != 0){
                        return(paste("The total cost of the itinerary is: ", TotalCost, sep = ""))
                } else {
                        return(NULL)
                }
        })
        
        # ----
        
        
        
        # -- plot the itinerary --
        
        output$itPlot <- renderPlot({
                rv$Tr
                }, height = reactive({85*rv$PlotHeight})) # NB: here height is in pixels, so the 2.9 inches per day must
        # be translated into a reasonable pixel value
        
        # ----
        
        
        
}

## ======== Run the app ===================

shinyApp(ui = ui, server = server)