# App: AggPlotApp_ver1
# Sec 0. Code Notes and Purpose
# Date: 05/14/2020
# Topic: 1) Receive Query Paramter from Aggreated App, Query WaDE 2.0 QA, load return JSON into workable format.


################################################################################################
################################################################################################
# Sec 1. Needed Libaries & Input Files
# Libraries
library(jsonlite)
library(shiny)
library(shinycssloaders) # Adds spinner icon to loading outputs.
library(curl)
library(DT) # Used to create more efficent data table output.
library(ggplot2)
library(rJava)
library(xlsx)
library(shinydashboard) # The layout used for the ui page.

################################################################################################
################################################################################################
# Sec 2. Custom Header
# The 'a' tag creates a link to a web page.

titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                tags$img(src='wswclogo.jpg', height=70, width=50),
                "WaDE 2.0 QA Database Aggreated Data"
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
    # tags$head(tags$style( type = 'text/css',  '.rpivotTable{ overflow-x: scroll; }')), # Adds scrollbar
    
    fluidRow(
      box(
        h5(strong("Query Parameter (ReportingUnitUUID)"), align = "center"),
        textInput("RUUUIDInput", "RUUUIDInput", value = "")
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
      dataTableOutput(outputId="WaterSourcesTable")
      ),
    
    br(), br(),
    
    #ReportingUnits Table
    tags$head(tags$style("#ReportingUnitsTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("ReportingUnits"), align = "center"),
      dataTableOutput(outputId="ReportingUnitsTable")
      ),
    
    br(), br(),
    
    #VariableSpecifics Table
    tags$head(tags$style("#VariableSpecificsTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("VariableSpecifics"), align = "center"),
      dataTableOutput(outputId="VariableSpecificsTable")
      ),
    
    br(), br(),
    
    #Methods Table
    tags$head(tags$style("#MethodsTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("Methods"), align = "center"),
      dataTableOutput(outputId="MethodsTable")
      ),
    
    br(), br(),
    
    #BeneficialUses Table
    tags$head(tags$style("#BeneficialUsesTable table {background-color: lightgrey; }", media="screen", type="text/css")),
    fluidRow(
      h3(strong("BeneficialUses"), align = "center"),
      dataTableOutput(outputId="BeneficialUsesTable")
      ),
    
    br(), br(),
    
    #AggregatedAmounts Table
    fluidRow(
      h3(strong("WaterAllocations"), align = "center"),
      DT::dataTableOutput(outputId="WaterAllocationsTable")
      )

  ) #end dashboardBody
  
) #end dashboardPage

