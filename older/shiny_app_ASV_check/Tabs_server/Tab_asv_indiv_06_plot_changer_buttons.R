# - Add or update button -
observeEvent(input$show_asv, {
  
  if (is.null(rv$raw_data_list)){
    rv$infoText <- "Sorry, no data loaded"
  } else if (is.null(rv$asv_counts_plots)){
    rv$infoText <- "Sorry, you have to calculate ASV data first"
  } else if (!input$ASV_name %in% names(rv$asv_counts_plots)){
    rv$infoText <- "Sorry, the given ASV name is not a name of a actual ASV"
  } else {
    rv$c_asv_name <- input$ASV_name
    rv$infoText <- paste0("Showing ASV: ", rv$c_asv_name, ". Last ASV:", names(rv$asv_counts_plots)[length(rv$asv_counts_plots)])
  }
})


observeEvent(input$next_asv, {
  
  if (is.null(rv$raw_data_list)){
    rv$infoText <- "Sorry, you have to load data first"
  } else if (is.null(rv$asv_counts_plots)){
    rv$infoText <- "Sorry, you have to calculate ASV data first"
  } else {
    c_asv_name <- rv$c_asv_name
    c_index <- which(names(rv$asv_counts_plots) == c_asv_name)
    if (c_index < length(rv$asv_counts_plots)){
      c_index <- c_index + 1
    } else {
      c_index <- 1
    }
    rv$c_asv_name <- names(rv$asv_counts_plots)[c_index]
    updateTextInput(session, inputId = "ASV_name",
                    value = rv$c_asv_name
    )
    rv$infoText <- paste0("Showing ASV: ", rv$c_asv_name, ". Last ASV:", names(rv$asv_counts_plots)[length(rv$asv_counts_plots)])
  }
})


observeEvent(input$previous_asv, {
  
  if (is.null(rv$raw_data_list)){
    rv$infoText <- "Sorry, you have to load data first"
  } else if (is.null(rv$asv_counts_plots)){
    rv$infoText <- "Sorry, you have to calculate ASV data first"
  } else {
    c_asv_name <- rv$c_asv_name
    c_index <- which(names(rv$asv_counts_plots) == c_asv_name)
    if (c_index > 1){
      c_index <- c_index - 1
    } else {
      c_index <- length(rv$asv_counts_plots)
    }
    rv$c_asv_name <- names(rv$asv_counts_plots)[c_index]
    updateTextInput(session, inputId = "ASV_name",
                    value = rv$c_asv_name
    )
    rv$infoText <- paste0("Showing ASV: ", rv$c_asv_name, ". Last ASV:", names(rv$asv_counts_plots)[length(rv$asv_counts_plots)])
  }
})


                