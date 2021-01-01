# - load default learn list from dropbox at start -
suppressMessages(filesInfo <- drop_dir(path = 'apps/learn'))
filePaths <- filesInfo$path_display
Name <- "Learn.rds"

if(Name %in% basename(filePaths)) {
        filePath <- filePaths[which(basename(filePaths) %in% Name)]
        # copied this code from drop_read_csv code!
        localfile = paste0(tempdir(), "/", basename(filePath))
        drop_download(path = filePath, local_path = localfile, overwrite = TRUE)
        rv$DFl <- readRDS(file = localfile)
        rv$InfoText = "Loaded learn list list from Dropbox"
} else {
        rv$InfoText = "Did not find a learn list with this name in your Dropbox folder"
}
# --