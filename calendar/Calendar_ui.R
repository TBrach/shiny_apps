# - source all the tabs -
tabpath <- "./Tabs_ui"
source(file.path(tabpath, "html_styles_ui.R"))
# source(file.path(tabpath, "Tab01_Done_ui.R"))
source(file.path(tabpath, "Tab02_Add_ui.R"))
source(file.path(tabpath, "Tab03_Main_ui.R"))
# --

# - generate the fluid page with the loaded parts -
ui <- fluidPage(
        html_styles,
        sidebarLayout(
                Tab02,
                Tab03
        )
        
)
# --