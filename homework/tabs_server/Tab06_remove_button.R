# - Add or update button -
observeEvent(input$remove_and_save, {
        
        # should not be possible to be NULL still but you could add a check
        to_do_df <- rv$to_do_df
        history_df <- rv$history_df


        c_area <- str_trim(input$area)
        c_item <- str_trim(input$item)
        
        
        already_in <- to_do_df %>% dplyr::filter(area == c_area & item == c_item)
        
                
        if (nrow(already_in) > 0) {
           
            to_do_df <- to_do_df %>% dplyr::filter(!(area == c_area & item == c_item))
            to_do_df <- to_do_df %>% dplyr::mutate(`to_due_days` = -1*(as.numeric(days(lubridate::date(now()) - due), "days"))) %>% dplyr::arrange(to_due_days)
            
            rv$to_do_df <- to_do_df
            
            # than directly save in dropbox:
            filename = "homework.rds"
            file_path <- file.path(tempdir(), filename)
            out_list <- list(`to_do_df` = rv$to_do_df, `history_df` = rv$history_df)
            saveRDS(out_list, file_path)
            drop_upload(file_path, path = 'apps/homework')
            rv$infoText = paste("Removed", c_area, "with", c_item, "from list and uploaded to Dropbox).")
            
            
        } else {
            rv$infoText <- "The area item combi was not on the list, so nothing was added or done."
            
        }
        # --

        
})
# --