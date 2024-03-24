# - prepare the accountTable -
observeEvent(input$generateAccountTable, {
        
        if(!is.null(rv$account_list)){
                rv$infoText <- NULL
                
                if(is.null(rv$account_list)){
                  rv$infoText <- "There is no account data to plot, please upload account data first."
                  return()
                }
                
                account_list <- rv$account_list
                
                # restrict to chosen account(s)
                accountNames <- input$select_accounts
                account_list <- account_list[names(account_list) %in% accountNames]
                
                if (isTRUE(input$as_total)) {
                        DFaShow <- generate_Total_account(account_list)
                } else {
                        DFaShow <- account_list %>% dplyr::bind_rows() %>% dplyr::arrange(Date)
                }
                
                DFaShow <- cbind(No = 1:nrow(DFaShow), DFaShow)
                DFaShow <- DFaShow %>% dplyr::filter(Date >= startDate(), Date <= endDate())
                
                if(isTRUE(input$search)){
                        DFaShow <- DFaShow %>% dplyr::filter(str_detect(DFaShow$Text, pattern = regex(input$wordsearch, ignore_case = TRUE)))
                                                                        #[grep(pattern = input$wordsearch, DFaShow$Text, ignore.case = TRUE),]
                        
                }
                
                if (nrow(DFaShow) > 0) {
                
                        if (DFaShow$Date[1] < DFaShow$Date[nrow(DFaShow)]) {
                                DFaShow <- DFaShow[nrow(DFaShow):1,] # here I want the youngest on top of course
                        }
                        
                        # DFaShow <- dplyr::arrange(DFaShow, desc(Date))
                        #DFkShow$Week <- paste0("W_", strftime(DFkShow$startTime, format = "%V", tz = "CET"), sep = "")
                        #DFkShow$Wday <- lubridate::wday(DFkShow$startTime, label = TRUE)
                        DFaShow$Date <- format(DFaShow$Date, format='%d-%m-%Y')
                        # - remove weird characters -
                        # DFaShow$Text <- str_replace_all(string = DFaShow$Text, "[^[:alnum:][:space:][_\\-\\:\\*]]", "?")
                        # --
                        # - add the categories if wished for -
                        if (!is.null(rv$budget_categories) && input$add_categories) {
                          budget_categories <- rv$budget_categories
                          budget_categories_coarse <- budget_categories %>% dplyr::group_by(Category_coarse) %>% dplyr::summarise(Pattern = str_c('\\b', Pattern, '\\b', collapse = '|'))
                          budget_categories_sd <- budget_categories %>% dplyr::group_by(Category) %>% dplyr::summarise(Pattern = str_c('\\b', Pattern, '\\b', collapse = '|'))
                          budget_categories_fine <- budget_categories %>% dplyr::group_by(Category_fine) %>% dplyr::summarise(Pattern = str_c('\\b', Pattern, '\\b', collapse = '|'))
                          
                          DFaShow$Category_coarse <- NA
                          for (i in 1:nrow(budget_categories_coarse)) {
                            DFaShow$Category_coarse[is.na(DFaShow$Category_coarse) & str_detect(DFaShow$Text, budget_categories_coarse$Pattern[i])] <- budget_categories_coarse$Category_coarse[i]
                          }
                          DFaShow$Category <- NA
                          for (i in 1:nrow(budget_categories_sd)) {
                            DFaShow$Category[is.na(DFaShow$Category) & str_detect(DFaShow$Text, pattern = regex(budget_categories_sd$Pattern[i], ignore_case = TRUE))] <- budget_categories_sd$Category[i]
                            if (budget_categories_sd$Category[i] == "Passning") { # required as otherwise house!
                              DFaShow$Category[str_detect(DFaShow$Text, pattern = regex(budget_categories_sd$Pattern[i], ignore_case = TRUE)) & abs(DFaShow$Amount) < 5000] <- budget_categories_sd$Category[i]
                            }
                          }
                          DFaShow$Category_fine <- NA
                          for (i in 1:nrow(budget_categories_fine)) {
                            DFaShow$Category_fine[is.na(DFaShow$Category_fine) & str_detect(DFaShow$Text, budget_categories_fine$Pattern[i])] <- budget_categories_fine$Category_fine[i]
                            if (budget_categories_fine$Category_fine[i] == "Kindergarden") { # required as otherwise house!
                              DFaShow$Category_fine[str_detect(DFaShow$Text, pattern = regex(budget_categories_fine$Pattern[i], ignore_case = TRUE)) & abs(DFaShow$Amount) < 5000] <- budget_categories_fine$Category_fine[i]
                            }
                          }
                          
                        }
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