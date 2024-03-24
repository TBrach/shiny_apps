# - let the user choose a folder with the input data then load relevant data -
# <https://stackoverflow.com/questions/55941597/how-to-select-a-directory-and-output-the-selected-directory-in-r-shiny>
roots <- c(studies = "~/Boxcryptor/Dropbox (CM)/Main/studies")
shinyDirChoose(input, id = 'input_folder_asv_indiv', roots=roots, defaultRoot = "studies")

observeEvent(input$input_folder_asv_indiv, {

  
  selected_folder <- parseDirPath(roots, input$input_folder_asv_indiv)
  files_in_folder <- list.files(selected_folder)
  
  if(!all(c(sum(str_detect(files_in_folder, "asv_counts.rds")), sum(str_detect(files_in_folder, "asv_lookup.rds")),
    sum(str_detect(files_in_folder, "asv_taxonomy.rds")), sum(str_detect(files_in_folder, "asv_alignment.align"))) == 1)){
    rv$raw_data_list <- NULL
    rv$infoText <- "Could REALLY not find exactly one asv_counts.rds, asv_lookup.rds, asv_taxonomy.rds, and asv_alignment.aling file in the selected folder. No data loaded, check folder."
  } else {
    
    count_table_file <- files_in_folder[str_detect(files_in_folder, "asv_counts.rds")]
    asv_lookup_file <- files_in_folder[str_detect(files_in_folder, "asv_lookup.rds")]
    asv_taxonomy_file <- files_in_folder[str_detect(files_in_folder, "asv_taxonomy.rds")]
    asv_alignment_file <- files_in_folder[str_detect(files_in_folder, "asv_alignment.align")]
    file_list <- list(count_table_file, asv_lookup_file, asv_taxonomy_file, asv_alignment_file)
    raw_data_list <- lapply(file_list[1:3], function(c_file){
      cm.read_data(file.path(selected_folder, c_file))
    })
    raw_data_list[[4]] <- seqinr::read.alignment(file.path(selected_folder, asv_alignment_file), format = "fasta")
    names(raw_data_list) <- c("count_table", "asv_lookup", "asv_taxonomy", "asv_alignment")
    asvlu <- raw_data_list[["asv_lookup"]]
    if (!all(asvlu$ASV %in% colnames(raw_data_list[[1]]))){
      warning_lu <- paste(sum(!asvlu$ASV %in% colnames(raw_data_list[[1]])), "ASVs were in asv_lookup but not count table (-> removed).")
      asvlu <- filter(asvlu, ASV %in% colnames(raw_data_list[[1]]))
      raw_data_list[["asv_lookup"]] <- asvlu
    } else {
      warning_lu <- ""
    }
    asval <- raw_data_list[["asv_alignment"]]
    alignment_sequences <- asval$seq
    names(alignment_sequences) <- asval$nam
    seqs_before <- length(alignment_sequences)
    alignment_sequences <- alignment_sequences[colnames(raw_data_list[[1]])]
    seqs_after <- length(alignment_sequences)
    if (seqs_after != seqs_before){
      warning_ali <- paste(seqs_before - seqs_after, "ASVs were not in count table but alignment (-> removed).")
    } else {
      warning_ali <- ""
    }
    asval_filt <- seqinr::as.alignment(nb = length(alignment_sequences), nam = names(alignment_sequences),
                                       seq = alignment_sequences, com = NA)
    raw_data_list[["asv_alignment"]] <- asval_filt
    # - if assignment_list is present load it also -
    if (sum(str_detect(files_in_folder, "assignment_list.rds")) == 1){
      asv_assignment_list_file <- files_in_folder[str_detect(files_in_folder, "assignment_list.rds")]
      file_list[["assignment_list"]] <- asv_assignment_list_file
      raw_data_list[["assignment_list"]] <- cm.read_data(file.path(selected_folder, asv_assignment_list_file))
    } else {
      raw_data_list[["assignment_list"]] <- NULL
    }
    # --
    rv$raw_data_list <- raw_data_list
    
    # - add a check to issue big warning if n_asvs do not fit -
    n_asv_ct <- ncol(raw_data_list[["count_table"]])
    n_asv_lu <- nrow(raw_data_list[["asv_lookup"]])
    n_asv_tax <- nrow(raw_data_list[["asv_taxonomy"]][[1]])
    n_asv_alignment <- raw_data_list[["asv_alignment"]]$nb
    if (!is.null(raw_data_list[["assignment_list"]])){
      n_asv_al <- length(raw_data_list[["assignment_list"]][["taxa_options"]])
    } else {
      n_asv_al <- NULL
    }
    asv_numbers <- c(n_asv_ct, n_asv_lu, n_asv_tax, n_asv_alignment, n_asv_al)
    names(asv_numbers) <- names(raw_data_list)
    if (length(unique(asv_numbers)) != 1){
      c_warning <- paste(". Warning: files had different numbers of asvs which can cause problems. Specifically", paste(names(asv_numbers), asv_numbers, collapse = ", "), sep = " ")
      
    } else {
      c_warning <- paste('. Number of asvs =', unique(asv_numbers))
    }
    # --
    
    rv$infoText <- paste("Loaded the files:", paste0(unlist(file_list), collapse = ", "), ".", c_warning, warning_lu, warning_ali)
  }
})

# --