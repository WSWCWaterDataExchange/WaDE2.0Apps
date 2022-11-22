# App: Ag Landing Page Demo
# Date: 11/08/2022
# Topic: Create a landing page similar to that of WestDAAT.


################################################################################################
################################################################################################
# Sec 1. Needed Libraries & Input Files
# Libraries
library(shiny)
library(shinydashboard) # The layout used for the ui page.
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(DT) # Provides an R interface to the JavaScript library DataTables
library(xlsx) # The xlsx package gives programatic control of Excel files using R
library(jsonlite) # These functions are used to convert between JSON data and R objects.
library(curl)  # Drop-in replacement for base url that supports https, ftps, gzip, deflate, etc
library(rJava) # Low-level interface to Java VM very much like .C/.Call and friends. Allows creation of objects, calling methods and accessing fields.
library(leaflet) # Map making. Leaflet is more supported for shiny.
library(plotly) # To create plots within the output for the app.
library(sf) # how to work & convert data into shapefile info. 


################################################################################################
################################################################################################
# Sec 2. Custom Header
# The 'a' tag creates a link to a web page.

titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "Aggregated Area Water Budget Landing Page Demo")



################################################################################################
################################################################################################
# Sec 3. The UI (HTML Page)

ui <- dashboardPage(
  skin = "black",
  title = "Aggregated Budget Landing Page Demo",
  
  dashboardHeader(
    title = titleWSWC,
    titleWidth = 500
  ), #end dashboardPage
  
  dashboardSidebar(disable = TRUE),
  
  dashboardBody(
    
    # SiteUUId and Download Box
    fluidRow(
      # Check ReportingUnitUUID Input
      box(title = h5(strong("Query Parameter (ReportingUnitUUID)"), align = "center"), width = 10,
          textInput("SQPInput", "SQPInput", value = "")
      ),
      # Download Option
      box(width = 2,
          downloadButton("Download Data", "downloadExcel")
      )
    ), #end fluidRow
    
    # Box Tabs
    fluidRow(
      # Organization 
      box(title = "Managing Organization Agency", status = "primary", solidHeader = TRUE, width = 2,
          p(strong("Organization Name: ")), textOutput("OrganizationName"), br(),
          p(strong("State: ")), textOutput("State"), br(),
          p(strong("Website: ")), textOutput("Website")
      ),
      
      #Method
      box(title = "Method Information", status = "primary", solidHeader = TRUE, width = 3,
          p(strong("Applicable Resource Type: ")), textOutput("ApplicableResourceType"), br(),
          p(strong("Method Type: ")), textOutput("MethodType"), br(),
          p(strong("Method Link: ")), textOutput("MethodLink"), br(),
          p(strong("Method Description: ")), textOutput("MethodDescription")
      ),
      
      # ReportingUnit
      box(title = "Reporting Unit Information", status = "primary", solidHeader = TRUE, width = 3,
          p(strong("WaDE Area ID: ")), textOutput("WaDEAreaID"), br(),
          p(strong("Area Native ID: ")), textOutput("AreaNativeID"), br(),
          p(strong("Area Name: ")), textOutput("AreaName"), br(),
          p(strong("Area Type: ")), textOutput("AreaType")
      ),
      
      # Map
      box(title = "mapA", status = "primary", solidHeader = TRUE, width = 4,
          leafletOutput(outputId="mapA", height=500)
          # box content
      )
    ), #end fluidRow
    
    # Tables
    fluidRow(
      tabBox(title = "Table Info", width = 12, side='left', selected = "Variable Specifics Info",
             tabPanel("Variable Specifics Info",  dataTableOutput("Variable")),
             tabPanel("Reporting Unit Area Aggregated Budget Amount Info",  dataTableOutput("AggregatedAmounts")),
             tabPanel("Water Source Info",  dataTableOutput("WaterSources"))
      )
    ), #end fluidRow
    
    # Line Plots
    fluidRow(
      box(title = "Reporting Unit Area Aggregated Budget Water Use by Variable Specific Type", status = "info", solidHeader = TRUE, width = 12,
          plotlyOutput(outputId = "LP_A")
      )
    )
    
  ) #end dashboardBody
) #end dashboardPage