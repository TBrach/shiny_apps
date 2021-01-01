# - load default item list from dropbox at start -
suppressMessages(filesInfo <- drop_dir(path = 'apps/sundhed'))
filePaths <- filesInfo$path_display
Name <- "sundhed.rds"

if(Name %in% basename(filePaths)) {
        filePath <- filePaths[which(basename(filePaths) %in% Name)]
        # copied this code from drop_read_csv code!
        localfile = paste0(tempdir(), "/", basename(filePath))
        drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
        rv$DFi <- readRDS(file = localfile)
        # rv$DFk$startTime <- force_tz(rv$DFk$startTime, tz = "CET") # only allowed in reactive expression
        # rv$DFk$endTime <- force_tz(rv$DFk$endTime, tz = "CET")
        rv$infoText = "Loaded item list from Dropbox"
} else {
        rv$infoText = "Did not find an item list with this name in your Dropbox folder"
}
# --