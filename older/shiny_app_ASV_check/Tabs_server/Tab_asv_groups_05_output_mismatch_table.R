# - use render Table to display itinerary -
output$group_table <- renderTable({
  if(!is.null(rv$c_group_name)){
    c_df <- rv$group_mismatch_table_list[[rv$c_group_name]]
    c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")] <- lapply(c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")], round)
    c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")] <- lapply(c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")], as.integer)
    c_df
  } else {
    NULL
  }
}, sanitize.text.function = function(x) x)
# --

output$taxa_option_table <- renderTable({
  if(!is.null(rv$c_group_name) && !is.null(rv$group_taxa_option_list)){
    c_df <- rv$group_taxa_option_list[[rv$c_group_name]]
    c_df
  } else {
    NULL
  }
}, sanitize.text.function = function(x) x)