titleWSWC <- tags$a(href='https://www.westernstateswater.org/',
                    tags$img(src='wswclogo.jpg', height=70, width=50),
                    "Regulatory Overlay Area Landing Page Demo")

# Define ui
ui <- dashboardPage(
      skin = "black",
      title = "Regulatory Overlay Area Landing Page Demo",
    dashboardHeader(title = titleWSWC, titleWidth = 500), 
    dashboardSidebar(disable = TRUE),
    dashboardBody(
      fluidRow(
        
        # Check ReportingUnitUUID Input
        box(title = h5(strong("Query Parameter (ReportingUnitUUID)"), align = "center"), width = 10, textInput("SQPInput", "SQPInput", value = "")),
        
        # Download Option
        box(width = 2, downloadButton("Download Data", "downloadExcel"))
        
      ), #end fluidRow
      
      # Box Tabs
      fluidRow(
        # Organization 
        box(title = "Managing Organization Agency", status = "primary", solidHeader = TRUE, width = 2,
            p(strong("Organization Name: ")), textOutput("OrganizationName"), br(),
            p(strong("State: ")), textOutput("State"), br(),
            p(strong("Website: ")), textOutput("Website")
        ),
        
        # ReportingUnitsRegulatory
        box(title = "Reporting Units Regulatory Information", status = "primary", solidHeader = TRUE, width = 3,
            p(strong("WaDE Area ID: ")), textOutput("WaDEAreaID"), br(),
            p(strong("Area Native ID: ")), textOutput("AreaNativeID"), br(),
            p(strong("Area Name: ")), textOutput("AreaName"), br(),
            p(strong("Area Type: ")), textOutput("AreaType"), br(),
            p(strong("Water Source Type: ")), textOutput("WaterSourceType"), br()
        ),
        
        # Map
        box(title = "mapA", status = "primary", solidHeader = TRUE, width = 4,
            leafletOutput(outputId="mapA")
            # box content
        )
      ),#end fluidRow
      
      # Tables
      fluidRow(
        # RegulatoryOverlays
        tabBox(title = "Table Info", width = 12, side='left', selected = "Regulatory Overlays Info",
               tabPanel("Regulatory Overlays Info",  dataTableOutput("RegulatoryOverlays"))
        )
      ) #end fluidRow
    )# end dashboardBody
    
  )# end dashboardPage
