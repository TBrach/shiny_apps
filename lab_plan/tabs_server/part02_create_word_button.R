# - reflect the selected output path -
observe({
    if (!is.null(input$dir)) {
        output$selected_dir <- renderPrint({
            dir_path <- parseDirPath(c(home = '~', studies = "~/Boxcryptor/OneDrive-SharedLibraries-ClinicalMicrobiomics"), input$dir)
            rv$dir_path <- dir_path
            dir_path
        })
    } else {
       dir_path <- NULL
       rv$dir_path <- dir_path
       dir_path
    }
})
# --



# - Add or update button -
observeEvent(input$create_word, {
    
    rv$lab_table <- NULL
    rv$infoText <- NULL
    
    # - check required inputs are there including dir_path -
    if (is.null(rv$default_lab_plans)){
        rv$infoText <- "No default lab plans were loaded, meaning rv$default_lab_plans was NULL."
        return()
    }
    if (is.null(rv$choice_combi_df)){
        rv$infoText <- "No choice_combi_df was loaded, meaning rv$choice_combi_df was NULL."
        return()
    }
    if (is.null(rv$dir_path) || identical(rv$dir_path, character(0))){
        rv$infoText <- "You first need to choose the output directory where the word file will be saved."
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
    
    # - The part of making the word file using officer and flextable -
    
    # -- settings used for the flextable later --
    A4 <- list(h = 9.72, w = 6.3) # NB: calc_fig_dims_a4 in cm.reports
    # -- -- 
    
    study_name <- str_to_lower(input$study_name)
    
    if (str_length(study_name) != 6){
        rv$infoText <- "study_name was not six characters long, change!"
        return()
    }
    
    lab_lead <- input$lab_lead
    background <- input$background
    clinical_protocol <- input$clinical_protocol
    sample_handling <- input$sample_handling
    
    
    
    doc <- officer::read_docx(path = "./input_at_start/CM_template_simple.docx")
    # doc <- officer::read_docx(path = "./input_at_start/CM_template.docx")
    # doc <- officer::read_docx()
    
    doc <- body_add_par(doc, "Study name", style = "CM 2 ni")
    doc <- body_add_par(doc, study_name, style = "CM 0")

    doc <- body_add_par(doc, "Lab lead", style = "CM 2 ni")
    doc <- body_add_par(doc, lab_lead, style = "CM 0")

    doc <- body_add_par(doc, "Background and objectives", style = "CM 2 ni")
    doc <- body_add_par(doc, background, style = "CM 0")

    doc <- body_add_par(doc, "Clinical protocol", style = "CM 2 ni")
    doc <- body_add_par(doc, clinical_protocol, style = "CM 0")

    doc <- body_add_par(doc, "Sample handling after analysis", style = "CM 2 ni")
    doc <- body_add_par(doc, sample_handling, style = "CM 0")

    # two empty lines, could also be done with fp_p in body_add_par
    doc <- body_add_par(doc, "", style = "CM 0")
    doc <- body_add_par(doc, "", style = "CM 0")
    
    
    # start with the default theme  
    set_flextable_defaults(theme_fun = "cm.table_theme")
    
    # Create a flextable object from rv$lab_table
    ft_lab_table <- rv$lab_table %>% flextable::flextable()

    
    #ft_lab_table <- cm.table_theme(ftable = ft_lab_table)
    
    ft_lab_table <- ft_lab_table %>% flextable::width(width = c(0.4, 0.2, 0.2, 0.2) * A4$w) %>% flextable::fontsize(size = 10, part = "all")  %>% flextable::bold(part = "header")  %>% flextable::valign(j = 1:4, valign = "center", part = "header")
    
    # -- this was how the styles were made first --
    # ft_lab_table <- flextable::fontsize(ft_lab_table, size = 10)
    # ft_lab_table <- flextable::font(ft_lab_table, fontname = "Calibri")
    # 
    # # Set the font size and font name for the headers
    # ft_lab_table <- flextable::bold(ft_lab_table, part = "header")
    # ft_lab_table <- flextable::fontsize(ft_lab_table, size = 10, part = "header")
    # ft_lab_table <- flextable::font(ft_lab_table, fontname = "Calibri", part = "header")
    # 
    # # Set the background color of the rows
    # ft_lab_table <- flextable::bg(ft_lab_table, bg = ifelse(seq_len(nrow(rv$lab_table)) %% 2 == 0, "white", "gray"), part = "body")
    # 
    # # Add borders to all cells
    # ft_lab_table <- flextable::border(ft_lab_table, border = fp_border(color="black"), part = "all")
    # -- --
    
    # Add the table to the Word document
    doc <- body_add_flextable(doc, ft_lab_table)
    
    # output_path <- "./generated_lab_plans/"
    output_path <- rv$dir_path
    
    # save_name <- paste(as.character(date), "lab_plan.docx", sep = "_")
    save_name <- paste0("Lab plan ", study_name, ".docx")
    
    print(doc, target = file.path(output_path, save_name))
    
    # Save the flextable as a Word document
    # flextable::save_as_docx(ft_lab_table, path = file.path(output_path, save_name))
    
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


