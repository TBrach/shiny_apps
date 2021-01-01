# - Separate all dates and times into reactive expressions and run validation tests on these inputs to check user input -
datePoint <- reactive({
        validate(need(!is.na(lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")), "Please add the date in year-month-day format!"))
        lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")
})

timePoint <- reactive({
        time_input <- renderText(strftime(input$time, "%H:%M"))
        validate(need(!is.na(lubridate::parse_date_time(time_input(), orders = "HM", tz = "CET")), "Please add the start time in hh:mm format!"))
        # if criterion is fulfilled code just continues, otherwise TimePoint becomes the string "Please..."
        lubridate::parse_date_time(time_input(), orders = "HM", tz = "CET")
})


plotDate <- reactive({
        validate(need(!is.na(lubridate::parse_date_time(input$plotDate, orders = "ymd", tz = "CET")), "Please add the plot date in year-month-day format!"))
        lubridate::parse_date_time(input$plotDate, orders = "ymd", tz = "CET")
})
# --


# - inform the user when validation tests on input$date or input$time failed -
output$dateStatus <- renderText({
        if(is.character(datePoint())) {
                datePoint()
        } else {
                NULL
        }
})

output$dateStatus2 <- renderText({
        if(is.character(datePoint())) {
                datePoint()
        } else {
                NULL
        }
})


output$timeStatus <- renderText({
        if(is.character(timePoint())){
                timePoint()
        } else {
                NULL
        }
})

output$timeStatus2 <- renderText({
        if(is.character(timePoint())){
                timePoint()
        } else {
                NULL
        }
})



output$plotDateStatus <- renderText({
        if(is.character(plotDate())) {
                plotDate()
        } else {
                NULL
        }
})
# --