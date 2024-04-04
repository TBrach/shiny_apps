# Functions for table design ====
cm.table_theme <- function(ftable){
    if (!inherits(ftable, "flextable")) {
        stop("This theme only supports flextable objects.")
    }
    even <- seq_len(nrow_part(ftable, "body")) %% 2 == 0
    odd <- !even
    
    ftable %<>%
        font(fontname = "Calibri Light", part = 'all') %>%
        fontsize(size = 10, part = "all") %>%
        border_remove() %>%
        hline_bottom(border = cm.solid_border, part = "header") %>%
        hline_bottom(border = cm.solid_border, part = "body") %>%
        hline_top(border = cm.solid_border, part = 'header') %>%
        bg(bg = "#E0E0E1", i = odd) %>%
        padding(padding.top = 0, padding.bottom = 0) %>%
        autofit(add_w = 0, add_h = 0) %>%
        align(align = 'left', part = "all") %>%
        fix_border_issues()
    return(ftable)
}


cm.solid_border <- officer::fp_border(color = "black", width = 0.5, style = "solid")