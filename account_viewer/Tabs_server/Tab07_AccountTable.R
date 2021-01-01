# - prepare the accountTable -
observeEvent(input$generateAccountTable, {
        
        if(!is.null(rv$account_list)){
                rv$infoText <- NULL
                account_list <- rv$account_list
                account <- input$tableAccount
                
                if (account == "Total") {
                        DFaShow <- generate_Total_account(account_list)
                        
                } else {
                        DFaShow <- account_list[[account]]
                }
                
                DFaShow <- cbind(No = 1:nrow(DFaShow), DFaShow)
                DFaShow <- dplyr::filter(DFaShow, Date >= startDate(), Date <= endDate())
                
                if(isTRUE(input$search)){
                        DFaShow <- DFaShow[grep(pattern = input$wordsearch, DFaShow$Text, ignore.case = TRUE),]
                        
                }
                
                if (dim(DFaShow)[1] != 0) {
                        
                        
                        if (DFaShow$Date[1] < DFaShow$Date[nrow(DFaShow)]) {
                                DFaShow <- DFaShow[nrow(DFaShow):1,] # here I want the youngest on top of course
                        }
                        
                        # DFaShow <- dplyr::arrange(DFaShow, desc(Date))
                        #DFkShow$Week <- paste0("W_", strftime(DFkShow$startTime, format = "%V", tz = "CET"), sep = "")
                        #DFkShow$Wday <- lubridate::wday(DFkShow$startTime, label = TRUE)
                        DFaShow$Date <- format(DFaShow$Date, format='%d-%m-%Y')
                        # - remove weird characters -
                        DFaShow$Text <- str_replace_all(string = DFaShow$Text, "[^[:alnum:][:space:][_\\-\\:\\*]]", "?")
                        # --
                        rv$accountTable <- head(DFaShow, input$NoEntries)
                        rv$infoText <- "Table generated"
                } else {
                        rv$infoText <- "no entry in your table"
                        rv$accountTable <- NULL
                }
        }
        
})
# --



# - use render Table to display account data -
output$accountTable <- renderTable({
        rv$accountTable}, sanitize.text.function = function(x) x)

# --