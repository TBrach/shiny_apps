# - Add or update button -
observeEvent(input$add_and_save, {
        
        # should not be possible to be NULL still but you could add a check
        to_do_df <- rv$to_do_df
        history_df <- rv$history_df


        c_area <- str_trim(input$area)
        c_item <- str_trim(input$item)
        
        c_date <- input$date
        
        already_in <- to_do_df %>% dplyr::filter(area == c_area & item == c_item)
        
                
        if (!nrow(already_in) > 0) {
            c_freq <- input$freq
            
            to_do_df_add <- tibble::tribble(
                ~"area",        ~"item",             ~"frequency",                     ~"done",
                c_area,     c_item,       lubridate::days(c_freq),                ymd(c_date))
            
            
            to_do_df_add <- to_do_df_add %>% dplyr::mutate(due = done + frequency,
                                                   `to_due_days` = -1*(as.numeric(days(lubridate::date(now()) - due), "days"))) %>% dplyr::arrange(to_due_days)
            
            to_do_df <- to_do_df %>% dplyr::bind_rows(to_do_df_add)
            # update
            to_do_df <- to_do_df %>% dplyr::mutate(`to_due_days` = -1*(as.numeric(days(lubridate::date(now()) - due), "days"))) %>% dplyr::arrange(to_due_days)
            
            person <- input$person
                
            history_entry <- to_do_df %>% dplyr::select(area, item, done) %>% dplyr::filter(area == c_area & item == c_item)
            history_entry$done_by <- person
            
            history_df <- history_df %>% dplyr::bind_rows(history_entry) %>% dplyr::arrange(desc(done))
            # no task should be done twice the same day usually
            history_df <- history_df %>% dplyr::distinct()
            
            rv$to_do_df <- to_do_df
            rv$history_df <- history_df
            
            # than directly save in dropbox:
            filename = "homework.rds"
            file_path <- file.path(tempdir(), filename)
            out_list <- list(`to_do_df` = rv$to_do_df, `history_df` = rv$history_df)
            saveRDS(out_list, file_path)
            drop_upload(file_path, path = 'apps/homework')
            rv$infoText = paste("Added item to list. Changed done date for area:", c_area, "and item:", c_item, "to:", date, "(and uploaded to Dropbox).")
            
            
        } else {
            rv$infoText <- "The area item combi was already on the list, so nothing was added or done."
            
        }
        # --

        
})
# --