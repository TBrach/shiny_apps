library(shiny)
library(shinyTime)
library(shinyFiles)
#library(rdrop2)
#library(gridExtra)
#library(ggrepel)
library(lubridate)
library(tidyverse)
# library(flextable)
# library(officer)
library(tidyverse)
library(readxl)
library(writexl)
library(cli) # to use 



# from_client <- cm.read_excel_app(file = input$sample_list_file$datapath, sheet = c_sheet, skip = c_skip, range = c_range, col_names = TRUE)
c_sheet <- "SampleOverview"
c_range <- NULL
c_skip <- 2
sample_name_column <- "Sample name"
comment_column <- "Comments"
input <- list()
input$cm_barcode <- FALSE
input$shorten <- FALSE
input$left <- FALSE
input$study_id <- "bsncas"
study_id <- str_to_lower(input$study_id)
user_name <- "Ola"
sample_list_folder <- "~/Boxcryptor/OneDrive-SharedLibraries-ClinicalMicrobiomics/studies - bsncas/from client/2024-05-22 updated sample list and barcodes (to replace the ones sent 08-05 and 06-05)/"

from_client <- cm.read_excel_app(file = "~/Boxcryptor/OneDrive-SharedLibraries-ClinicalMicrobiomics/studies - bsncas/from client/2024-05-22 updated sample list and barcodes (to replace the ones sent 08-05 and 06-05)/C2753_CM Sample list_bygstubben adress_BATCH1_2024MAY22.xlsx", sheet = c_sheet, skip = c_skip, range = c_range, col_names = TRUE)
from_client <- from_client %>% dplyr::select(sample_name = all_of(sample_name_column), comment_client = any_of(comment_column))

# - in case of cm_barcode check study_id is prefixed if not complain, then remove study_name prefix from sample_name -
if (input$cm_barcode) {
  if (!all(str_detect(from_client$sample_name, paste0(study_id, "_")))){
    rv$bsl_table <- from_client
    rv$infoText <- "You selected CM barcode provided, but prefixes do not all match study name. They should, PLEASE check!"
    return() 
  }
  
  from_client$sample_name <- str_remove(from_client$sample_name, paste0(study_id, "_"))
}
# --


# - Check uniqueness -
sample_name_count <- from_client %>% dplyr::count(sample_name) %>% dplyr::arrange(desc(n)) %>% dplyr::filter(n > 1)

if (nrow(sample_name_count) > 0){
  rv$bsl_table <- sample_name_count
  rv$infoText <- "sample_name not unique --> contact client, see table showing non-unique names. You could also save this table."
  return()
}
# - -


# - Generate a tidied sample name without weird characters -
from_client <- from_client %>% dplyr::mutate(sample_name_tidy = clean_string(sample_name))
# --

# - Check uniqueness again -
sample_name_tidy_count <- from_client %>% dplyr::count(sample_name_tidy) %>% dplyr::arrange(desc(n)) %>% dplyr::filter(n > 1)

if (nrow(sample_name_tidy_count) > 0){
  rv$bsl_table <- sample_name_tidy_count
  rv$infoText <- "sample_name_tidy not unique --> check your code!, see table showing non unique names. You could also save this table."
  return()
}
# --


# - Shorten sample name as it could be relevant for sending to Novogene or other vendors -
if (any(str_length(from_client$sample_name_tidy) > 3)){
  
  position_df <- lapply(str_split(from_client$sample_name_tidy, ""), function(c_splitted_name){
    c_splitted_name %>% enframe() %>% tidyr::pivot_wider(names_from = name, names_prefix = "P_", values_from = value)
  })  %>% dplyr::bind_rows()
  
  
  uniform_positions <- position_df %>% summarise_all(~ n_distinct(.) == 1) %>% pivot_longer(everything()) %>% deframe()
  
  if (any(uniform_positions)){
    n_positions <- length(uniform_positions)
    
    n_positions_to_remove <- n_positions - 3
    
    remove_positions <- which(uniform_positions)
    
    if (length(remove_positions) > n_positions_to_remove){
      
      if (input$left){
        remove_positions <- remove_positions[1:n_positions_to_remove]
      } else {
        remove_positions <- remove_positions[(length(remove_positions) - n_positions_to_remove + 1):length(remove_positions)]
      }
      
    }
    
    position_df <- position_df %>% dplyr::select(!any_of(names(remove_positions)))
    
    from_client$sample_name_shortened <- position_df %>% mutate_all(~replace_na(., "")) %>% pmap_chr(~paste0(..., collapse = ""))
    
  }
  
} else {
  from_client$sample_name_shortened <- from_client$sample_name_tidy
}

# -- Check uniqueness again (should not have changed) --
sample_name_shortened_count <- from_client %>% dplyr::count(sample_name_shortened) %>% dplyr::arrange(desc(n)) %>% dplyr::filter(n > 1)

if (nrow(sample_name_shortened_count) > 0){
  rv$bsl_table <- sample_name_shortened_count
  rv$infoText <- "sample_name_shortened not unique --> check your code!, see table showing non unique names. You could also save this table."
  return()
}
# -- --
# --

from_client <- from_client %>% dplyr::mutate(sample_code = paste0(study_id, "_", sample_name_tidy),
                                             sample_code_shortened = paste0(study_id, "_", sample_name_shortened)) %>% dplyr::select(any_of(c("sample_code", "sample_name", "comment_client", "sample_code_shortened")))


if (input$shorten){
  from_client$sample_code <- from_client$sample_code_shortened 
} 



benchling_sample_list <- from_client %>% dplyr::select(any_of(c("sample_code", "sample_name", "comment_client", "sample_code_shortened")))

if(is.null(c_sheet)){c_sheet <- "NULL"}
if(is.null(c_range)){c_range <- "NULL"}
if(is.null(c_skip)){c_skip <- "NULL"}
if(is.null(user_name)){user_name <- "NULL"}
if(is.null(sample_list_folder)){sample_list_folder <- "NULL"}
formatted_time <- format(now(), "%Y-%m-%d %H:%M:%S")

info_add <- tibble("sample_list_file" = c("input$sample_list_file$name", rep(NA, nrow(benchling_sample_list) - 1)),
                   "sample_list_folder" = c(sample_list_folder, rep(NA, nrow(benchling_sample_list) - 1)),
                   "study_id" = c(study_id, rep(NA, nrow(benchling_sample_list) - 1)),
                   "user" = c(user_name, rep(NA, nrow(benchling_sample_list) - 1)),
                   "date_time" = c(formatted_time, rep(NA, nrow(benchling_sample_list) - 1)),
                   "sheet" = c(c_sheet, rep(NA, nrow(benchling_sample_list) - 1)),
                   "range" = c(c_range, rep(NA, nrow(benchling_sample_list) - 1)),
                   "skip" = c(c_skip, rep(NA, nrow(benchling_sample_list) - 1)),
                   "sample_name_column" = c(sample_name_column, rep(NA, nrow(benchling_sample_list) - 1)),
                   "comment_column" = c(comment_column, rep(NA, nrow(benchling_sample_list) - 1)),
                   "cm_barcode" = c(input$cm_barcode, rep(NA, nrow(benchling_sample_list) - 1)),
                   "shorten" = c(input$shorten, rep(NA, nrow(benchling_sample_list) - 1)),
                   "left" = c(input$left, rep(NA, nrow(benchling_sample_list) - 1)))

benchling_sample_list <- benchling_sample_list %>% dplyr::bind_cols(info_add)



