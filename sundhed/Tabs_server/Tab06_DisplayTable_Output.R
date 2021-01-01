# - use render Table to display sundhed list -
output$itemTable <- renderTable({
        if(!is.null(rv$DFi)){
                DFiShow <- cbind(No = 1:nrow(rv$DFi), rv$DFi)
                
                if(isTRUE(input$restrictItem)){
                        itemNames <- input$itemNames
                        DFiShow <- DFiShow[DFiShow$Item %in% itemNames,]

                }
                
                if(isTRUE(input$restrictDate)){
                        DFiShow <- DFiShow[DFiShow$Time >= startDatePoint(),]
                        DFiShow <- DFiShow[DFiShow$Time <= endDatePoint() + days(1),]
                        
                }
                
                if (dim(DFiShow)[1] != 0) {
                        
                        max_shown <- as.numeric(input$item_number)
                        
                        if (input$view == "end"){
                                DFiShow <- tail(DFiShow, max_shown)
                        } else if (input$view == "date") {
                                DFiShow <- DFiShow[DFiShow$Time >= datePoint(),]
                                DFiShow <- head(DFiShow, max_shown)
                        } else if (input$view == "date past") {
                                DFiShow <- DFiShow[DFiShow$Time <= datePoint() + days(1),]
                                DFiShow <- tail(DFiShow, max_shown)
                        }
                        
                        # New show newest on top
                        DFiShow <- dplyr::arrange(DFiShow, desc(Time), Item)
                        DFiShow$Week <- paste0("W_", strftime(DFiShow$Time, format = "%V", tz = "CET"), sep = "")
                        DFiShow$Wday <- lubridate::wday(DFiShow$Time, label = TRUE)
                        DFiShow$Year <- as.character(lubridate::year(DFiShow$Time))
                        DFiShow$Date <- format(DFiShow$Time, format='%Y-%m-%d')
                        DFiShow$Time <- format(DFiShow$Time, format='%H:%M')
                        DFiShow <- dplyr::select(DFiShow, No, Date, Time, Item, Unit, Value, Comment, Year, Week, Wday)
                        DFiShow
                } else {
                        NULL
                }
        } else {
                NULL
        }}, sanitize.text.function = function(x) x)
# --