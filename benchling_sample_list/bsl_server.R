server_tab_path <- "./tabs_server"


server <- function(input, output, session){
        
        
        # - generate reactive Values -
        rv <- reactiveValues(bsl_table = NULL, dir_path = NULL, infoText = NULL)
        # --
        
        # # - To allow choosing the directory with the samle list -
        # source(file.path(server_tab_path, "part01_show_selected_dir.R"), local = TRUE)
        # # --
        
        # - The create benchling sample list button -
        source(file.path(server_tab_path, "part02_create_bsl_excel_button.R"), local = TRUE)
        # --
        
        # - output infoText -
        source(file.path(server_tab_path, "part03_info_text_output.R"), local = TRUE)
        # --
        
        
        # - Display table  -
        source(file.path(server_tab_path, "part04_display_table_output.R"), local = TRUE)
        # --
       
  
        # - Save benchling sample list  -
        source(file.path(server_tab_path, "part05_save_bsl_as_excel_button.R"), local = TRUE)
        # --
}