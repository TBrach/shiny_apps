# - Add or update button -
observeEvent(input$show_group, {
        
        if (is.null(rv$raw_data_list)){
                rv$infoText <- "Sorry, you have to load data first"
        } else if (is.null(rv$group_list)){
                rv$infoText <- "Sorry, you have to calculate groups first"
        } else if (!input$group_name %in% names(rv$group_list)){
                rv$infoText <- "Sorry, the given group_name is not a name of a group"
        } else {
                rv$c_group_name <- input$group_name
                rv$infoText <- paste("showing group:", input$group_name)
        }
})


observeEvent(input$next_group, {
        
        if (is.null(rv$raw_data_list)){
                rv$infoText <- "Sorry, you have to load data first"
        } else if (is.null(rv$group_list)){
                rv$infoText <- "Sorry, you have to calculate groups first"
        } else {
                c_group_name <- rv$c_group_name
                c_index <- which(names(rv$group_list) == c_group_name)
                if (c_index < length(rv$group_list)){
                        c_index <- c_index+1
                } else {
                        c_index <- 1
                }
                rv$c_group_name <- names(rv$group_list)[c_index]
                updateTextInput(session, inputId = "group_name",
                                value = rv$c_group_name
                )
                rv$infoText <- paste("showing group:", rv$c_group_name)
        }
})


observeEvent(input$previous_group, {
        
        if (is.null(rv$raw_data_list)){
                rv$infoText <- "Sorry, you have to load data first"
        } else if (is.null(rv$group_list)){
                rv$infoText <- "Sorry, you have to calculate groups first"
        } else {
                c_group_name <- rv$c_group_name
                c_index <- which(names(rv$group_list) == c_group_name)
                if (c_index > 1){
                        c_index <- c_index - 1
                } else {
                        c_index <- length(rv$group_list)
                }
                rv$c_group_name <- names(rv$group_list)[c_index]
                updateTextInput(session, inputId = "group_name",
                                value = rv$c_group_name
                )
                rv$infoText <- paste("showing group:", rv$c_group_name)
        }
})


                