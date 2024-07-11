# - Add or update button -
observeEvent(input$create_bsl, {
    
    rv$bsl_table <- NULL
    rv$infoText <- NULL
    
    # - check required inputs -
    if (is.null(input$sample_list_file)){
      rv$infoText <- "You first need to choose the sample list excel file provided by the client in 1.)."
      return()
    }
    
    if (!file.exists(input$sample_list_file$datapath)){
      rv$infoText <- "It seems the file you selected in 1.) does not exist."
      return()
    }
    
    # --
    
    # - record what user has chosen -
    user_name <- input$your_name
    study_id <- str_to_lower(input$study_id)
    
    if (str_length(study_id) < 6) {
      rv$infoText <- paste0("The given study_id: ", study_id, " is too short, should have a str_length of at least 6.")
      return()
    }
    
    c_sheet <- input$sheet
    c_skip <- input$skip
    c_range <- input$range
    sample_name_column <- input$sample_name_column
    comment_column <- input$comment_column
    # --
    
    # - for the sample_list_folder, the user can type it or slect it (selection should take preference) -
    if (!is.null(rv$dir_path)){ # NB: this was when part01_show_selected_dir.R was used but didn't work on shinyapps.io
      sample_list_folder <- rv$dir_path
    } else {
      sample_list_folder <- input$folder_with_sample_list 
    }
    
    if (str_length(sample_list_folder) < 2) {
      rv$infoText <- paste0("Please make sure you give the path to the folder with the sample list provided by the client")
      return()
    }
    # -- 
    
    
    # - do some checks on the user choices -
    if (c_range == "") {
      c_range <- NULL
    }
    
    # - Ensure skip is numeric and default to 0 if not specified -
    if (is.null(c_skip) || c_skip == "") {
      c_skip <- 0
    }
    # --
    
    
    # - read excel -
    from_client <- cm.read_excel_app(file = input$sample_list_file$datapath, sheet = c_sheet, skip = c_skip, range = c_range, col_names = TRUE)
    # --
    
    
    from_client <- from_client %>% dplyr::select(sample_name = all_of(sample_name_column), comment_client = any_of(comment_column))
    
    # - in case of cm_barcode check study_id is prefixed, if not, complain, then remove study_name prefix from sample_name -
    if (input$cm_barcode) {
      if (!all(str_detect(from_client$sample_name, paste0(study_id, "_")))){
        rv$bsl_table <- from_client
        rv$infoText <- "You selected CM barcode provided, but prefixes do not all match study name. They should, PLEASE check!"
        return() 
      }
      
      from_client$sample_name <- str_remove(from_client$sample_name, paste0(study_id, "_"))
    }
    # --
    
    
    # - Check uniqueness -
    sample_name_count <- from_client %>% dplyr::count(sample_name) %>% dplyr::arrange(desc(n)) %>% dplyr::filter(n > 1)
    
    if (nrow(sample_name_count) > 0){
      rv$bsl_table <- sample_name_count
      rv$infoText <- "sample_name not unique --> contact client, see table showing non-unique names. You could also save this table."
      return()
    }
    # - -
    
    
    # - Generate a tidied sample name without weird characters -
    from_client <- from_client %>% dplyr::mutate(sample_name_tidy = clean_string(sample_name))
    # --
    
    # - Check uniqueness again -
    sample_name_tidy_count <- from_client %>% dplyr::count(sample_name_tidy) %>% dplyr::arrange(desc(n)) %>% dplyr::filter(n > 1)
    
    if (nrow(sample_name_tidy_count) > 0){
      rv$bsl_table <- sample_name_tidy_count
      rv$infoText <- "sample_name_tidy not unique --> check your code!, see table showing non unique names. You could also save this table."
      return()
    }
    # --
    
    
    # - Shorten sample name as it could be relevant for sending to Novogene or other vendors -
    if (any(str_length(from_client$sample_name_tidy) > 3)){
      
      position_df <- lapply(str_split(from_client$sample_name_tidy, ""), function(c_splitted_name){
        c_splitted_name %>% enframe() %>% tidyr::pivot_wider(names_from = name, names_prefix = "P_", values_from = value)
      })  %>% dplyr::bind_rows()
      
      
      uniform_positions <- position_df %>% summarise_all(~ n_distinct(.) == 1) %>% pivot_longer(everything()) %>% deframe()
      
      if (any(uniform_positions)){
        n_positions <- length(uniform_positions)
        
        n_positions_to_remove <- n_positions - 3
        
        remove_positions <- which(uniform_positions)
        
        if (length(remove_positions) > n_positions_to_remove){
          
          if (input$left){
            remove_positions <- remove_positions[1:n_positions_to_remove]
          } else {
            remove_positions <- remove_positions[(length(remove_positions) - n_positions_to_remove + 1):length(remove_positions)]
          }
          
        }
        
        position_df <- position_df %>% dplyr::select(!any_of(names(remove_positions)))
        
        from_client$sample_name_shortened <- position_df %>% mutate_all(~replace_na(., "")) %>% pmap_chr(~paste0(..., collapse = ""))
        
      }
      
    } else {
      from_client$sample_name_shortened <- from_client$sample_name_tidy
    }
    
    # -- Check uniqueness again (should not have changed) --
    sample_name_shortened_count <- from_client %>% dplyr::count(sample_name_shortened) %>% dplyr::arrange(desc(n)) %>% dplyr::filter(n > 1)
    
    if (nrow(sample_name_shortened_count) > 0){
      rv$bsl_table <- sample_name_shortened_count
      rv$infoText <- "sample_name_shortened not unique --> check your code!, see table showing non unique names. You could also save this table."
      return()
    }
    # -- --
    # --
    
    from_client <- from_client %>% dplyr::mutate(sample_code = paste0(study_id, "_", sample_name_tidy),
                                                 sample_code_shortened = paste0(study_id, "_", sample_name_shortened)) %>% dplyr::select(any_of(c("sample_code", "sample_name", "comment_client", "sample_code_shortened")))
    
    
    if (input$shorten){
      from_client$sample_code <- from_client$sample_code_shortened 
    } 
    
    
    
    benchling_sample_list <- from_client %>% dplyr::select(any_of(c("sample_code", "sample_name", "comment_client", "sample_code_shortened")))
    
    if(is.null(c_sheet)){c_sheet <- "NULL"}
    if(is.null(c_range)){c_range <- "NULL"}
    if(is.null(c_skip)){c_skip <- "NULL"}
    if(is.null(user_name)){user_name <- "NULL"}
    if(is.null(sample_list_folder)){sample_list_folder <- "NULL"}
    formatted_time <- format(now(), "%Y-%m-%d %H:%M:%S")
    
    info_add <- tibble("sample_list_file" = c(input$sample_list_file$name, rep(NA, nrow(benchling_sample_list) - 1)),
                       "sample_list_folder" = c(sample_list_folder, rep(NA, nrow(benchling_sample_list) - 1)),
                       "study_id" = c(study_id, rep(NA, nrow(benchling_sample_list) - 1)),
                       "user" = c(user_name, rep(NA, nrow(benchling_sample_list) - 1)),
                       "date_time" = c(formatted_time, rep(NA, nrow(benchling_sample_list) - 1)),
                       "sheet" = c(c_sheet, rep(NA, nrow(benchling_sample_list) - 1)),
                       "range" = c(c_range, rep(NA, nrow(benchling_sample_list) - 1)),
                       "skip" = c(c_skip, rep(NA, nrow(benchling_sample_list) - 1)),
                       "sample_name_column" = c(sample_name_column, rep(NA, nrow(benchling_sample_list) - 1)),
                       "comment_column" = c(comment_column, rep(NA, nrow(benchling_sample_list) - 1)),
                       "cm_barcode" = c(input$cm_barcode, rep(NA, nrow(benchling_sample_list) - 1)),
                       "shorten" = c(input$shorten, rep(NA, nrow(benchling_sample_list) - 1)),
                       "left" = c(input$left, rep(NA, nrow(benchling_sample_list) - 1)))
    
    benchling_sample_list <- benchling_sample_list %>% dplyr::bind_cols(info_add)
    
    
    
    rv$bsl_table <- benchling_sample_list
    rv$infoText <- paste0("Benchling sample list has been generated and is ready for saving in the next step, see shown table for a check.")
    # --
    
    
    # - Next save the benchling_sample_list -
    # output_path <- rv$dir_path
    # 
    # save_name <- paste0("benchling_sample_list", study_id, ".xlsx")
    # writexl::write_xlsx(x = benchling_sample_list, path = file.path(output_path, save_name), col_names = TRUE, format_headers = FALSE)
    # 
    # rv$infoText <- paste0("Hopfully saved ", save_name, " in ", output_path)
    
  
    # --
    
    
})
# --


