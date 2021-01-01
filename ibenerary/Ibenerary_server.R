server_tab_path <- "./Tabs_server"

server <- function(input, output, session){
        
        # - generate reactive Values -
        rv <- reactiveValues(DFi = NULL, infoText = NULL, Tr = NULL, PlotHeight = 2.9) #Plot Height, see below
        # 2.9 inches is chosen per day of the itinerary, that way four days fill 1 DinA4 = 11,69 inches
        
        Rating <- reactive({
                if(isTRUE(input$ratedecide)){
                        input$rate
                } else {
                        NULL
                }
        })
        # --
        
        # - Get default planner from dropbox -
        # source(file.path(server_tab_path, "Tab00_GetDefaultPlannerFromDropboxAtStart.R"), local = TRUE)
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
        
        # - generate the planner plots -
        source(file.path(server_tab_path, "Tab07_IbeneraryPlot.R"), local = TRUE)
        # --
        
        # - generate the score plot -
        source(file.path(server_tab_path, "Tab08_DownloadPlot.R"), local = TRUE)
        # --
        
        # - output planner plots -
        source(file.path(server_tab_path, "Tab09_IbeneraryPlot_Output.R"), local = TRUE)
        # --
        
        # - output the score plot -
        #source(file.path(server_tab_path, "Tab10_ScorePlot_Output.R"), local = TRUE)
        # --
        
        # - Save in Dropbox -
        source(file.path(server_tab_path, "Tab11_SaveIbeneraryInDropbox.R"), local = TRUE)
        # --
        
        # - Get from Dropbox -
        source(file.path(server_tab_path, "Tab12_GetIbeneraryFromDropbox.R"), local = TRUE)
        # --
        
        # - Save as csv -
        source(file.path(server_tab_path, "Tab13_SaveCSV.R"), local = TRUE)
        # --
        
        # - Load from csv -
        source(file.path(server_tab_path, "Tab14_LoadCSV.R"), local = TRUE)
        # --
        
        # - Locally save Score Plot as pdf -
        #source(file.path(server_tab_path, "Tab13_SaveScorePlotPdf.R"), local = TRUE)
        # --
}