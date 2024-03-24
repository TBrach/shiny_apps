
# - generate budget plots and table -
observeEvent(input$budget_overview, { 
        
        rv$TrHB <- NULL
        rv$TrHB2 <- NULL
        rv$infoText <- NULL
        rv$budget_table <- NULL
        plotHeightHB = 0
        plotHeightHB2 = 0
        
        if(is.null(rv$account_list)){
                rv$infoText <- "There is no account data to plot, please upload account data first."
                return()
        }
        
        if(is.null(rv$budget_categories)){
                rv$infoText <- "No file defining the budget categories has been uploaded yet, no plot possible."
                return()
        }
        
        account_list <- rv$account_list
        
        accountNames <- input$select_accounts
        account_list <- account_list[names(account_list) %in% accountNames]
        
        DFaShow <- account_list %>% dplyr::bind_rows() %>% dplyr::arrange(Date)
        
        DFaShow <- DFaShow %>% dplyr::filter(Date >= startDate(), Date <= endDate())
        
        if (!nrow(DFaShow) > 0) {
          rv$infoText <- "No entries in your chosen accounts to do a budget on."
          return()
        }
        
        budget_categories <- rv$budget_categories
        # budget_categories_coarse <- budget_categories %>% dplyr::group_by(Category_coarse) %>% dplyr::summarise(Pattern = str_c('\\b', Pattern, '\\b', collapse = '|'))
        budget_categories_sd <- budget_categories %>% dplyr::group_by(Category) %>% dplyr::summarise(Pattern = str_c('\\b', Pattern, '\\b', collapse = '|'))
        # budget_categories_fine <- budget_categories %>% dplyr::group_by(Category_fine) %>% dplyr::summarise(Pattern = str_c('\\b', Pattern, '\\b', collapse = '|'))
        
        # DFaShow$Category_coarse <- NA
        # for (i in 1:nrow(budget_categories_coarse)) {
        #   DFaShow$Category_coarse[is.na(DFaShow$Category_coarse) & str_detect(DFaShow$Text, budget_categories_coarse$Pattern[i])] <- budget_categories_coarse$Category_coarse[i]
        # }
        
        DFaShow$Category <- NA
        for (i in 1:nrow(budget_categories_sd)) {
          DFaShow$Category[is.na(DFaShow$Category) & str_detect(DFaShow$Text, pattern = regex(budget_categories_sd$Pattern[i], ignore_case = TRUE))] <- budget_categories_sd$Category[i]
          if (budget_categories_sd$Category[i] == "Passning") { # required as otherwise house!
            DFaShow$Category[str_detect(DFaShow$Text, pattern = regex(budget_categories_sd$Pattern[i], ignore_case = TRUE)) & abs(DFaShow$Amount) < 5000] <- budget_categories_sd$Category[i]
          }
        }
        
        # DFaShow$Category_fine <- NA
        # for (i in 1:nrow(budget_categories_fine)) {
        #   DFaShow$Category_fine[is.na(DFaShow$Category_fine) & str_detect(DFaShow$Text, budget_categories_fine$Pattern[i])] <- budget_categories_fine$Category_fine[i]
        # }
        
        DFaShow <- DFaShow %>% dplyr::filter(!is.na(Category))
        
        DFaShow <- DFaShow %>% dplyr::arrange(Date)
        
        DFaShow <- DFaShow %>% dplyr::mutate(year = lubridate::year(Date),
                                           month = paste(lubridate::month(Date, label = TRUE), year),
                                           quarter = paste(paste0("Q", lubridate::quarter(Date)), year))
        DFaShow$month <- factor(DFaShow$month, levels = unique(DFaShow$month))
        DFaShow$year <- factor(DFaShow$year, levels = unique(DFaShow$year))
        DFaShow$quarter <- factor(DFaShow$quarter, levels = unique(DFaShow$quarter))
        
        DFaShow$Category <- factor(DFaShow$Category, levels = c("House", "Food", "Forsikring", "Passning", "Food out", "Shopping", "Entertainment"))
  
        
        budget_per_month <- DFaShow %>% group_by(month, Category) %>% summarise(amount = sum(Amount),
                                                                                year = unique(year))
        
        cc_lu <- budget_categories %>% dplyr::select(Category_coarse, Category) %>% dplyr::distinct()
        
        budget_per_month$Category_coarse <- cc_lu$Category_coarse[match(budget_per_month$Category, cc_lu$Category)]
        budget_per_month$Category_coarse <- factor(budget_per_month$Category_coarse, levels = c("fix costs", "fun costs"))
        budget_per_month$amount <- -1*budget_per_month$amount
        
        budget_per_month <- budget_per_month %>% dplyr::arrange(month, Category)
        
        colors_categories <- c("#7D3560", "#148F77", "#4E7705", "#9D654C", "#098BD9", "#616161", "#ff7f00")
        names(colors_categories) <- levels(budget_per_month$Category)
        shapes_cc <- c(21, 23)
        names(shapes_cc) <- c("fix costs", "fun costs")
        
        
        Tr <- ggplot(budget_per_month, aes(x = month, y = amount))
        Tr <- Tr +
          geom_point(aes(fill = Category, shape = Category_coarse)) +
          #geom_line(aes(group = Category, col = Category), linewidth = .5) +
          #facet_wrap(year ~ ., scales = "free", ncol = 4) +
          scale_fill_manual("", values = colors_categories) +
          #scale_color_manual("", values = colors_categories) +
          scale_shape_manual("", values = shapes_cc) +
          theme_bw(10) +
          xlab("") +
          ylab(paste0("Amount")) +
          #ggtitle(paste0("From ", startDate(), " to ", endDate())) +
          theme(legend.position = "right",
                axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
        Tr <- ggplotly(Tr, tooltip = c("y", "fill"), height = 400)
        
        budget_per_year <- budget_per_month %>% group_by(year, Category) %>% 
          dplyr::summarise(amount = sum(amount),
                           n_month = n()) %>% ungroup() %>% group_by(year) %>% mutate(n_month_max = max(n_month),
                                                                                      amount_avg_p_month = amount/n_month_max)
        budget_per_year$Category_coarse <- cc_lu$Category_coarse[match(budget_per_year$Category, cc_lu$Category)]
        budget_per_year$Category_coarse <- factor(budget_per_year$Category_coarse, levels = c("fix costs", "fun costs"))
       
        
        Tr1 <- ggplot(budget_per_year, aes(x = Category))
        Tr1 <- Tr1 +
          geom_col(aes(y = amount, fill = Category), alpha = 0.6) +
          geom_point(aes(y = amount_avg_p_month, fill = Category, shape = Category_coarse)) +
          facet_wrap(year ~ ., scales = "free", ncol = 4) +
          scale_fill_manual("", values = colors_categories) +
          scale_shape_manual("", values = shapes_cc) +
          theme_bw(10) +
          xlab("") +
          ylab(paste0("Amount")) +
          #ggtitle(paste0("From ", startDate(), " to ", endDate())) +
          theme(legend.position = "none",
                axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1))
        Tr1 <- ggplotly(Tr1, tooltip = c("y"), height = 400)
        
        budget_per_year_table <- budget_per_year %>% ungroup() %>% dplyr::select(year, Category, Amount_total = amount, `Mean amount per month (max)` = amount_avg_p_month, `No of months` = n_month, `No of months max` = n_month_max)
        budget_per_year_table <- budget_per_year_table %>% pivot_longer(Amount_total:`No of months max`, names_to = "Parameter")
        budget_per_year_table$Parameter <- factor(budget_per_year_table$Parameter, levels = c("Amount_total", "Mean amount per month (max)", "No of months", "No of months max"))
        budget_per_year_table <- budget_per_year_table %>% dplyr::arrange(desc(year), Category, Parameter)
        budget_per_year_table <- budget_per_year_table %>% pivot_wider(names_from = Category, values_from = value)
        
        budget_per_year_table %<>%
          rowwise() %>%
          mutate(
            fix_costs = sum(c_across(any_of(cc_lu$Category[cc_lu$Category_coarse == "fix costs"])), na.rm = TRUE),
            fun_costs = sum(c_across(any_of(cc_lu$Category[cc_lu$Category_coarse == "fun costs"])), na.rm = TRUE)
          )
        
        budget_per_year_table$fix_costs[str_detect(budget_per_year_table$Parameter, "months")] <- NA
        budget_per_year_table$fun_costs[str_detect(budget_per_year_table$Parameter, "months")] <- NA
        
        rv$plotHeightHB = 400
        rv$TrHB <- Tr
        rv$plotHeightHB2 = 400 # length(unique(plot_df2$category))*200
        rv$TrHB2 <- Tr1
        rv$budget_table <- budget_per_year_table
        rv$infoText <- "Generated budget overview"
        
})
# --

# - plot the first HB plot -
output$plotUI_HB <- renderUI({
        plotlyOutput(outputId = "hbPlot", height = paste0(rv$plotHeightHB,"px")) # rv$plotHeightHB
})

output$hbPlot <- renderPlotly({
        if (is.null(rv$TrHB)) {
                return()
                rv$infoText = "no plot generated yet"
        } else {
                print(rv$TrHB)
        }
})
# --

# - plot the second HB plot -
output$plotUI_HB2 <- renderUI({
        plotlyOutput(outputId = "hbPlot2", height = paste0(rv$plotHeightHB2,"px")) # rv$plotHeightHB
})

output$hbPlot2 <- renderPlotly({
        if (is.null(rv$TrHB2)) {
                return()
                rv$infoText = "no plot generated yet"
        } else {
                print(rv$TrHB2)
        }
})
# --

# - use render Table to display account data -
output$budget_table <- renderTable({
    rv$budget_table}, sanitize.text.function = function(x) x)

# --


