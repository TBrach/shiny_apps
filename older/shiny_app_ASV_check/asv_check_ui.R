# - source all the tabs -
tabpath <- "./Tabs_ui"
source(file.path(tabpath, "html_styles_ui.R"))
source(file.path(tabpath, "Tab_asv_indiv_ui.R"))
source(file.path(tabpath, "Tab_asv_groups_ui.R"))
source(file.path(tabpath, "Tab_search_asvs_ui.R"))
source(file.path(tabpath, "Tab_check_assignment_ui.R"))
source(file.path(tabpath, "Tab_asv_correlations_ui.R"))
# --



ui <- fluidPage(
        html_styles,
        tabsetPanel(type = "tabs",
                    tabPanel("ASVs", Tab_asv_indiv),
                    tabPanel("ASV groups", Tab_asv_groups),
                    tabPanel("Search ASVs", Tab_search_asvs),
                    tabPanel("Check assignment options", Tab_check_assignment),
                    tabPanel("Correlation groups", Tab_asv_correlations))
)