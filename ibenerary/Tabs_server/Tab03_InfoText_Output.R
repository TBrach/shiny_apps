# - output infoText -
output$infoText <- renderText({
    rv$infoText
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
# --