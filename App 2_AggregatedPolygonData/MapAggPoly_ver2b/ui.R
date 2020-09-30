# App: MapAggPoly_ver2b

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
    
    ##Header
    fluidRow(
      box(width = 8, status="primary",
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
      
      #Input & Instructions
      box(width = 4, status="primary",
          HTML("
                   <h4 style='text-align:center'; class='parallax'> Instructions </h4>
                   <p style='text-align:left'; class='parallax_description'>Select desired reporting year from dropdown. Use tabs to select area type. Click on polygon for more info below.</p>
                 "),
          selectInput(inputId = 'ReportYearInput', label = 'Report Year', 
                      choices = AllReportYearList, selected = 2005)
      )
    ), #endfluidRow
    
    
    ## Output Maps & API Tables
    fluidRow(
      box(width = NULL, status="primary",
          tabsetPanel(
            id = "tab_being_displayed", # will set input$tab_being_displayed
            
            ##County
            tabPanel(title = "County",
                     fluidRow(
                       leafletOutput(outputId="CountyMap", height=600)
                     ),
                     HTML("
                      <h4 style='text-align:center'; class='parallax'> 
                        <br>
                        Consumptive Use Plots (click desired area on map)
                      </h4>
                    "),
                     fluidRow(
                       box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId = "LP_County_A")),
                       box(title = "VariableType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId = "LP_County_B")
                       )
                     )
            ),
            
            ##HUC8Map
            tabPanel(title = "HUC8",
                     fluidRow(
                       leafletOutput(outputId = "HUC8Map", height=600)
                     ),
                     HTML("
                      <h4 style='text-align:center'; class='parallax'> 
                        <br>
                        Consumptive Use Plots (click desired area on map)
                      </h4>
                    "),
                     fluidRow(
                       box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId = "LP_HUC8_A", height = 300)),
                       box(title = "VariableType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId = "LP_HUC8_B", height = 300))
                     )
            ),
            
            ##CustomSF
            tabPanel(title = "Custom",
                     fluidRow(
                       leafletOutput(outputId = "CustomMap", height=600)
                     ),
                     HTML("
                      <h4 style='text-align:center'; class='parallax'> 
                        <br>
                        Consumptive Use Plots (click desired area on map)
                      </h4>
                    "),
                     fluidRow(
                       box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId="LP_Custom_A", height = 300)),
                       box(title = "VariableType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId="LP_Custom_B", height = 300))
                     )
            ),
            
            ##USBR_UCRB_TributarySFMap
            tabPanel(title = "USBR Upper Colorado River Basin Tributarys",
                     fluidRow(
                       leafletOutput(outputId = "USBR_UCRB_TributaryMap", height=600)
                     ),
                     HTML("
                      <h4 style='text-align:center'; class='parallax'> 
                        <br>
                        Consumptive Use Plots (click desired area on map)
                      </h4>
                    "),
                     fluidRow(
                       box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId="LP_USBR_UCRB_Tributary_A", height = 300)),
                       box(title = "VariableType", width = 6, solidHeader = TRUE, status = "primary",
                           plotlyOutput(outputId="LP_USBR_UCRB_Tributary_B", height = 300))
                     )
            )
            
          ) #endtabsetPanel
      ) #endbox
    ) #end fluidRow
  ) #enddashboardBody
) #end dashboardPage