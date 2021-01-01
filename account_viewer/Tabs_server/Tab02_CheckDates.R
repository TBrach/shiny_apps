# - Separate all dates and times into reactive expressions and run validation tests on these inputs to check user input -
startDate <- reactive({
        validate(need(!is.na(lubridate::parse_date_time(input$startDate, orders = "ymd", tz = "CET")), "Please add the date in year-month-day format!"))
        lubridate::parse_date_time(input$startDate, orders = "ymd", tz = "CET")
})

endDate <- reactive({
        validate(need(!is.na(lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")), "Please add the end date in year-month-day format!"))
        lubridate::parse_date_time(input$endDate, orders = "ymd", tz = "CET")
})
# --

# - inform the user when validation tests on input$date or input$time failed -
output$startDateStatus <- renderText({
        if(is.character(startDate())) {
                startDate()
        } else {
                NULL
        }
})

output$endDateStatus <- renderText({
        if(is.character(endDate())) {
                endDate()
        } else {
                NULL
        }
})
# --