server_tab_path <- "./Tabs_server"


server <- function(input, output, session){
        
        # - read in the drop token -
        token <- readRDS("token.rds")
        # --
        
        # - generate reactive Values -
        rv <- reactiveValues(DFk = NULL, infoText = NULL, TrL = NULL)
        # --
        
        # - Get default calendar from dropbox -
        source(file.path(server_tab_path, "Tab00_GetDefaultCalendarFromDropboxAtStart.R"), local = TRUE)
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
        
        # - generate the calendar plots -
        source(file.path(server_tab_path, "Tab07_CalendarPlots.R"), local = TRUE)
        # --
        
        # - output calendar plots -
        source(file.path(server_tab_path, "Tab08_CalendarPlots_Output.R"), local = TRUE)
        # --
        
        # - Save in Dropbox -
        source(file.path(server_tab_path, "Tab09_SaveCalendarInDropbox.R"), local = TRUE)
        # --
        
        # - Get from Dropbox -
        source(file.path(server_tab_path, "Tab10_GetCalendarFromDropbox.R"), local = TRUE)
        # --
        
        # - Locally save Score Plot as pdf -
        source(file.path(server_tab_path, "Tab11_SaveWeekPlotPdf.R"), local = TRUE)
        # --
}