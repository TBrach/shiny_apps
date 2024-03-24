server_tab_path <- "./tabs_server"


server <- function(input, output, session){
        
        # - read in the drop token -
        token <- readRDS("token.rds")
        # --
        
        # - generate reactive Values -
        rv <- reactiveValues(to_do_df = NULL, history_df = NULL, infoText = NULL)
        # --
        
        # - Get default calendar from dropbox -
        source(file.path(server_tab_path, "Tab00_get_tables_from_dropbox_at_start.R"), local = TRUE)
        # --
        
        observe({
            # Create the choices
            choices_what <- paste0(rv$to_do_df$area, " - ", rv$to_do_df$item)
            
            # Update the selectInput
            updateSelectInput(session, "what", choices = choices_what, selected = choices_what[1])
        })
        
        # - Check all Dates and Times, inform (output) -
        source(file.path(server_tab_path, "Tab01_CheckDateTimes.R"), local = TRUE)
        # --
        
        # - Add or update button -
        source(file.path(server_tab_path, "Tab02_DoneButton.R"), local = TRUE)
        # --
        
        # - output infoText -
        source(file.path(server_tab_path, "Tab03_InfoText_Output.R"), local = TRUE)
        # --
        
        
        # - Display table using input$view -
        source(file.path(server_tab_path, "Tab04_DisplayTable_Output.R"), local = TRUE)
        # --
        
        # - Option to add items -
        source(file.path(server_tab_path, "Tab05_add_button.R"), local = TRUE)
        # --
        
        # - Option to remove items -
        source(file.path(server_tab_path, "Tab06_remove_button.R"), local = TRUE)
        # --
        
        # # - generate the calendar plots -
        # source(file.path(server_tab_path, "Tab07_CalendarPlots.R"), local = TRUE)
        # # --
        # 
        # # - output calendar plots -
        # source(file.path(server_tab_path, "Tab08_CalendarPlots_Output.R"), local = TRUE)
        # # --
        
}