server_tab_path <- "./tabs_server"


server <- function(input, output, session){
        
        
        # - generate reactive Values -
        rv <- reactiveValues(default_lab_plans = NULL, choice_combi_df = NULL, lab_table = NULL, dir_path = NULL, infoText = NULL)
        # --
        
        # - set defaults for -
        shinyDirChoose(input, 'dir', roots = c(home = '~', studies = "~/Boxcryptor/OneDrive-SharedLibraries-ClinicalMicrobiomics"))
        # --
        
        # - Get default labtables -
        source(file.path(server_tab_path, "part00_get_labtable_list_at_start.R"), local = TRUE)
        # --
        
        # - Check all Dates and Times, inform (output) -
        source(file.path(server_tab_path, "part01_check_date_times.R"), local = TRUE)
        # --
        
        # - The create word button -
        source(file.path(server_tab_path, "part02_create_word_button.R"), local = TRUE)
        # --
        
        # - output infoText -
        source(file.path(server_tab_path, "part03_info_text_output.R"), local = TRUE)
        # --
        
        
        # - Display table  -
        source(file.path(server_tab_path, "part04_display_table_output.R"), local = TRUE)
        # --
        
        # - The create word button -
        source(file.path(server_tab_path, "part05_create_table_button.R"), local = TRUE)
        # --
  
        
}