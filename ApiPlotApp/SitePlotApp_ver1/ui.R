# App: SitePlotApp_ver1
# Sec 0. Code Notes and Purpose
# Date: 05/06/2020
# Topic: 1) Receive Query Paramter from Sites App, Query WaDE 2.0 QA, load return JSON into workable format.


################################################################################################
################################################################################################
# Sec 1a. Needed Libaries & Input Files
# Libraries
library(jsonlite)
library(shiny)
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(curl)
library(rJava)
library(xlsx)
library(DT) # Used to create more efficent data table output.
library(shinydashboard) # The layout used for the ui page.

################################################################################################
################################################################################################
# Sec 2. Custom Header
# The 'a' tag creates a link to a web page.

titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "WaDE 2.0 QA Database Site Data"
                    )

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
    
    fluidRow(
      box(
        h5(strong("Query Parameter (SiteUUID)"), align = "center"),
        textInput("SQPInput", "SQPInput", value = "")
      ),
      box(
        h5(strong("Download Tables to Excel Workbook"), align = "center"),
        downloadButton("downloadExcel", "downloadExcel")
      )
    ),
    
    br(), br(),
    
    #Organizations Table
    tags$head(tags$style("#OrganizationsTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("Organizations"), align = "center"),
      dataTableOutput(outputId="OrganizationsTable")
    ),
    
    br(), br(),
    
    #WaterSources Table"
    tags$head(tags$style("#WaterSourcesTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("WaterSources"), align = "center"),
      dataTableOutput("WaterSourcesTable")
    ),
    
    br(), br(),
    
    #VariableSpecifics Table
    tags$head(tags$style("#VariableSpecificsTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("VariableSpecifics"), align = "center"),
      dataTableOutput("VariableSpecificsTable")
    ),
    
    br(), br(),
    
    #Methods Table
    tags$head(tags$style("#MethodsTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("Methods"), align = "center"),
      dataTableOutput("MethodsTable")
    ),
    
    br(), br(),
    
    #BeneficialUses Table
    tags$head(tags$style("#BeneficialUsesTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("BeneficialUses"), align = "center"),
      dataTableOutput("BeneficialUsesTable")
    ),
    
    br(), br(),
    
    #Sites Table
    tags$head(tags$style("#SitesTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("Sites"), align = "center"),
      dataTableOutput("SitesTable")
    ),
    
    br(), br(),
    
    #AggregatedAmounts Table
    fluidRow(
      h3(strong("WaterAllocations"), align = "center"),
      DT::dataTableOutput("WaterAllocationsTable")
    )
    
  ) #end dashboardBody
  
) #end dashboardPage


# shinyUI(fluidPage(
#   
#   # Application title
#   titlePanel("WaDE 2.0 QA Site JSON Return"),
#   
#   # Sidebar with a slider input for number of bins
#   sidebarLayout(
#     sidebarPanel(
#       textInput("SQPInput", "Query Parameter (SiteUUID)", value = ""),
#       downloadButton("downloadExcel", "Download Tables to Excel Workbook")
#     ),
#     
#     # Show a plot of the generated distribution
#     mainPanel(
#       fluidRow(withSpinner(textOutput("textOutA"))),
#       br(), br(),
#       helpText("OrganizationsTable.", align = "center"),
#       fluidRow(withSpinner(tableOutput("OrganizationsTable"))),
#       br(), br(),
#       helpText("WaterSourcesTable", align = "center"),
#       fluidRow(withSpinner(tableOutput("WaterSourcesTable"))),
#       br(), br(),
#       helpText("VariableSpecificsTable", align = "center"),
#       fluidRow(withSpinner(tableOutput("VariableSpecificsTable"))),
#       br(), br(),
#       helpText("MethodsTable", align = "center"),
#       fluidRow(withSpinner(tableOutput("MethodsTable"))),
#       br(), br(),
#       helpText("BeneficialUsesTable", align = "center"),
#       fluidRow(withSpinner(tableOutput("BeneficialUsesTable"))),
#       br(), br(),
#       helpText("WaterAllocationsTable", align = "center"),
#       fluidRow(withSpinner(tableOutput("WaterAllocationsTable"))),
#       br(), br(),
#       helpText("SitesTable", align = "center"),
#       fluidRow(withSpinner(tableOutput("SitesTable"))),
#       br(), br()
#     )
#   )
# ))
