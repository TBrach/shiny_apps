# - load default planner from dropbox at start -
suppressMessages(filesInfo <- drop_dir(path = 'apps/account_list'))
filePaths <- filesInfo$path_display
Name <- "account_list.rds"

if(Name %in% basename(filePaths)) {
        filePath <- filePaths[which(basename(filePaths) %in% Name)]
        # copied this code from drop_read_csv code!
        localfile = paste0(tempdir(), "/", basename(filePath))
        drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
        rv$account_list <- readRDS(file = localfile)
        rv$infoText = "Loaded account list from Dropbox"
} else {
        rv$infoText = "Did not find an account list with this name in your Dropbox folder"
}
# --