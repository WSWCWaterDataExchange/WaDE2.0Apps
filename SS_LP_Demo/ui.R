# App: Site-Specific Landing Page Demo
# Date: 10/17/2022
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


################################################################################################
################################################################################################
# Sec 2. Custom Header
# The 'a' tag creates a link to a web page.

titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "landing page demo")



################################################################################################
################################################################################################
# Sec 3. The UI (HTML Page)

ui <- dashboardPage(
  skin = "black",
  
  dashboardHeader(
    title = titleWSWC,
    titleWidth = 500
  ), #end dashboardPage
  
  dashboardSidebar(disable = TRUE),
  
  dashboardBody(
    
    # SiteUUId and Download Box
    fluidRow(
      # Check SiteUUID Input
      box(title = h5(strong("Query Parameter (SiteUUID)"), align = "center"), width = 10,
          textInput("SQPInput", "SQPInput", value = "")
      ),
      # Download Option
      box(width = 2,
          downloadButton("Download Data", "downloadExcel")
      )
    ),#end fluidRow
    
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
      
      # Site
      box(title = "Site Information", status = "primary", solidHeader = TRUE, width = 3,
          p(strong("WaDE Site ID: ")), textOutput("WaDESiteID"), br(),
          p(strong("Site Native ID: ")), textOutput("SiteNativeID"), br(),
          p(strong("Site Name: ")), textOutput("SiteName"), br(),
          p(strong("Longitude: ")), textOutput("Longitude"), br(),
          p(strong("Latitude: ")), textOutput("Latitude"), br(),
          p(strong("County: ")), textOutput("County"), br(),
          p(strong("Site Type: ")), textOutput("SiteType"), br(),
          p(strong("POD or POU: ")), textOutput("PODorPOU")
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
             tabPanel("Site Specific Amount Info",  dataTableOutput("SiteSpecificAmount")),
             tabPanel("Water Source Info",  dataTableOutput("WaterSources"))
      )
    ), #end fluidRow
    
    # Line Plots
    fluidRow(
      box(title = "Site Specific Water Use by Variable Specific Type", status = "info", solidHeader = TRUE, width = 12,
          plotlyOutput(outputId = "LP_A")
      )
    )
    
  ) #end dashboardBody
) #end dashboardPage