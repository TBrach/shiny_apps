# - Separate all dates and times into reactive expressions and run validation tests on these inputs to check user input -
datePoint <- reactive({
        validate(need(!is.na(lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")), "Please add the date in year-month-day format!"))
        lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")
})

endDatePoint <- reactive({
        validate(need(!is.na(lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")), "Please add the end date in year-month-day format!"))
        lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")
})

timePoint <- reactive({
        time_input <- renderText(strftime(input$time, "%H:%M"))
        validate(need(!is.na(lubridate::parse_date_time(time_input(), orders = "HM", tz = "CET")), "Please add the start time in hh:mm format!"))
        # if criterion is fulfilled code just continues, otherwise TimePoint becomes the string "Please..."
        lubridate::parse_date_time(time_input(), orders = "HM", tz = "CET")
})

endTimePoint <- reactive({
        time_input2 <- renderText(strftime(input$endTime, "%H:%M"))
        validate(need(!is.na(lubridate::parse_date_time(time_input2(), orders = "HM", tz = "CET")), "Please add the end time in hh:mm format!"))
        # if criterion is fulfilled code just continues, otherwise TimePoint becomes the string "Please..."
        lubridate::parse_date_time(time_input2(), orders = "HM", tz = "CET")
})
# --

# - inform the user when validation tests on input$date or input$time failed -
output$startDateStatus <- renderText({
        if(is.character(datePoint())) {
                datePoint()
        } else {
                NULL
        }
})

output$endDateStatus <- renderText({
        if(is.character(endDatePoint())) {
                endDatePoint()
        } else {
                NULL
        }
})



output$startTimeStatus <- renderText({
        if(is.character(timePoint())){
                timePoint()
        } else {
                NULL
        }
})


output$endTimeStatus <- renderText({
        if(is.character(endTimePoint())){
                endTimePoint()
        } else {
                NULL
        }
})
# --