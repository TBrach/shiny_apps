#Tab02 <- tabPanel("Add",
Tab01 <- sidebarPanel(
                  wellPanel(
                          #tags$br(),
                          selectInput(inputId = "person", label = "Done by", choices = c("Iben", "Thorsten"), selected = "Thorsten"),
                          selectInput(inputId = "what", label = "What did you do?", choices = "", selected = ""), # see choices update in server
                          dateInput(inputId = "date", label = "Date"),
                          textOutput(outputId = 'date_status'),
                          actionButton(inputId = "done_and_save", label = "Done"),
                          textOutput(outputId = 'infoTextExtra')
                  ), 
                  
                  wellPanel(
                      #tags$br(),
                      tags$h5("Add items. Date above used as Done."),
                      textInput(inputId = "area", label = "Area", value = "", placeholder = "kitchen"),
                      textInput(inputId = "item", label = "Item", value = "", placeholder = "mop floor"),
                      numericInput(inputId = "freq", label = "Frequency in days", value = 7),
                      actionButton(inputId = "add_and_save", label = "Add item"),
                      tags$h5("Remove item using inputs from above."),
                      actionButton(inputId = "remove_and_save", label = "Remove item")
                  ),
)