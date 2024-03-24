# - Add or update button -
observeEvent(input$calc_groups, {
        
        if (is.null(rv$raw_data_list)){
                rv$infoText <- "Sorry, you have to load data first"
        } else {
                rv$infoText <- NULL
                rv$c_group_name <- NULL
                asv_lookup <- rv$raw_data_list[["asv_lookup"]]
                asvs <- asv_lookup$sequence
                asv_names <- asv_lookup$ASV
                names(asv_names) <- asv_names
                asv_alignment <- rv$raw_data_list[["asv_alignment"]]
                
                # - you could add a sanity check that alignment fits to asv_lookup -
                # alignment_sequences <- asv_alignment$seq
                # names(alignment_sequences) <- asv_alignment$nam
                # unique(sapply(alignment_sequences, nchar))
                # ass <- lapply(alignment_sequences, str_remove_all, pattern = "-")
                # ass_lu <- data.frame(ASV = names(ass), sequence = str_to_upper(unlist(ass)))
                # all(asvs == ass_lu$sequence[match(asv_names, ass_lu$ASV)])
                # --
                # - you could also add a filter option to restrict asvs -
                
                # --
                # - then calculate distances from alignment, then pid_matrix, then n_mismatch matrix -
                if (is.null(rv$n_mismatch_matrix)){
                  asv_alignment_dist <- seqinr::dist.alignment(asv_alignment)
                  #NB: ? see seqinr::dist.alignment for good infos
                  asv_alignment_dist_matrix <- as.matrix(asv_alignment_dist)
                  # -- order as asvs not as alignment --
                  asv_alignment_dist_matrix <- asv_alignment_dist_matrix[asv_names, asv_names]
                  # -- --
                  pid_matrix <- 100*(1-asv_alignment_dist_matrix^2)
                  nchars <- nchar(asvs)
                  max_length_matrix <- sapply(1:length(asvs), function(i){
                    x <- nchars
                    x[nchars[i] > x] <- nchars[i]
                    x
                  })
                  n_mismatch_matrix <- max_length_matrix * (1-pid_matrix/100)
                } else {
                  asv_alignment_dist <- seqinr::dist.alignment(asv_alignment)
                  #NB: ? see seqinr::dist.alignment for good infos
                  asv_alignment_dist_matrix <- as.matrix(asv_alignment_dist)
                  # -- order as asvs not as alignment --
                  asv_alignment_dist_matrix <- asv_alignment_dist_matrix[asv_names, asv_names]
                  
                  n_mismatch_matrix <- rv$n_mismatch_matrix
                }
                # --
                # - Then calculate the groups from the n_mismatch_matrix -
                max_mismatch <- input$max_mismatch
                n_mismatch_matrix_bin <- n_mismatch_matrix <= max_mismatch
                group_list <- apply(n_mismatch_matrix_bin, 1, function(x){
                        colnames(n_mismatch_matrix_bin)[x]
                })
                names(group_list) <- asv_names
                group_list <- group_list[sapply(group_list, length) > 1]
                # make it unique, i.e. remove entries with identical groups -
                group_list <- group_list[!duplicated(group_list)]
                included_in_other_group <- sapply(1:length(group_list), function(i){
                        any(sapply(group_list[-i], function(c_group){
                                all(group_list[[i]] %in% c_group)
                        }))
                })
                group_list <- group_list[!included_in_other_group]
                # if requested, connect groups with members that are less than max_mismatch apart:
                if (input$group_type == "connected"){
                        #group_list_exclusive <- group_list # to save also those where all members are very close to each other
                        if (length(unlist(group_list)) != length(unique(unlist(group_list)))) { # meaning some ASVs are still in serveral groups
                                while (length(unlist(group_list)) != length(unique(unlist(group_list)))){
                                        # -- find ASVs that are in several groups --
                                        multi_group_asvs <- names(table(unlist(group_list))[table(unlist(group_list)) > 1])
                                        # -- --
                                        # -- find the group the first multi_group_asv is in  --
                                        in_group <- which(sapply(group_list, function(c_list){multi_group_asvs[1] %in% c_list}))
                                        # --
                                        # - get the union group and replace with old groups -
                                        union_group <- sort(Reduce(f = "union", group_list[in_group]))
                                        group_list[[in_group[1]]] <- union_group
                                        
                                        group_list <- group_list[-in_group[-1]]
                                        names(group_list) <- sapply(group_list, `[[`, 1) # name here by first ASV even though not necessary the center
                                        # --
                                } 
                        }
                }
                group_list <- group_list[sort(names(group_list))]
                group_list <- Map(f = function(c_group, c_name){
                  c_group <- c(c_name, c_group[c_group != c_name])
                  c_group
                }, c_group = group_list, c_name = names(group_list))
                # --
                # - Calculate the count correlation plots for the groups -
                count_table <- rv$raw_data_list[["count_table"]]
                group_counts_plots <- lapply(group_list, function(c_group){
                        # - this should probably be linked to a warning and is only done because you might use the app after removal of some ASVs from count table -
                        c_group <- c_group[c_group %in% colnames(count_table)]
                        # --
                        plot_data <- as.data.frame(count_table[, c_group, drop = FALSE]) %>% rownames_to_column("sample_name") # %>% cm.add_metadata(meta, join_column = "amplicon_file")
                        # - filter out samples in which all asvs are 0 -
                        not_all_zero <- apply(dplyr::select(plot_data, all_of(c_group)), 1, function(x){any(x > 0)})
                        plot_data <- dplyr::filter(plot_data, not_all_zero)
                        # --
                        plot_data <- pivot_longer(plot_data, cols = all_of(c_group), names_to = "ASV", values_to = "counts")
                        
                        
                        Tr <- ggplot(plot_data, aes(x = sample_name, y = counts))
                        Tr <- Tr +
                                geom_line(aes(group = ASV, col = ASV)) +
                                geom_point(aes(col = ASV)) +
                                scale_y_log10() +
                                theme_cowplot(8) +
                                xlab("") +
                                theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
                        Tr
                })        
                # --
                # - calculate the tree plots for the groups -
                asv_tax <- rv$raw_data_list[["asv_taxonomy"]]
                main_taxes <- asv_tax$Tax
                main_taxes <- main_taxes %>% rownames_to_column("ASV")
                full_tax <- asv_tax$FullTax
                ra_table <- cm.relative_abundance(count_table)
                group_tree_plots <- lapply(group_list, function(c_group){
                        # print(c_group)
                        # filter distances
                        c_dist_matrix <- asv_alignment_dist_matrix[c_group, c_group]
                        c_dist <- as.dist(c_dist_matrix)
                        # calculate tree
                        #c_tree <- ape::nj(c_dist)
                        c_tree <- phangorn::midpoint(phangorn::upgma(c_dist))
                        # -- use treeio package for better plotting --
                        c_tree_treeio <- as.treedata(c_tree)#new("treedata", phylo = c_tree)
                        # you need to add @data for the plot
                        c_n_nodes <- getNodeNum(c_tree_treeio) # tips plus internal nodes
                        c_n_internal_nodes <- Nnode(c_tree_treeio, internal.only = TRUE) #only the internal
                        # generate data slot
                        original_tip_labels <- c_tree_treeio@phylo$tip.label
                        # new_tip_labels <- main_taxes[match(c_tree_treeio@phylo$tip.label, main_taxes$ASV),]
                        # new_tip_labels <- apply(dplyr::select(new_tip_labels, ASV, MainTax), 1, function(x){paste(x, collapse = ": ")})
                        # c_tree_treeio@phylo$tip.label <- new_tip_labels
                        node_data <- tibble(node = 1:c_n_nodes, node_names = c(c_tree_treeio@phylo$tip.label, rep(NA, c_n_internal_nodes)))
                        
                        c_ra_sums <- colSums(ra_table[, original_tip_labels])
                        c_ra_max <- apply(ra_table[, original_tip_labels], 2, max)
                        
                        node_data$ra_sums <- c(c_ra_sums, rep(NA, c_n_internal_nodes))
                        node_data$ra_max <- c(c_ra_max, rep(NA, c_n_internal_nodes))
                        node_data$Size <- 5*node_data$ra_max/max(node_data$ra_max, na.rm = TRUE)
                        node_data$main_tax <- c(main_taxes$MainTax[match(original_tip_labels, main_taxes$ASV)], rep(NA, c_n_internal_nodes))
                        node_data$annotation_level <- c(main_taxes$Level[match(original_tip_labels, main_taxes$ASV)], rep(NA, c_n_internal_nodes))
                        
                        
                        c_tree_treeio@data <- node_data
                        # print(c_group)
                        Tr <- ggtree(c_tree_treeio) +
                                geom_label(aes(x = branch, label = node_names), fill = "lightgray") +
                                #ggtree::geom_tiplab() + # caused surprising issue
                                geom_tippoint(aes(size = Size, col = main_tax)) +
                                guides(size = "none") +
                                # theme_cowplot(8) +
                                #ggplot2::xlim(0, 0.06) +
                                theme(legend.title = element_blank(),
                                       legend.position = "top")
                        Tr
                        
                })
                # --
                # - if trees suck, maybe alternative is PCoA -
                # group_pcoa_plots <- lapply(group_list, function(c_group){
                #         # filter distances
                #         c_dist_matrix <- asv_alignment_dist_matrix[c_group, c_group]
                #         c_dist <- as.dist(c_dist_matrix)
                #         # calculate tree
                #         pcoa_coords <- cm.prepare_pcoa(c_dist)
                #         pcoa_labels <- attr(pcoa_coords, "labels")
                #         
                #         pcoa_plot <- ggplot(pcoa_coords, aes(x = x, y = y))
                #         pcoa_plot <- pcoa_plot +
                #                 geom_point(aes_string(col = "rowname")) +
                #                 labs(x = pcoa_labels["x"], y = pcoa_labels["y"]) +
                #                 theme_cowplot(8)
                #         pcoa_plot
                #         
                # })
                # --
                # - calculate the n_mismatch tables for the groups -
                mismatch_table_list <- lapply(group_list, function(c_group){
                        c_mmm <- n_mismatch_matrix[c_group, c_group]
                        c_mm_df <- as.data.frame(c_mmm)
                        c_mm_df <- c_mm_df %>% rownames_to_column("ASV")
                        c_main_taxes <- main_taxes[match(c_mm_df$ASV, main_taxes$ASV),]
                        # c_mm_df <- merge(c_mm_df, main_taxes, by = "ASV")
                        c_mm_df <- cbind(c_mm_df, dplyr::select(c_main_taxes, -ASV))
                        c_mm_df$ra_sum <- colSums(ra_table[, c_mm_df$ASV])
                        c_mm_df$ra_max <- apply(ra_table[, c_mm_df$ASV], 2, max)
                        c_mm_df$n_bps <- nchar(asv_lookup$sequence[match(c_mm_df$ASV, asv_lookup$ASV)])
                        c_mm_df$Seq <- asv_lookup$sequence[match(c_mm_df$ASV, asv_lookup$ASV)]
                        c_mm_df
                })
                # --
                
                # - if improvement_list is present, make taxa_option_list -
                if (!is.null(rv$raw_data_list[["assignment_list"]])){
                        al <- rv$raw_data_list[["assignment_list"]]
                        tax_df_before_after_options <- al[["tax_df_before_after_options"]]
                        taxa_option_list <- lapply(group_list, function(c_group){
                          c_df <- dplyr::filter(tax_df_before_after_options, ASV %in% c_group)
                          c_df$ASV <- factor(c_df$ASV, levels = c_group)
                          c_df <- dplyr::arrange(c_df, ASV)
                          dplyr::select(c_df, ASV:status, pid:name_refDB, n_ass = n_assignments, n_seqs = n_sequences, conformity_depth, seq_ID, ass_ID = assignment_ID, gtdb_conform, FW, RV, Seq)
                        })
                        
                        # taxa_options <- al[["taxa_options"]]
                        # taxa_option_list <- lapply(group_list, function(c_group){
                        #         c_to <- taxa_options[c_group]
                        #         c_df <- do.call("rbind", c_to)
                        #         # for simplicity redo seq_id, assignment_id, add entry_id
                        #         amplis <- unique(c_df$Seq)
                        #         seq_id_lu <- data.frame(Seq = amplis, seq_ID = paste0("Seq_", sprintf(fmt = paste0("%0.", floor(log10(length(amplis))) + 1,  "d"), 1:length(amplis))))
                        #         c_df$seq_ID <- seq_id_lu$seq_ID[match(c_df$Seq, seq_id_lu$Seq)]
                        #         assignment_lu <- unique(c_df[, c("domain", "phylum", "class", "order", "family", "genus", "species")])
                        #         assignment_lu <- arrange(assignment_lu, domain, phylum, class, order, family, genus, species)
                        #         assignment_lu$assignment <- apply(assignment_lu, 1, function(x){paste0(paste(as.character(x)[!is.na(x)], collapse = ";"),";")})
                        #         assignment_lu$assignment_ID <- paste0("Ass_", sprintf(fmt = paste0("%0.", floor(log10(nrow(assignment_lu))) + 1,  "d"), 1:nrow(assignment_lu)))
                        #         c_df$assignment <- apply(dplyr::select(c_df, domain:species), 1, function(x){paste0(paste(as.character(x)[!is.na(x)], collapse = ";"),";")})
                        #         c_df$assignment_ID <- assignment_lu$assignment_ID[match(c_df$assignment, assignment_lu$assignment)]
                        #         c_df$entry <- paste(c_df$seq_ID, c_df$assignment_ID)
                        #         entry_lu <- data.frame(entry = unique(c_df$entry))
                        #         entry_lu$entry_id <- paste0("Entry_", sprintf(fmt = paste0("%0.", floor(log10(nrow(entry_lu))) + 1,  "d"), 1:nrow(entry_lu)))
                        #         c_df$entry_ID <- entry_lu$entry_id[match(c_df$entry, entry_lu$entry)]
                        #         # simplify
                        #         c_df$ASV <- rep(names(c_to), sapply(c_to, nrow))
                        #         ts <- dplyr::select(c_df, domain:species)
                        #         #ts$species[!is.na(ts$species)] <- paste(ts$genus[!is.na(ts$species)], ts$species[!is.na(ts$species)])
                        #         mtax <- cm.asv_main_tax(ts, max_resolution_in_column = "last")
                        #         c_df <- cbind(c_df, mtax)
                        #         c_df$bps <- nchar(c_df$Seq)
                        #         c_df$bps_ASV <- nchar(asv_lookup$sequence[match(c_df$ASV, asv_lookup$ASV)])
                        #         dplyr::select(c_df, ASV, entry_ID, MainTax, Level, name_refDB, pid, n_mis = n_mismatches, seq_ID, ass_ID = assignment_ID, n_ass = n_assignments, n_seqs = n_sequences, gtdb_conform, bps, bps_ASV)
                        # })
                        
                } else {
                        taxa_option_list <- NULL
                }
                # --
                
                rv$group_list <- group_list
                rv$group_counts_plots <- group_counts_plots
                rv$group_tree_plots <- group_tree_plots
                rv$group_mismatch_table_list <- mismatch_table_list
                rv$group_taxa_option_list <- taxa_option_list
                rv$c_group_name <- names(group_list)[[1]]
                updateTextInput(session, inputId = "group_name",
                                value = rv$c_group_name
                )
                rv$infoText = paste("Calculated ASV groups. Shown group:", rv$c_group_name)
                #rv$infoText = paste("Calculated distance matrixes, count plots, and tree plots for each ASV. Shown ASV:", rv$c_asv_name, "Last ASV:", names(rv$asv_counts_plots)[length(rv$asv_counts_plots)])
                
        }
        
})
# --