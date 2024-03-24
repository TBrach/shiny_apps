options(shiny.maxRequestSize=30*1024^2) # to allow loading big files
server_tab_path <- "./Tabs_server"

server <- function(input, output, session){
        
        # - generate reactive Values -
        rv <- reactiveValues(infoText = NULL, 
                             raw_data_list = NULL, 
                             pid_matrix = NULL,
                             n_mismatch_matrix = NULL,
                             asv_taxa_option_list = NULL,
                             asv_mismatch_table_list = NULL,
                             asv_tree_plots = NULL,
                             asv_counts_plots = NULL,
                             c_asv_name = NULL,
                             group_list = NULL, 
                             group_counts_plots = NULL, 
                             group_tree_plots = NULL, 
                             group_mismatch_table_list = NULL, 
                             group_taxa_option_list = NULL, 
                             c_group_name = NULL, 
                             hit_group_list = NULL,
                             search_asv_table = NULL,
                             refDB = NULL, 
                             assignment_options = NULL, 
                             search_seq = NULL)
        # --
        
        # Tab_asv_indiv ==============
        
        # - load data from user selected folder -
        source(file.path(server_tab_path, "Tab_asv_indiv_01_load_data.R"), local = TRUE)
        # --
        
        # - output info text on asv_indiv tab -
        source(file.path(server_tab_path, "Tab_asv_indiv_02_InfoText_Output.R"), local = TRUE)
        # --
        
        # - output info text on asv_indiv tab -
        source(file.path(server_tab_path, "Tab_asv_indiv_03_calc_asv_data.R"), local = TRUE)
        # --
        
        # - output asv plot -
        source(file.path(server_tab_path, "Tab_asv_indiv_04_group_plots_output.R"), local = TRUE)
        # --
        
        # - output mismatch and options -
        source(file.path(server_tab_path, "Tab_asv_indiv_05_output_mismatch_table.R"), local = TRUE)
        # --
        
        # - change plots -
        source(file.path(server_tab_path, "Tab_asv_indiv_06_plot_changer_buttons.R"), local = TRUE)
        # --
        
        
        # Tab_asv_groups ==============
        
        # - calculate asv groups based on distances and plot -
        source(file.path(server_tab_path, "Tab_asv_groups_01_calc_asv_groups.R"), local = TRUE)
        # --
        
        # - output infoText -
        source(file.path(server_tab_path, "Tab_asv_groups_02_InfoText_Output.R"), local = TRUE)
        # --
        
        # # - output group_plots -
        source(file.path(server_tab_path, "Tab_asv_groups_03_group_plots_output.R"), local = TRUE)
        # # --
        
        # - output group_names -
        source(file.path(server_tab_path, "Tab_asv_groups_04_group_names_output.R"), local = TRUE)
        # --
        
        # - output group_names -
        source(file.path(server_tab_path, "Tab_asv_groups_05_output_mismatch_table.R"), local = TRUE)
        # --
        
        # - change plot buttons -
        source(file.path(server_tab_path, "Tab_asv_groups_06_plot_changer_buttons.R"), local = TRUE)
        # --
        
        # - change plot buttons -
        source(file.path(server_tab_path, "Tab_asv_groups_07_find_asv_groups.R"), local = TRUE)
        # --
        
        
        
        # Tab_search_asvs ==============
        
        # - change plot buttons -
        source(file.path(server_tab_path, "Tab_search_asvs_01_find_asvs.R"), local = TRUE)
        # --
        
        # - output infoText -
        source(file.path(server_tab_path, "Tab_search_asvs_02_InfoText_Output.R"), local = TRUE)
        # --
        
        # - output found ASVs table -
        source(file.path(server_tab_path, "Tab_search_asvs_03_output_found_asvs_table.R"), local = TRUE)
        # --
        
        
        
        # Tab_check_assignment ==============
        
        # -  -
        source(file.path(server_tab_path, "Tab_check_assignment_01_load_refDB.R"), local = TRUE)
        # --
        
        # - output infoText -
        source(file.path(server_tab_path, "Tab_check_assignment_02_InfoText_Output.R"), local = TRUE)
        # --

        # -  -
        source(file.path(server_tab_path, "Tab_check_assignment_03_find_assignment_options.R"), local = TRUE)
        # --
        
        # -  -
        source(file.path(server_tab_path, "Tab_check_assignment_04_output_assignment_options.R"), local = TRUE)
        # --
        

}