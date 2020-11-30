
library(shiny)

# Define UI for application that draws a histogram
shinyUI(
    
    navbarPage("Transit Shed Explorer", id='nav',
    
    tabPanel("Map",
               
    div(class = "outer",
        tags$head(
            # Include our custom CSS
            includeCSS("styles.css")
        ),

    leafletOutput("mymap", height ="100%", width = "100%"),
        
    # Sidebar with a slider input for number of bins
 
        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                      width = 330, height = "auto",
            
            h3('Controls'),
            
            dateInput("date", strong("Date"), 
                      min = "2020-10-22", 
                      max = NULL, 
                      format = "mm-dd-yyyy",
                      value = "2020-10-22", 
                      startview = "month", 
                      autoclose = TRUE),
            
            fluidRow(
            column(4, numericInput("hh", strong("Hour"), 8, min = 1, max = 12, step = 1)),
            column(4, numericInput("mm", strong("Min"), 30, min = 1, max = 59, step = 1)),
            column(4, selectInput("am_pm", strong("AM/PM"), choices = c("am","pm"), selected = "am")),
            ),
            
            sliderInput("mins", strong("Travel Time"), min = 10, max = 60, value = 60, step = 10),
            checkboxGroupInput("modes", strong("Select Modes"), 
                               choices = c('WALK','BICYCLE','TRANSIT'), selected = c('WALK', 'TRANSIT'), inline = TRUE),
            sliderInput("walk", strong("Max. Walk Distance (Mi.)"), min = 0.25, max = 2, value = 0.5, step = 0.25, ticks = FALSE),
            
            fluidRow(
        
            column(5, numericInput("transfer", strong('Transfer Time (Mins)'), 2, min = 1, max = 5, step = 0.5)),
            column(5, numericInput("max_transfer", strong(paste("Max # of Transfers")), 1, min = 0, max = 3, step = 1)),
            ),
            
            checkboxInput("wheelchair", strong("Wheelchair Accessible")),
            actionButton("go", strong('Calculate Transit Shed!'), icon = NULL),
            actionButton("stop", "Show Nearby Stops")
        
            )
        )
    )
))
