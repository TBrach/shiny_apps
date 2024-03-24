# - load default tables at start of app -
if (file.exists("./input_at_start/lab_plan_app_inputs.rds")){
  
  out_list <- readRDS("./input_at_start/lab_plan_app_inputs.rds")
    
  rv$default_lab_plans <- out_list[["default_lab_plans"]]
  rv$choice_combi_df <- out_list[["choice_combi_df"]]
  
  rv$InfoText = "Loaded inputs being default_lab_plans and "
} else {
  rv$InfoText = "Did not find ./input_at_start/lab_plan_app_inputs.rds!"
}
# --