part_01 <- sidebarPanel(
  wellPanel(
    fileInput(inputId = "sample_list_file", "1.) Choose sample list file, must be: Excel File",
              accept = c(".xlsx")
    )
  ),
  wellPanel(
    tags$h5("2.) Set all parameters for reading the excel file correctly"),
    #tags$br(),
    textInput(inputId = "your_name", label = "Your full name", value = "", placeholder = "Super Mario"),
    textInput(inputId = "study_id", label = "Study name", value = "", placeholder = "cmd00015"),
    textInput(inputId = "folder_with_sample_list", label = "Please write the directory of the folder with the sample list here (best copy from terminal!):", value = "", placeholder = "~/Boxcryptor/OneDrive-SharedLibraries-ClinicalMicrobiomics/"),
    
    # shinyDirButton(id = "dir", label = "Or select the folder with the sample list here (takes preference!)", title = "Choose Folder"),
    # verbatimTextOutput(outputId = "selected_dir"),
    
    textInput(inputId = "sheet", label = "sheet", value = "SampleOverview", placeholder = "SampleOverview"),
    numericInput(inputId = "skip", label = "skip", value = 2),
    textInput(inputId = "range", label = "range (takes precedence over skip)", value = "", placeholder = "B3:F115"),
    textInput(inputId = "sample_name_column", label = "Sample name column", value = "Sample name", placeholder = "Sample name"),
    textInput(inputId = "comment_column", label = "Comment name column", value = "Comments", placeholder = "Comments"),
    
    textOutput(outputId = 'infoTextExtra'),
    
    # dateInput(inputId = "date", label = "Date"),
    # textOutput(outputId = 'date_status'),
    
    # could be used in case you want the option to change biomass
    # selectInput(inputId = "biomass", label = "Biomass", choices = c("normal", "low"), selected = "normal"),
  ),
  
  wellPanel(
    tags$h5("3.) Create benchling_sample_list (or get feedback about problems in sample list :))"),
    
    checkboxInput(inputId = "cm_barcode", label = "CM barcode provided (will become both sample name and sample code)", value = FALSE),
    checkboxInput(inputId = "shorten", label = "Use shortened sample names in sample code", value = FALSE),
    checkboxInput(inputId = "left", label = "Shorten sample name from left instead of right", value = FALSE),
    
    actionButton(inputId = "create_bsl", label = "Create benchling sample list and save in selected output directory"),
    
  ),
  
  wellPanel(
    tags$h5("4.) Save the generated benchling_sample_list on your computer"),
    downloadButton(outputId = "save_bsl", label = "Save benchling_sample_list as excel file")
  )
  
)
