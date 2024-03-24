html_styles <- tags$head(
        # set color of the info texts
        tags$style(HTML("
                        .shiny-text-output {
                        color: rgb(102,0,51);
                        font-size: 15px;
                        }
                        ")),
        tags$style(HTML("
                        .shiny-output-error-validation {
                        color: red;
                        }
                        "))
)