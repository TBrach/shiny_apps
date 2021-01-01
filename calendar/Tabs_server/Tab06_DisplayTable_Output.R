# - use render Table to display calendar table -
output$calendarTable <- renderTable({
        if(!is.null(rv$DFk)){
                DFkShow <- cbind(No = 1:nrow(rv$DFk), rv$DFk)
                
                if(isTRUE(input$search)){
                        DFkShow <- DFkShow[grep(pattern = input$wordsearch, DFkShow$Name),] 
                        
                }
                
                if (dim(DFkShow)[1] != 0) {
                        
                        max_shown <- as.numeric(input$max_shown)
                        
                        if (input$view == "end"){
                                DFkShow <- tail(DFkShow, max_shown)
                        } else if (input$view == "plot date") {
                                DFkShow <- DFkShow[DFkShow$startTime >= plotDate(),]
                                DFkShow <- head(DFkShow, max_shown)
                        } else if (input$view == "plot date past") {
                                DFkShow <- DFkShow[DFkShow$startTime <= plotDate() + days(1),]
                                DFkShow <- tail(DFkShow, max_shown)
                        }
                        
                        # New show newest on top
                        DFkShow <- dplyr::arrange(DFkShow, desc(startTime))
                        DFkShow$Week <- paste0("W_", strftime(DFkShow$startTime, format = "%V", tz = "CET"), sep = "")
                        DFkShow$Wday <- lubridate::wday(DFkShow$startTime, label = TRUE)
                        DFkShow$Date <- format(DFkShow$startTime, format='%Y-%m-%d')
                        DFkShow$Time <- format(DFkShow$startTime, format='%H:%M')
                        DFkShow$endTime <- format(DFkShow$endTime, format='%Y-%m-%d %H:%M')
                        DFkShow$Duration <- as.character(DFkShow$Duration)
                        DFkShow <- dplyr::select(DFkShow, No, Week, Wday, Name, Comment, Date, Time, Minutes = Duration, End = endTime, Categ. = Color)
                        DFkShow
                } else {
                        NULL
                }
        } else {
                NULL
        }}, sanitize.text.function = function(x) x)
# --