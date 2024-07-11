# - source all the tabs -
tabpath <- "./tabs_ui"
source(file.path(tabpath, "html_styles_ui.R"))
source(file.path(tabpath, "part01_sidebar_choices_ui.R"))
source(file.path(tabpath, "part02_main_panel_ui.R"))
# --

# - generate the fluid page with the loaded parts -
ui <- fluidPage(
        html_styles,
        sidebarLayout(
                part_01,
                part_02
        )
        
)
# --