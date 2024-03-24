# - use render Table to display itinerary -
output$assignment_options <- renderTable({
  if(!is.null(rv$assignment_options)){
    c_df <- rv$assignment_options
    #c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")] <- lapply(c_df[sapply(c_df, is.numeric) & str_detect(colnames(c_df), "^ASV_")], round)
    c_df$n_mismatches <- as.integer(round(c_df$n_mismatches, 0))
    c_df
  } else {
    NULL
  }
}, sanitize.text.function = function(x) x)
# --

output$search_seq <- renderText({
  if (is.null(rv$search_seq)){
    NULL
  } else {
    paste0("No of bps: ", nchar(rv$search_seq), ", Sequence:\n", rv$search_seq)
  }
})