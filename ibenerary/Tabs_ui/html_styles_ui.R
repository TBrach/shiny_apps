html_styles <- tags$head(
    tags$style(HTML("
                                .shiny-text-output {
                                color: blue;
                                }
                                ")),
    tags$style(HTML("
                                .shiny-output-error-validation {
                                color: red;
                                }
                                ")),
    # tags$style(HTML("
    #                 .tab-pane {
    #                 background-color: green;
    #                 }
    #                 "))
    tags$style(HTML("
                                h2 {
                                color: orange;
                                font-size: 25px;
                                font-weight: 900;
                                }
                                "))
    
)