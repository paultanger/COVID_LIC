library(shiny)
library(qs)
# https://shiny.rstudio.com/tutorial/

# load data - only works in the app
AllPeakData.agg.all = qread('data/AllPeakDataAggAllAges_20200511_1020.qs')

# Define UI for application
ui <- shinyUI(pageWithSidebar(
    
    # Application title
    headerPanel("COVID data in LIC from CMMID at LSHTM"),
    
    # Sidebar with controls to select a dataset and specify the number
    # of observations to view
    sidebarPanel(
        selectInput("dataset", "Choose a dataset:", 
                    choices = c("from May 5 2020 qs files")),
        
        numericInput("obs", "Number of rows to view:", 10),
        
        downloadButton("downloadData", "Download")
    ),
    
    # Show a summary of the dataset and an HTML table with the requested
    # number of observations
    mainPanel(
        verbatimTextOutput("summary"),
        
        tableOutput("view")
    )
))

##################################################
# Define server logic required
server <- shinyServer(function(input, output) {
    
    # Return the requested dataset
    datasetInput <- reactive({
        switch(input$dataset,
               "from May 5 2020 qs files" = AllPeakData.agg.all)
    })
    
    # Generate a summary of the dataset
    output$summary <- renderPrint({
        dataset <- datasetInput()
        summary(dataset)
    })
    
    # Show the first "n" observations
    output$view <- renderTable({
        head(datasetInput(), n = input$obs)
        #head(datasetInput())
    })
        
    # download data function
    output$downloadData <- downloadHandler(
        filename = function() {
            paste(input$dataset, ".csv", sep = "")
        },
        content = function(file) {
            write.csv(datasetInput(), file, row.names = FALSE)
        }
    )
        
    
})

# Run the application 
shinyApp(ui = ui, server = server)
