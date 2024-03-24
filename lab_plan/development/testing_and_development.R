setwd("~/shiny_apps/lab_plan/")
out_list <- readRDS("./input_at_start/lab_plan_app_inputs.rds")
rv <- list()
rv$default_lab_plans <- out_list[["default_lab_plans"]]
rv$choice_combi_df <- out_list[["choice_combi_df"]]
default_lab_plans <- rv$default_lab_plans
choice_combi_df <- rv$choice_combi_df
sample_type <- "feces"
provided <- "sample"
data_type <- "shotgun"
sequencing_provider <- "Dante"

c_protocol_name <- paste(sample_type, data_type, sequencing_provider, sep = "_")
