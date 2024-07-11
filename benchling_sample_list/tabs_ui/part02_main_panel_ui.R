part_02 <- mainPanel(
  wellPanel(
    tags$h6("Info 5-JULY-2024: Based on SOP-023 and after consulting with Nikolay: 
            Sample name is the labelling of the samples used by the client. Sample code is study name underscore a tidied sample name. 
            If the client provides barcodes on the tubes, they become by definition the sample name. If CM provides barcodes, they should be identical to the sample code (i.e, they must start with study name underscore).
            How this is implemented in this app: User chooses Sample name column, here the correct options: 1.) Sample name provided by the client that is on the tubes; 2.) The barcode column if provided by the client; 
            3.) CM barcode when we provided it. In this case it should be equal to sample code (and thus start with study name underscore).
            NB: IF CM barcode was provided you must make sure that study name corresponds to the prefix of the barcodes! (To allow the app to check this, PLEASE tick CM barcode provided!!
            NB: For the sample code: The app first tidies the Sample name. It also attempts to shorten the tidied sample name by removing characters that are uniform across samples (by default from the right and down to 3 characters).
            NB: shortened sample codes are stored as they could help in Protocol 01.09.02 when sending to Novo. Shortened sample names are only used in sample code if this is ticked (Nikolaj prefers no default shortening!).")
    ), 
        textOutput(outputId = 'infoText'),
        tags$br(),
        tableOutput(outputId = "bsl_table")
        # plotOutput(outputId = "calendar", height = "1250px")
        
)