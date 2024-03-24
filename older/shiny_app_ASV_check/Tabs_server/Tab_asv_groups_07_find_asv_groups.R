# - Add or update button -
observeEvent(input$search_groups, {
        
        if (is.null(rv$group_list)){
                rv$infoText <- "Sorry, no groups to search yet"
        } else if (input$search_group_term == ""){
                rv$infoText <- "You need to give a search term like a taxonomic name or ASV name."
        } else {
                search_term <- input$search_group_term
                group_list <- rv$group_list
                tax <-  rv$raw_data_list[["asv_taxonomy"]]
                full_tax <- tax$FullTax
                full_tax_list <- lapply(group_list, function(c_group){
                        full_tax[c_group,, drop = FALSE]
                })
                hit_groups <- Map(f = function(c_group, c_tax){
                        search_term %in% c_group | any(str_detect(unique(unlist(c_tax)), search_term))
                }, c_group = group_list, c_tax = full_tax_list)
                
                hit_group_list <- group_list[unlist(hit_groups)]
                
                if (length(hit_group_list) == 0){
                        rv$hit_group_list <- NULL
                        rv$infoText <- "no groups found"
                } else {
                        rv$hit_group_list <- hit_group_list
                        rv$infoText <- paste("found", length(hit_group_list), "groups")
                }
                
                
        }
        
})
# --