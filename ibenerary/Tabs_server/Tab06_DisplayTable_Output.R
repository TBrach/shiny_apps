# - use render Table to display itinerary -
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
# --