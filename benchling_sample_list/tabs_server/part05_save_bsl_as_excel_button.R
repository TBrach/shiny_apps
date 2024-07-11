# - save word on computer -
output$save_bsl <- downloadHandler(
    # downloadHandler takes two arguments, both functions
    # the filename function:
    
    
    filename = function() {
        study_id <- str_to_lower(input$study_id)
        paste0("benchling_sample_list_", study_id, ".xlsx")
    },
    
    content = function(file) {
        # rv$infoText <- NULL # does not work
        if(is.null(rv$bsl_table)){
            rv$infoText <- "No benchling_sample_table was generated yet for download."
            return()
        } 
        
        study_id <- str_to_lower(input$study_id)
        
        if (str_length(study_id) < 6) {
          rv$infoText <- paste0("The given study_id: ", study_id, " is too short, please update.")
          return()
        }
        
        rv$infoText <- paste0("Downloaded ", paste0("benchling_sample_list_", study_id, ".xlsx"), " to chosen directory")
        
        writexl::write_xlsx(rv$bsl_table, path = file, col_names = TRUE, format_headers = FALSE)
    }
)
# --