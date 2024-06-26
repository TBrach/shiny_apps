# - load default planner from dropbox at start -
suppressMessages(filesInfo <- drop_dir(path = 'apps/calendar'))
filePaths <- filesInfo$path_display
Name <- "Planner_work.rds"

if(Name %in% basename(filePaths)) {
        filePath <- filePaths[which(basename(filePaths) %in% Name)]
        # copied this code from drop_read_csv code!
        localfile = paste0(tempdir(), "/", basename(filePath))
        drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
        rv$DFk <- readRDS(file = localfile)
        # rv$DFk$startTime <- force_tz(rv$DFk$startTime, tz = "CET") # only allowed in reactive expression
        # rv$DFk$endTime <- force_tz(rv$DFk$endTime, tz = "CET")
        rv$InfoText = "Loaded planner list from Dropbox"
} else {
        rv$InfoText = "Did not find a planner with this name in your Dropbox folder"
}
# --