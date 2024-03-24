# - Add or update button -
observeEvent(input$create_word, {
    
    rv$lab_table <- NULL
    rv$infoText <- NULL
    
    # - check required inputs are there -
    if (is.null(rv$default_lab_plans)){
        rv$infoText <- "No default lab plans were loaded, meaning rv$default_lab_plans was NULL."
        return()
    }
    if (is.null(rv$choice_combi_df)){
        rv$infoText <- "No choice_combi_df was loaded, meaning rv$choice_combi_df was NULL."
        return()
    }
    
    default_lab_plans <- rv$default_lab_plans
    choice_combi_df <- rv$choice_combi_df
    # --
    
    # - record what user has chosen -
    sample_type <- input$sample_type
    provided <- input$provided
    data_type <- input$data_type
    sequencing_provider <- input$sequencing_provider
    date <- input$date
    # --
    
    
    # - check if there is a default lab plan for this choice -
    c_protocol_name <- paste(sample_type, data_type, sequencing_provider, sep = "_")
    if (!c_protocol_name %in% choice_combi_df$name){
        rv$infoText <- "There is no default lab plan for the choice combination you took. Please check choices, if correct, let's talk:)."
        return()
    }
    # --
    
    
    c_actual_protocol_name <- choice_combi_df$protocol_name[choice_combi_df$name == c_protocol_name]
    c_df <- default_lab_plans[[c_actual_protocol_name]]
    
    # - remove loading and extraction if "extracted DNA" provided -
    if (input$provided == "extracted DNA") {
        c_df <- c_df %>% dplyr::filter(!str_detect(Protocol, "xtraction|oading"))
        add_txt <- " As extracted DNA is provided, loading and extraction protocols were removed from lab plan."
    } else {
        add_txt <- NULL
    }
    # --
    
    rv$lab_table <- c_df
    
    # - add here the part of actually generating and saving the word file -
    # Create a flextable object from rv$lab_table
    ft_lab_table <- flextable(rv$lab_table)
    
    col_widths(ft_lab_table) <- c(2, 1, 1, 1)
    
    ft_lab_table <- set_flextable_defaults(ft_lab_table, fontname = "Calibri", fontsize = 10)
    
    output_path <- "./generated_lab_plans/"
    
    save_name <- paste(as.character(date), "lab_plan.docx", sep = "_")
    
    # Save the flextable as a Word document
    flextable::save_as_docx(ft_lab_table, path = file.path(output_path, save_name))
    
    rv$infoText <- paste0("Lab table generated for choice combination ", c_protocol_name, " which refers to ", c_actual_protocol_name, ".", add_txt, " Word was saved as ", save_name, " in ",  output_path)
    # --
    
    
})
# --

# 
# # Read uploaded data frames
# uploaded_dfs <- reactive({
#   req(input$dataframes)
#   lapply(input$dataframes$datapath, readRDS)
# })
# 
# # Create Word document
# output$downloadDoc <- downloadHandler(
#   filename = "data_frame_report.docx",
#   content = function(file) {
#     doc <- read_docx()
# 
#     # Add tables to the Word document
#     for (df_name in names(uploaded_dfs())) {
#       df <- uploaded_dfs()[[df_name]]
#       tbl <- flextable(df)
#       doc <- body_add_flextable(doc, tbl)
#       doc <- body_add_par(doc, "\n")  # Add some spacing between tables
#     }
# 
#     # Save the Word document
#     print(doc, target = file)
#   }
# )


