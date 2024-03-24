# - use render Table to display table -
output$found_asvs_table <- renderTable({
  if(!is.null(rv$search_asv_table)){
    c_df <- rv$search_asv_table
    c_df$pid <- round(c_df$pid, 3)
    c_df$n_mismatches <- as.integer(c_df$n_mismatches)
    c_df
  } else {
    NULL
  }
}, sanitize.text.function = function(x) x)
# --
