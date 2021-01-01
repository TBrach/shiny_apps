server_tab_path <- "./Tabs_server"

server <- function(input, output, session){
        
        # - generate reactive Values -
        rv <- reactiveValues(account_list = NULL, overviewTable = NULL, accountTable = NULL, infoText = NULL, Tra = NULL, plotHeight = 0,
                             patternCategory = NULL, TrHB = NULL, plotHeightHB = 0, TrHB2 = NULL, plotHeightHB2 = 0,
                             account_colors = c(Total = "#E69F00", IngDiba_Giro = "#117755", IngDiba_Extra = "#44AA88", IngDiba_Depot = "#99CCBB",
                                                BasisBank_Loen = "#4477AA", Handelsbanken_Faelles = "#AA4477"))
        # --
        
        # - Get account_list dropbox -
        source(file.path(server_tab_path, "Tab00_GetAccountListFromDropboxAtStart.R"), local = TRUE)
        # --
        
        # - Make and render overview table -
        source(file.path(server_tab_path, "Tab01_MakeAndRenderOverviewTable.R"), local = TRUE)
        # --
        
        # - CheckDates -
        source(file.path(server_tab_path, "Tab02_CheckDates.R"), local = TRUE)
        # --
        
        # # - load account from csv - # 20200101: removed after I now save the accounts in dropbox and upload new data directly
        # source(file.path(server_tab_path, "Tab03_LoadAccountCSV.R"), local = TRUE)
        # # --
        
        # - load account from csv -
        source(file.path(server_tab_path, "Tab03a_AddNewAccountData.R"), local = TRUE)
        # --
        
        # - remove an account -
        # source(file.path(server_tab_path, "Tab04_RemoveAccount.R"), local = TRUE)
        # --
        
        # - plot accounts -
        source(file.path(server_tab_path, "Tab05_PlotAccounts.R"), local = TRUE)
        # --
        
        # - update account -
        source(file.path(server_tab_path, "Tab06_UpdateAccounts.R"), local = TRUE)
        # --
        
        # - generate account table -
        source(file.path(server_tab_path, "Tab07_AccountTable.R"), local = TRUE)
        # --
        
        # - currency converter -
        source(file.path(server_tab_path, "Tab08_CurrencyConverter.R"), local = TRUE)
        # --
        
        # - save account_list in dropbox -
        source(file.path(server_tab_path, "Tab09_SaveAccountListInDropbox.R"), local = TRUE)
        # --
        
        # - make Haushaltsbuch plots -
        source(file.path(server_tab_path, "Tab10_Haushaltsbuch.R"), local = TRUE)
        # --
        
}