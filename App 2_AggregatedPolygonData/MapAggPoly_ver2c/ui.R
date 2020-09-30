# App: MapAggPoly_ver2c

################################################################################################
################################################################################################
# Sec 2. The UI (HTML Page)

ui <- dashboardPage(
  
  dashboardHeader(
    disable = TRUE
  ),
  
  dashboardSidebar(
    disable = TRUE
  ),
  
  dashboardBody(
    
    ## Header
    fluidRow(
      box(width = 8, status="success",
          HTML("
        <html>
          <head>
            <meta name='viewport' content='width=device-width, initial-scale=1'>
            <style>
              img {
                display: block;
                margin-left: auto;
                margin-right: auto;
              }
            </style>
          </head>
          <body>
            <div class='col-md-2'>
              <img src='wswclogo.jpg' alt='https://www.westernstateswater.org/' width='90' height='120' class='center'>
            </div>
            <div class='col-md-9'>
              <h1 style='text-align:center'; class='parallax'> WSWC Aggregate Water Use Map </h1>
              <p style='text-align:center'; class='parallax_description'>A web tool used to summarize aggregated annual water use for a given area across the Western United States.</p>
              <p style='color:red; text-align:center'; class='parallax_description'>DISCLAIMER: This tool is under construction, not for public use, and has not yet been fully approved by our member states.</p>
            </div>
          </body>
        </html>
        ")
      ), 
      
      ## Input & Instructions
      box(width = 4, status="success",
          HTML("
                   <h4 style='text-align:center'; class='parallax'> Instructions </h4>
                   <p style='text-align:left'; class='parallax_description'>Select desired reporting year from dropdown. Use tabs to select area type. Click on polygon for more info below.</p>
                 "),
          actionButton(inputId="reset_input", label="Reset Inputs"),
          selectInput(inputId = 'ReportYearInput', label = 'Report Year', 
                      choices = AllReportYearList, selected = 2005),
          pickerInput(inputId = 'StateInput', label = 'Select Visible State', 
                      choices = StateList, selected = StateList,
                      multiple = TRUE),
      )
    ), #endfluidRow
    
    
    ## Output Map
    fluidRow(
      box(width = NULL, status="success",
          tabsetPanel(
            id = "tab_being_displayed", # will set input$tab_being_displayed
            
            ##County
            tabPanel(title = "County",
                     leafletOutput(outputId="CountyMap", height=600)
            ),
            
            ##HUC8Map
            tabPanel(title = "HUC8",
                     leafletOutput(outputId = "HUC8Map", height=600)
            ),
            
            ##CustomSF
            tabPanel(title = "Custom",
                     leafletOutput(outputId = "CustomMap", height=600)
            ),
            
            ##USBR_UCRB_TributarySFMap
            tabPanel(title = "USBR Upper Colorado River Basin Tributarys",
                     leafletOutput(outputId = "USBR_UCRB_TributaryMap", height=600)
            )
            
          ) #endtabsetPanel
      ) #endbox
    ), #end fluidRow
    
    
    ## Output Plots
    fluidRow(
      HTML("
        <h4 style='text-align:center'; class='parallax'> 
        <br>
        Consumptive Use Plots (click desired area on map)
        </h4>
      "),
      box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "success",
          plotlyOutput(outputId = "LP_A")),
      box(title = "VariableType", width = 6, solidHeader = TRUE, status = "success",
          plotlyOutput(outputId = "LP_B")
      ) #endbox
    ), #end fluidRow
    
    
    ## API Tables
    fluidRow(
      #Organizations API Table
      box(
        width = NULL, status="success",
        h3(strong("Organizations"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('OrganizationsTable'))
      ),
      
      #WaterSources API Table
      box(
        width = NULL, status="success",
        h3(strong("WaterSources"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('WaterSourcesTable'))
      ),
      
      #VariableSpecifics API Table
      box(
        width = NULL, status="success",
        h3(strong("VariableSpecifics"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('VariableSpecifics'))
      ),
      
      #Methods API Table
      box(
        width = NULL, status="success",
        h3(strong("Methods"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('MethodsTable'))
      ),
      
      #BeneficialUses API Table
      box(width = NULL, status="success",
          h3(strong("BeneficialUses"), align = "center"),
          div(style = 'overflow-x: scroll', DT::dataTableOutput('BeneficialUsesTable'))
      ),
      
      #ReportingUnits API Tables
      box(
        width = NULL,status="success",
        h3(strong("ReportingUnits"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('ReportingUnits'))
      ),
      
      #AggregatedAmounts Table
      box(
        width = NULL, status="success",
        h3(strong("AggregatedAmounts"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('AggregatedAmountsTable'))
      )
    ) #endfluidRow
    
  ) #enddashboardBody
) #end dashboardPage