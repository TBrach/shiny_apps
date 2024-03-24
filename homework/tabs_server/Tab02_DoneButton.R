# - Add or update button -
observeEvent(input$done_and_save, {
        
        # should not be possible to be NULL still but you could add a check
        to_do_df <- rv$to_do_df
        history_df <- rv$history_df

        area_item <- input$what
        # area_item <- "bathroom - clean sink"

        c_area <- str_split(area_item, " - ")[[1]][[1]]
        c_item <- str_split(area_item, " - ")[[1]][[2]]
        
        date <- input$date
        
        # - change to_do_df and history_df in case date is newer than old done date to record the work -
        c_date <- to_do_df$done[to_do_df$area == c_area & to_do_df$item == c_item]
        
        if (date > c_date) {
            to_do_df$done[to_do_df$area == c_area & to_do_df$item == c_item] <- date
            to_do_df <- to_do_df %>% dplyr::mutate(due = done + frequency,
                                                   `to_due_days` = -1*(as.numeric(days(lubridate::date(now()) - due), "days"))) %>% dplyr::arrange(to_due_days)
            
            
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
            rv$infoText = paste("Changed done date for area:", c_area, "and item:", c_item, "to:", date, "(and uploaded to Dropbox).")
            
            
        } else {
            rv$infoText <- "didn't change anything probably because date was actually before the current done date."
            
        }
        # --

        
})
# --