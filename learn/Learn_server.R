server_tab_path <- "./Tabs_server"

server <- function(input, output, session){
        
        # - generate reactive Values -
        rv <- reactiveValues(DFl = NULL, infoText = NULL)
        # --
        
        # - Get default learn list from dropbox -
        source(file.path(server_tab_path, "Tab00_GetDefaultLearnListFromDropboxAtStart.R"), local = TRUE)
        # --
        
        # - Check all Dates and Times, inform (output) -
        source(file.path(server_tab_path, "Tab01_CheckDateTimes.R"), local = TRUE)
        # --
        
        # - Add or update button -
        source(file.path(server_tab_path, "Tab02_AddUpdateButton.R"), local = TRUE)
        # --
        
        # - output infoText -
        source(file.path(server_tab_path, "Tab03_InfoText_Output.R"), local = TRUE)
        # --
        
        # - Pick an event -
        source(file.path(server_tab_path, "Tab04_PickEvent.R"), local = TRUE)
        # --
        
        # - Remove an event -
        source(file.path(server_tab_path, "Tab05_RemoveEvent.R"), local = TRUE)
        # --
        
        # - Display table using input$view -
        source(file.path(server_tab_path, "Tab06_DisplayTable_Output.R"), local = TRUE)
        # --
        
        # - Display table categories -
        source(file.path(server_tab_path, "Tab07_DisplayTable_Categories.R"), local = TRUE)
        # --
        
        
        # - Save in Dropbox -
        source(file.path(server_tab_path, "Tab08_SaveLearnInDropbox.R"), local = TRUE)
        # --
        
        # - Get from Dropbox -
        #source(file.path(server_tab_path, "Tab12_GetPlannerFromDropbox.R"), local = TRUE)
        # --
        
}