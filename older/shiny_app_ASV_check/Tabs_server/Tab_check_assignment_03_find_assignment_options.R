# -  -
observeEvent(input$find_100PC, {
  
  if (is.null(rv$refDB)){
    rv$infoText <- "Sorry, you need to load a refDB first"
  } else if (input$asv_or_seq == ""){
    rv$infoText <- "Sorry, you need to give an ASV name or a sequence to search the refDB with"
  } else {
    rv$assignment_options <- NULL
    rv$search_seq <- NULL
    search_item <- str_trim(input$asv_or_seq)
    asv_lookup <- rv$raw_data_list$asv_lookup
    if (!is.null(asv_lookup) && search_item %in% asv_lookup$ASV){
      search_seq <- asv_lookup$sequence[asv_lookup$ASV == search_item]
    } else {
      search_seq <- search_item
    }
    refDB <- rv$refDB
    rv$search_seq <- search_seq
    assignment_options <- dplyr::filter(refDB, Seq == search_seq)
    if (nrow(assignment_options) == 0){
      rv$infoText = "Did not find any assignment options fitting 100% to your input."
    } else {
      assignment_options$in_UHGG <- str_detect(assignment_options$name_refDB, "UHGG")
      assignment_options$in_rrnDB <- str_detect(assignment_options$name_refDB, "rrnDB")
      assignment_options$n_DBs <- str_count(assignment_options$name_refDB, pattern = ",") + 1
      assignment_options$depth <- sapply(assignment_options$assignment_depth, function(c_depth){which(colnames(assignment_options)==c_depth)})
      assignment_options$depth_conformity <- sapply(assignment_options$conformity_depth, function(c_depth){which(colnames(assignment_options)==c_depth)})
      assignment_options <- dplyr::arrange(assignment_options, desc(n_DBs), desc(in_UHGG), desc(in_rrnDB), desc(depth), desc(depth_conformity), desc(n_sequences))
      assignment_options$pid <- 100
      assignment_options$n_mismatches <- 0
      assignment_options$bps <- nchar(assignment_options$Seq)
      assignment_options <- dplyr::select(assignment_options, domain:species, name_refDB, pid:bps, everything(), Seq)
      rv$infoText = paste0("Found ", nrow(assignment_options), " assignment options with a pid (% identity) of 100%")
      rv$assignment_options <- assignment_options
    }
    
    
    
  }
})



observeEvent(input$align, {
        
        if (is.null(rv$refDB)){
                rv$infoText <- "Sorry, you need to load a refDB first"
        } else if (input$asv_or_seq == ""){
                rv$infoText <- "Sorry, you need to give an ASV name or a sequence to search the refDB with"
        } else {
                rv$assignment_options <- NULL
                rv$search_seq <- NULL
                search_item <- str_trim(input$asv_or_seq)
                asv_lookup <- rv$raw_data_list$asv_lookup
                if (!is.null(asv_lookup) && search_item %in% asv_lookup$ASV){
                        search_seq <- asv_lookup$sequence[asv_lookup$ASV == search_item]
                } else {
                        search_seq <- search_item
                }
                refDB <- rv$refDB
                
                if (input$align_to == "UHGG + rrnDB"){
                        refDB <- dplyr::filter(refDB, str_detect(name_refDB, "UHGG|rrnDB"))
                } else if (input$align_to == "UHGG") {
                        refDB <- dplyr::filter(refDB, str_detect(name_refDB, "UHGG"))
                } else if (input$align_to == "rrnDB") {
                        refDB <- dplyr::filter(refDB, str_detect(name_refDB, "rrnDB"))
                } else if (input$align_to == "entries of tax you enter"){
                        align_tax <- str_trim(input$align_tax)
                        res_mat <- sapply(dplyr::select(refDB, domain:species), function(c_tax){
                          str_detect(c_tax, align_tax)
                        })
                        hit_indexes <- rowSums(res_mat, na.rm = TRUE) > 0
                        # entry_find_list <- lapply(dplyr::select(refDB, domain:species), function(c_tax){
                        #         str_detect(c_tax, align_tax)
                        # })
                        # indexes <- Reduce(`|`, entry_find_list)
                        # indexes[is.na(indexes)] <- FALSE
                        refDB <- dplyr::filter(refDB, hit_indexes)
                        
                }
                
                if (nrow(refDB) == 0){
                        rv$infoText = "no refDB entries found to align to"
                        return()
                }
                
                refDB_unique <- unique(dplyr::select(refDB, seq_ID, Seq))
                
                not_only_letters <- str_detect(search_seq, "[^A-Za-z]")
                if (!not_only_letters){
                  not_allowed_letters <- setdiff(LETTERS, names(IUPAC_CODE_MAP))
                  not_only_letters <- str_detect(search_seq, paste(not_allowed_letters, collapse = "|"))
                }
                
                
                
                if (not_only_letters){
                        rv$infoText <- "Seems not to be a useful search_seq, please check it"
                        return()
                }
                
                rv$search_seq <- search_seq
                search_seq_dna <- DNAString(search_seq)
                
                pa <- Biostrings::pairwiseAlignment(pattern = DNAStringSet(refDB_unique$Seq), subject = search_seq_dna, type = 'global')
                refDB_unique$pid <- pid(pa)
                refDB_unique$n_mismatches <- nmismatch(pa)
                # - Currently show all options with pids max 5% below max pid -
                max_pid <- max(refDB_unique$pid)
                pid_thresh <- max_pid - 5
                n_sequences <- nrow(refDB_unique)
                refDB_unique <- dplyr::filter(refDB_unique, pid >= pid_thresh)
                # --
                sequences <- refDB_unique$Seq
                
                assignment_options <- refDB[refDB$Seq %in% sequences, , drop = FALSE]
                
                if (nrow(assignment_options) == 0){
                        rv$infoText = "Did not find any assignment options"
                } else {
                  assignment_options$in_UHGG <- str_detect(assignment_options$name_refDB, "UHGG")
                  assignment_options$in_rrnDB <- str_detect(assignment_options$name_refDB, "rrnDB")
                  assignment_options$n_DBs <- str_count(assignment_options$name_refDB, pattern = ",") + 1
                  assignment_options$depth <- sapply(assignment_options$assignment_depth, function(c_depth){which(colnames(assignment_options)==c_depth)})
                  assignment_options$depth_conformity <- sapply(assignment_options$conformity_depth, function(c_depth){which(colnames(assignment_options)==c_depth)})

                  assignment_options$pid <- refDB_unique$pid[match(assignment_options$Seq, refDB_unique$Seq)]
                  assignment_options$n_mismatches <- refDB_unique$n_mismatches[match(assignment_options$Seq, refDB_unique$Seq)]
                  assignment_options <- dplyr::arrange(assignment_options, desc(pid), desc(n_DBs), desc(in_UHGG), desc(in_rrnDB), desc(depth), desc(depth_conformity), desc(n_sequences))
                  assignment_options$bps <- nchar(assignment_options$Seq)
                  assignment_options <- dplyr::select(assignment_options, domain:species, name_refDB, pid:bps, everything(), Seq)
                  rv$infoText = paste0("Found ", nrow(dplyr::filter(assignment_options, pid == max_pid)), " assignment options with a pid of ", assignment_options$pid[1], " from ", nrow(refDB), " references by aligning to ", n_sequences, " sequences.")
                  rv$assignment_options <- assignment_options
                }
       
        }
})


observeEvent(input$show_search_seq, {
        
        
        if (input$asv_or_seq == ""){
                rv$infoText <- "Sorry, you need to give an ASV name or a sequence to search the refDB with"
        } else {
                rv$search_seq <- NULL
                search_item <- str_trim(input$asv_or_seq)
                asv_lookup <- rv$raw_data_list$asv_lookup
                if (!is.null(asv_lookup) && search_item %in% asv_lookup$ASV){
                        search_seq <- asv_lookup$sequence[asv_lookup$ASV == search_item]
                } else {
                        search_seq <- search_item
                }
                rv$search_seq <- search_seq
                rv$infoText <- "showing search_seq"
        }
})




