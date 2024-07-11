# - save word on computer -
output$save_word <- downloadHandler(
    # downloadHandler takes two arguments, both functions
    # the filename function:
    
    
    filename = function() {
        study_name <- input$study_name
        paste0("Lab plan ", study_name, ".docx")
    },
    
    content = function(file) {
        # rv$infoText <- NULL # does not work
        if(is.null(rv$lab_plan_word)){
            rv$infoText <- "No word was generated yet for download."
            return()
        } else {
            rv$infoText <- "Downloaded lab plan word to chosen directory"
        }
        print(rv$lab_plan_word, target = file)
    }
)
# --