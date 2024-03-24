observeEvent(input$refDB, {
        
        rv$refDB <- NULL
        
        file <- input$refDB
        
        df_in <- readRDS(file$datapath)
        
        if (class(df_in) != "data.frame"){
                rv$infoText <- "The uploaded refDB was not in data fame format, it needs to be."
                #return()
        } else {
                rv$refDB <- df_in
                rv$infoText <- paste0("Uploaded refDB with ", nrow(df_in), " entries called ", file$name, " having a size of ", file$size)
                
        }
        
})
