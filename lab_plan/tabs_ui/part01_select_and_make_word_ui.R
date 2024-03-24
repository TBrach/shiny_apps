part_01 <- sidebarPanel(
                  wellPanel(
                          #tags$br(),
                          selectInput(inputId = "sample_type", label = "Sample type", choices = c("feces", "feces in buffer", "skin swab", "saliva", "saliva in buffer"), selected = "feces"), # see choices update in server
                          selectInput(inputId = "provided", label = "Provided", choices = c("sample", "extracted DNA"), selected = "sample"),
                          selectInput(inputId = "data_type", label = "Data type", choices = c("shotgun", "16S"), selected = "shotgun"),
                          selectInput(inputId = "sequencing_provider", label = "Sequencing provider", choices = c("Dante", "Novogene", "MiSeq-DK"), selected = "Dante"),
                          dateInput(inputId = "date", label = "Date"),
                          textOutput(outputId = 'date_status'),
                          actionButton(inputId = "create_word", label = "Create labplan as word file"),
                          textOutput(outputId = 'infoTextExtra') #,
                          
                          # could be used in case you want the option to change biomass
                          # selectInput(inputId = "biomass", label = "Biomass", choices = c("normal", "low"), selected = "normal"),
                  )
)
