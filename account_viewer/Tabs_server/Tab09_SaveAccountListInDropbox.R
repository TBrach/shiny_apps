# - save account_list in your dropbox -
observeEvent(input$saveDropbox, {
        if(is.null(rv$account_list)){
                rv$infoText = "I do not think you want to upload an empty account_list to your Dropbox"
                return(NULL)
        } else {
                filename = "account_list.rds"
                file_path <- file.path(tempdir(), filename)
                saveRDS(rv$account_list, file_path)
                drop_upload(file_path, path = 'apps/account_list')
                rv$infoText = "Uploaded account_list to Dropbox"
        }
})
# --