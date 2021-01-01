#Tab02 <- tabPanel("Add",
Tab02 <- sidebarPanel(
                  wellPanel(
                          textOutput(outputId = 'infoTextExtra3'),
                          #tags$br(),
                          selectInput(inputId = "color", label = "Event Color", choices = colorLevels, selected = "Thorsten"),
                          textInput(inputId = "eventName", label = "Event Name"),
                          dateInput(inputId = "date", label = "Date"),
                          textOutput(outputId = 'dateStatus2'),
                          #textInput(inputId = "time", label = "Start Time", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                          timeInput(inputId = "time", label = "Start Time", value = now(tzone = "CET"), seconds = FALSE), # NB: you can't use minute.steps, fucks up the timezone
                          textOutput(outputId = 'timeStatus2'),
                          textInput(inputId = "duration", label = "Duration (in minutes!)", placeholder = "duration in minutes"),
                          # checkboxInput(inputId = "wholeDay", label = "Whole Day (Start Time = 00:00; Duration = 1440)"),
                          dateInput(inputId = "endDate", label = "End Date (only considered if no duration is given)"),
                          textOutput(outputId = 'endDateStatus2'),
                          #textInput(inputId = "endTime", label = "End Time (only considered if no duration is given)", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                          timeInput(inputId = "endTime", label = "End Time (only considered if no duration is given)", value = now(tzone = "CET"), seconds = FALSE), # NB: you can't use minute.steps, fucks up the timezone
                          textOutput(outputId = 'endTimeStatus2'),
                          # selectInput(inputId = "urgency", label = "urgency level", choices = c("a", "b", "c")),
                          textInput(inputId = "comment", label = "Comment"),
                          actionButton(inputId = "addEvent", label = "Add/Update")
                  ),
                  wellPanel(
                          textInput(inputId = "no", label = "No of event to pick or remove", placeholder = "No", width = "200px"),
                          actionButton(inputId = "pick", label = "Pick Event"),
                          actionButton(inputId = "removeEvent", label = "Remove Event")
                  ),
                  textOutput(outputId = 'infoTextExtra4'),
                  wellPanel(
                          textInput(inputId = "calendarName", label = "calendar name", value = "Faelles"),
                          # tags$br(),
                          actionButton(inputId = "getDropbox", label = "Get from Dropbox"),
                          actionButton(inputId = "saveDropbox", label = "Save in Dropbox")
                  ),
                  wellPanel(
                          checkboxInput(inputId = "search", label = "Entries containing.."),
                          textInput(inputId = "wordsearch", label = "search entry", placeholder = "search entry")
                          
                  ),
                  #tags$br(),
                  textOutput(outputId = 'infoTextExtra5'),
                  #tags$br(),
                  wellPanel(
                          textInput(inputId = "max_shown", label = "maximum events shown", value = "5", placeholder = "How many events will be shown (max)"),
                          radioButtons(inputId = "view", label = "Events shown in table", choices = c("plot date past", "end", "plot date"), selected = "plot date past")
                  )
)