# - use render Table to display learn list -
output$categories <- renderTable({
        if(!is.null(rv$DFl)){
                DFlShow <- rv$DFl
                
                
                list_categories <- DFlShow$Category
                list_categories <- str_split(list_categories, pattern = ",")
                list_categories <- unlist(lapply(list_categories, str_trim))
                list_categories <- sort(unique(list_categories))
                
                list_categories
        } else {
                NULL
        }}, sanitize.text.function = function(x) x)
# --