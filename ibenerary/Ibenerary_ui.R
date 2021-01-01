# - source all the tabs -
tabpath <- "./Tabs_ui"
source(file.path(tabpath, "html_styles_ui.R"))
source(file.path(tabpath, "Tab01_ui.R"))
# --


ui <- fluidPage(
        html_styles,
        TitleP,
        WellP,
        Tab01
)