# - use render Table to display learn list -
output$learnTable <- renderTable({
        if(!is.null(rv$DFl)){
                DFlShow <- cbind(No = 1:nrow(rv$DFl), rv$DFl)
                
                if(isTRUE(input$search)){
                        DFlShow <- DFlShow[grep(pattern = input$wordsearch, DFlShow$Name),] 
                        
                }
                
                if(dim(DFlShow)[1] != 0 && isTRUE(input$search_cat)){
                        
                        list_categories <- DFlShow$Category
                        list_categories <- str_split(list_categories, pattern = ",")
                        list_categories <- lapply(list_categories, str_trim)
                        
                        search_categories <- input$wordsearch_cat
                        # to remove unwanted whitespaces -
                        search_categories <- str_trim(unlist(str_split(search_categories, pattern = ",")))
                        
                        indexes <- sapply(list_categories, function(x){all(search_categories %in% x)})
                        
                        DFlShow <- DFlShow[indexes,] 
                        
                }
                
                if (dim(DFlShow)[1] != 0) {
                        
                        max_shown <- as.numeric(input$event_number)
                        
                        if (input$view == "end"){
                                DFlShow <- tail(DFlShow, max_shown)
                        } else if (input$view == "plot date") {
                                DFlShow <- DFlShow[DFlShow$startTime >= plotDate(),]
                                DFlShow <- head(DFlShow, max_shown)
                        } else if (input$view == "plot date past") {
                                DFlShow <- DFlShow[DFlShow$startTime <= plotDate() + days(1),]
                                DFlShow <- tail(DFlShow, max_shown)
                        }
                        
                        # New show newest on top
                        DFlShow <- dplyr::arrange(DFlShow, desc(startTime))
                        DFlShow$Week <- paste0("W_", strftime(DFlShow$startTime, format = "%V", tz = "CET"), sep = "")
                        #DFlShow$Wday <- lubridate::wday(DFlShow$startTime, label = TRUE)
                        DFlShow$Date <- format(DFlShow$startTime, format='%Y-%m-%d')
                        DFlShow$Time <- format(DFlShow$startTime, format='%H:%M')
                        DFlShow <- dplyr::select(DFlShow, No, Date, Time, Week, Category, Name, Description, Comment, Files)
                        DFlShow
                } else {
                        NULL
                }
        } else {
                NULL
        }}, sanitize.text.function = function(x) x)
# --