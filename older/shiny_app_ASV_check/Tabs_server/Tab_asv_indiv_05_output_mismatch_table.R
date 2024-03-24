# - output infoText -
output$asv_sequence <- renderText({
  if(!is.null(rv$c_asv_name)){
    asv_lookup <- rv$raw_data_list[["asv_lookup"]]
    paste(rv$c_asv_name, asv_lookup$sequence[asv_lookup$ASV == rv$c_asv_name])
  } else {
    NULL
  }
})
# --


# - use render Table to display itinerary -
output$asv_table <- renderTable({
  if(!is.null(rv$c_asv_name)){
    c_df <- rv$asv_mismatch_table_list[[rv$c_asv_name]]
    c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")] <- lapply(c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")], round)
    c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")] <- lapply(c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")], as.integer)
    c_df
  } else {
    NULL
  }
}, sanitize.text.function = function(x) x)
# --

output$asv_option_table <- renderTable({
  if(!is.null(rv$c_asv_name) && !is.null(rv$asv_taxa_option_list)){
    c_df <- rv$asv_taxa_option_list[[rv$c_asv_name]]
    c_df
  } else {
    NULL
  }
}, sanitize.text.function = function(x) x)