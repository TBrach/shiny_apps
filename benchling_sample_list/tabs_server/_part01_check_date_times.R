# - Separate all dates (and times) into reactive expressions and run validation tests on these inputs to check user input -
datePoint <- reactive({
        validate(need(!is.na(lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")), "Please add the date in year-month-day format!"))
        lubridate::parse_date_time(input$date, orders = "ymd", tz = "CET")
})
# --

# - inform the user when validation tests on input$date or input$time failed -
output$date_status <- renderText({
        if(is.character(datePoint())) {
                datePoint()
        } else {
                NULL
        }
})

# --