# - load default planner from dropbox at start -
suppressMessages(filesInfo <- drop_dir(path = 'apps/homework'))
filePaths <- filesInfo$path_display
Name <- "homework.rds"

if(Name %in% basename(filePaths)) {
        filePath <- filePaths[which(basename(filePaths) %in% Name)]
        # copied this code from drop_read_csv code!
        localfile = paste0(tempdir(), "/", basename(filePath))
        drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
        homework_list <- readRDS(file = localfile)
        to_do_df <- homework_list[["to_do_df"]]
        date <- date(lubridate::now())
        to_do_df <- to_do_df %>% dplyr::mutate(`to_due_days` = -1*(as.numeric(days(lubridate::date(now()) - due), "days"))) %>% dplyr::arrange(to_due_days)
        rv$to_do_df <- to_do_df
        rv$history_df <- homework_list[["history_df"]]
        # rv$DFk$startTime <- force_tz(rv$DFk$startTime, tz = "CET") # only allowed in reactive expression
        # rv$DFk$endTime <- force_tz(rv$DFk$endTime, tz = "CET")
        rv$InfoText = "Loaded homework tables from Dropbox"
} else {
        rv$InfoText = "Did not find homework tables in your Dropbox folder"
}
# --