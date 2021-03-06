Tab01 <- tabPanel("Done",
                  tags$br(),
                  textOutput(outputId = 'infoTextExtra2'),
                  #sliderInput(inputId = "person", label = "Person", min = 0, max = 1, value = 0, step = 1),
                  radioButtons(inputId = "person", label = "Who", choices = c("Thorsten", "Iben"), selected = "Thorsten"),
                  #tags$br(),
                  radioButtons(inputId = "task", label = "What", choices = c("legday", "abday"), selected = "legday"),
                  # textInput(inputId = "other", label = "other", placeholder = "if given, has priority over radio buttons"),
                  dateInput(inputId = "doneDate", label = "What Day"),
                  textOutput(outputId = 'doneDateStatus'),
                  textInput(inputId = "doneTime", label = "What Time", value = paste(strftime(now(), "%H", tz = "CET"), ":", strftime(now(), "%M", tz = "CET"), sep = ""), placeholder = "time in hh:mm"),
                  textOutput(outputId = 'doneTimeStatus'),
                  actionButton(inputId = "done", label = "Done -> Dropbox"),
                  tags$br(),
                  tags$br(),
                  textOutput(outputId = 'infoTextExtra')
)