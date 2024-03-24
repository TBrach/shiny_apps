# - source all the tabs -
tabpath <- "./tabs_ui"
source(file.path(tabpath, "html_styles_ui.R"))
# source(file.path(tabpath, "Tab01_Done_ui.R"))
source(file.path(tabpath, "Tab01_done_part_ui.R"))
source(file.path(tabpath, "Tab02_main_ui.R"))
# --

# - generate the fluid page with the loaded parts -
ui <- fluidPage(
        html_styles,
        sidebarLayout(
                Tab01,
                Tab02
        )
        
)
# --