# - use render Table to display to_do_table -
output$labplan_table <- renderTable({
        if(!is.null(rv$lab_table)){
                lab_table <- rv$lab_table
                # to_do_df_show$frequency <- paste(as.numeric(to_do_df_show$frequency, "days"), "days")
                # to_do_df_show$done <- as.character(to_do_df_show$done)
                # to_do_df_show$due <- as.character(to_do_df_show$due)
                # to_do_df_show <- to_do_df_show %>% dplyr::mutate(to_do = case_when(
                #     to_due_days <= 0 ~ "To Do",
                #     TRUE ~ ""
                # ))
                lab_table_show <- lab_table # %>% dplyr::select(area, item, to_do, to_due_days, due, done, frequency)
                
                lab_table_show
        } else {
                NULL
        }}, sanitize.text.function = function(x) x)
# --