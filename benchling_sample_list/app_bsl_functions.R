# Functions for table design ====
cm.read_excel_app <- function (file, ..., drop_empty_cols = TRUE, drop_empty_rows = TRUE){
  xls <- readxl::read_excel(path = file, ...)
  # if ("CM.info" %in% readxl::excel_sheets(file)) {
  #   cm_info <- readxl::read_excel(path = file, sheet = "CM.info") %>% 
  #     dplyr::pull(2, 1)
  #   ui_done(c("{ui_field('Created by')}: {ui_value(cm_info['user'])}", 
  #             "{ui_field('on')}: {ui_value(cm_info['date'])}", 
  #             "{ui_field('with')}: {ui_value(cm_info['source'])}"))
  # }
  if (drop_empty_cols) {
    xls <- xls %>% dplyr::select(-where(~all(is.na(.x))))
  }
  if (drop_empty_rows) {
    xls <- xls %>% dplyr::filter(!dplyr::if_all(.fns = is.na, .cols = dplyr::everything()))
  }
  return(xls)
}


clean_string <- function(c_string){
  c_string <- str_trim(c_string) # Trims whitespace from the start and end of the text
  c_string <- str_squish(c_string) # Removes extra spaces within the text.
  c_string <- str_replace_all(c_string, "[^[:alnum:]_\\-[:space:]]", "") # remove non alphanumeric unless space, dash, or underscore
  c_string <- str_replace_all(c_string, "[ -]", "_")
  c_string
}



# 
# cm.table_theme <- function(ftable){
#     if (!inherits(ftable, "flextable")) {
#         stop("This theme only supports flextable objects.")
#     }
#     even <- seq_len(nrow_part(ftable, "body")) %% 2 == 0
#     odd <- !even
#     
#     ftable %<>%
#         font(fontname = "Calibri Light", part = 'all') %>%
#         fontsize(size = 10, part = "all") %>%
#         border_remove() %>%
#         hline_bottom(border = cm.solid_border, part = "header") %>%
#         hline_bottom(border = cm.solid_border, part = "body") %>%
#         hline_top(border = cm.solid_border, part = 'header') %>%
#         bg(bg = "#E0E0E1", i = odd) %>%
#         padding(padding.top = 0, padding.bottom = 0) %>%
#         autofit(add_w = 0, add_h = 0) %>%
#         align(align = 'left', part = "all") %>%
#         fix_border_issues()
#     return(ftable)
# }
# 
# 
# cm.solid_border <- officer::fp_border(color = "black", width = 0.5, style = "solid")