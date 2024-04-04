part_01 <- sidebarPanel(
                  wellPanel(
                          #tags$br(),
                          selectInput(inputId = "sample_type", label = "Sample type", choices = c("feces", "feces in buffer", "skin swab", "saliva", "saliva in buffer"), selected = "feces"), # see choices update in server
                          selectInput(inputId = "provided", label = "Provided", choices = c("sample", "extracted DNA"), selected = "sample"),
                          selectInput(inputId = "data_type", label = "Data type", choices = c("shotgun", "16S"), selected = "shotgun"),
                          selectInput(inputId = "sequencing_provider", label = "Sequencing provider", choices = c("Dante", "Novogene", "MiSeq-DK"), selected = "Dante"),
                          actionButton(inputId = "create_labplan_table", label = "Check labplan table"),
                          textOutput(outputId = 'infoTextExtra') #,
                          
                          # could be used in case you want the option to change biomass
                          # selectInput(inputId = "biomass", label = "Biomass", choices = c("normal", "low"), selected = "normal"),
                  ),
                  wellPanel(
                      #tags$br(),
                      textInput(inputId = "study_name", label = "Study name", value = "", placeholder = "cmidem"),
                      textInput(inputId = "lab_lead", label = "Lab lead", value = "Thorsten Brach", placeholder = "Thorsten Brach"),
                      textInput(inputId = "background", label = "Background and objectives", value = "", placeholder = "Project with client bla bla"),
                      textInput(inputId = "clinical_protocol", label = "Clinical protocol", value = "Not applicable.", placeholder = "If applicable, reference the clinical protocol and explain compliance with it."),
                      textInput(inputId = "sample_handling", label = "Sample handling", value = "To be discussed with client.", placeholder = "For how long should samples be stored before being discarded/shipped back?"),
                      dateInput(inputId = "date", label = "Date"),
                      textOutput(outputId = 'date_status'),
                      shinyDirButton(id = "dir", label = "Select output directory", title = "Choose Folder"),
                      verbatimTextOutput(outputId = "selected_dir"),
                      actionButton(inputId = "create_word", label = "Create labplan as word file")
                      
                      # could be used in case you want the option to change biomass
                      # selectInput(inputId = "biomass", label = "Biomass", choices = c("normal", "low"), selected = "normal"),
                  )
)
