
library(shiny)


# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Trial Analysis"),
  
  sidebarPanel(
    selectInput("chartType", "Choose chart type:", 
                choices = c("Requests by Week",
                            "Requests by Category",
                            "Requests by Size", 
                            "Requests by Hour", 
                            "Requests by Quantity",
                            "Top 15 Brands")),
      
    submitButton("Refresh the graph")
  ),
  
  
  mainPanel(
    verbatimTextOutput("weekRangeToShow"),
    tabsetPanel(
      tabPanel("Chart", plotOutput("chartSelected")),
      tabPanel("DataSet", tableOutput("datasetTable"))
      )
  )
))

