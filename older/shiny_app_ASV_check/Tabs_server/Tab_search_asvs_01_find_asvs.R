# - Add or update button -
observeEvent(input$search_asvs, {
  
  if (is.null(rv$raw_data_list)){
    rv$infoText <- "Sorry, you need to load data first"
  } else if (input$search_asv_term == ""){
    rv$infoText <- "You need to give a search term like a sequence or a taxnomy."
  } else {
    rv$search_asv_table
    search_term <- str_trim(input$search_asv_term)
    tax <-  rv$raw_data_list[["asv_taxonomy"]]
    full_tax <- tax$FullTax
    asv_lookup <- rv$raw_data_list$asv_lookup
    # - First assume the user gave a taxonomy term and you want to inlcude the taxonomic options in the search -
    al <- rv$raw_data_list$assignment_list
    tax_df_before_after_options <- al$tax_df_before_after_options
    res_mat <- sapply(dplyr::select(tax_df_before_after_options, domain:species), function(c_tax){
      str_detect(c_tax, search_term)
    })
    hit_indexes <- which(rowSums(res_mat, na.rm = TRUE) > 0)
    
    if (length(hit_indexes) > 0){
      hit_asvs <- sort(unique(tax_df_before_after_options$ASV[hit_indexes]))
      
      out_table <- full_tax[hit_asvs,] %>% rownames_to_column("ASV")
      out_table$pid <- NA
      out_table$n_mismatches <- NA
      out_table$Seq <- asv_lookup$sequence[match(out_table$ASV, asv_lookup$ASV)]
      out_table <- dplyr::select(out_table, ASV, domain:species, everything())
      # --
    } else {
      # - if nothing hit assume it was a sequence and do an alignment to all ASV-
      search_term <- str_to_upper(search_term)
      not_only_letters <- str_detect(search_term, "[^A-Za-z]")
      if (!not_only_letters){
        not_allowed_letters <- setdiff(LETTERS, names(IUPAC_CODE_MAP))
        not_only_letters <- str_detect(search_term, paste(not_allowed_letters, collapse = "|"))
      }
      if (!not_only_letters){
        pa <- Biostrings::pairwiseAlignment(pattern = DNAStringSet(asv_lookup$sequence), subject = DNAString(search_term), type = 'global')
        asv_lookup$pid <- pid(pa)
        asv_lookup$n_mismatch <- nmismatch(pa)
        out_table <- full_tax %>% rownames_to_column("ASV")
        out_table$pid <- asv_lookup$pid[match(out_table$ASV, asv_lookup$ASV)]
        out_table$n_mismatches <- asv_lookup$n_mismatch[match(out_table$ASV, asv_lookup$ASV)]
        out_table$Seq <- asv_lookup$sequence[match(out_table$ASV, asv_lookup$ASV)]
        out_table <- dplyr::arrange(out_table, desc(pid))
        out_table <- dplyr::select(out_table, ASV, domain:species, everything())
      } else {
        out_table <- NULL
      }
      # --
    }
    
    
    if (is.null(out_table)){
      rv$search_asv_table <- NULL
      rv$infoText <- "No ASVs found"
    } else {
      rv$search_asv_table <- out_table
      rv$infoText <- "Found ASV table will be shown"
    }
    
    
  }
  
})
# --