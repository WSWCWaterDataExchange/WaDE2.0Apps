# App: App2_Aggregated_v2d

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
    
    setBackgroundColor(
      color = "#e6ffe6",
      shinydashboard = TRUE
    ),
    
    ## Header
    fluidRow(
      box(width = 9, height = 325, status="success",
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
              <img src='wswclogo.jpg' alt='https://www.westernstateswater.org/' width='180' height='250' class='center'>
            </div>
            <div class='col-md-9'>
              <h1 style='text-align:center'><b><u> WSWC Aggregate Water Use Map v2d </b></u></h1>
              <p style='text-align:center'> A web tool used to summarize aggregated annual water use for a given area across the Western United States.</p>
              <br>
              <p style='color:red; text-align:center'> DISCLAIMER: This tool is under construction, not for public use, and has not yet been fully approved by our member states.</p>
              <p style='color:red; text-aglgn:center'><b> WARNING: Individual states use separate methods to estimate water use.  As a result, water use data comparison across states lines is not necessarily exact.  Before drawing any conclusions or making comparison, consult the state's utilized method on water data creation. </b></p>
              <h3 style='text-align:center'><i><u> Instructions </u></i></h3>
              <p style='text-align:center'> Select desired reporting year from dropdown. Use map tabs to select area type. Click on polygon for more info below.</p>
            </div>
          </body>
        </html>
        ")
      ), 
      
      ## Input & Instructions
      box(width = 3, status="success",
          HTML("
                   <h4 style='text-align:center'; class='parallax'><u> Map Selection Tools</u></h4>
                 "),
          actionButton(inputId="reset_input", label="Reset Inputs"),
          selectInput(inputId = 'VariableCVInput', label = 'Variable Type', 
                      choices = VariableCVList, selected = "Consumptive Use"),
          selectInput(inputId = 'ReportYearInput', label = 'Report Year', 
                      choices = AllReportYearList, selected = 2005),
          pickerInput(inputId = 'StateInput', label = 'Select Visible State', 
                      choices = StateList, selected = StateList,
                      multiple = TRUE),
          pickerInput(inputId = "BenUseInput", label = "Benificial Use", 
                      choices = BenUseList, selected = BenUseList,
                      multiple = TRUE)
      )
    ), #endfluidRow
    
   
    ## Output Map
    fluidRow(
      box(width = 12, status="success",
          tabsetPanel(
            id = "tab_being_displayed", # will set input$tab_being_displayed
            
            ##County
            tabPanel(title = "County",
                     leafletOutput(outputId = "CountyMap", height=600)
            ),
            
            ##HUC8Map
            tabPanel(title = "HUC8",
                     leafletOutput(outputId = "HUC8Map", height=600)
            ),
            
            ##CustomSF
            tabPanel(title = "Custom",
                     leafletOutput(outputId = "CustomMap", height=600)
            ),
            
            ##DAUCOSF
            tabPanel(title = "Detailed Analysis Units by County",
                     leafletOutput(outputId = "DAUCOMap", height=600)
            ),
            
            ##HydrologicRegionSF
            tabPanel(title = "Hydrologic Region",
                     leafletOutput(outputId = "HydrologicRegionMap", height=600)
            ),
            
            ##USBR_UCRB_TributarySFMap
            tabPanel(title = "USBR Upper Colorado River Basin Tributarys",
                     leafletOutput(outputId = "USBR_UCRB_TributaryMap", height=600)
            )
            
          ) #endtabsetPanel
      ) #endbox
    ), #end fluidRow
    
    
    ## Output Plots A-B
    fluidRow(
      HTML("
        <h3 style='text-align:center'; class='parallax'> 
        <br>
        <b> Annual Water Use Plots (click desired area on map) </b>
        </h3>
      "),
      tabBox(title = "Beneficial Use", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_A")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_A"))
      ),
      tabBox(title = "Water Source Type", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_B")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_B"))
      )
    ), #end fluidRow
    
    
    ## Output Plots C-D
    fluidRow(
      tabBox(title = "Variable Type", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_C")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_C"))
      ),
      tabBox(title = "Variable Specific Type", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_D")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_D"))
      )
    ), #end fluidRow
    

    ## API Tables
    fluidRow(
      HTML("
        <h3 style='text-align:center'; class='parallax'> 
        <br>
        WaDE Data Tables (click desired area on map)
        </h3>
      ")),
    
    fluidRow(
      #Organizations API Table
      box(
        width = 12, status="success",
        h3(strong("Organizations"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('OrganizationsTable'))
      ),
      
      #WaterSources API Table
      box(
        width = 12, status="success",
        h3(strong("WaterSources"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('WaterSourcesTable'))
      ),
      
      #VariableSpecifics API Table
      box(
        width = 12, status="success",
        h3(strong("VariableSpecifics"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('VariableSpecifics'))
      ),
      
      #Methods API Table
      box(
        width = 12, status="success",
        h3(strong("Methods"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('MethodsTable'))
      ),
      
      #BeneficialUses API Table
      box(width = 12, status="success",
          h3(strong("BeneficialUses"), align = "center"),
          div(style = 'overflow-x: scroll', DT::dataTableOutput('BeneficialUsesTable'))
      ),
      
      #ReportingUnits API Tables
      box(
        width = 12, status="success",
        h3(strong("ReportingUnits"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('ReportingUnits'))
      ),
      
      #AggregatedAmounts Table
      box(
        width = 12, status="success",
        h3(strong("AggregatedAmounts"), align = "center"),
        div(style = 'overflow-x: scroll', DT::dataTableOutput('AggregatedAmountsTable'))
      )
    ) #endfluidRow
    
  ) #enddashboardBody
) #end dashboardPage