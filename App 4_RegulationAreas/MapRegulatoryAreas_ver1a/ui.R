# App: MapRegulatoryAreas_ver1a

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
      box(width = 8, status="danger",
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
              <h1 style='text-align:center'; class='parallax'> WSWC Regulation Areas Map </h1>
              <p style='text-align:center'; class='parallax_description'>A web tool used to visualize the area of effect of water rights and water use regulations across the Western United States.</p>
              <p style='color:red; text-align:center'; class='parallax_description'>DISCLAIMER: This tool is under construction, not for public use, and has not yet been fully approved by our member states.</p>
            </div>
          </body>
        </html>
        ")
      ), 
      
      ## Input & Instructions
      box(width = 4, status="danger",
          HTML("
                   <h4 style='text-align:center'; class='parallax'> Instructions </h4>
                   <p style='text-align:left'; class='parallax_description'> Click on desired area for more info below.</p>
                 "),
          selectInput(inputId = 'basemapInput', label = 'Basemap Selector', 
                      choices = basemapProvdierList, selected = providers$Esri.WorldStreetMap),
          pickerInput(inputId = 'StateInput', label = 'Select Visible State', 
                      choices = StateList, selected = StateList,
                      multiple = TRUE),
          pickerInput(inputId = 'BoundaryTypeInput', label = 'Select Regulation Boundary Type', 
                      choices = BoundaryTypeList, selected = BoundaryTypeList,
                      multiple = TRUE)
      )
    ), #endfluidRow
    
    
    ## Output Map
    fluidRow(
      box(width = NULL, status="danger",
          tabsetPanel(
            id = "tab_being_displayed", # will set input$tab_being_displayed
            
            ##RegAMap
            tabPanel(title = "Regulatory Area", leafletOutput(outputId="RegAMap", height=600)
            ) #end tabPanel
          ) #end tabsetPanel
      ) #end box
    ), #end fluidRow
    
    
    ## Output Plots
    fluidRow(
      HTML("
        <h4 style='text-align:center'; class='parallax'> 
        <br>
        Amounts Plots (click desired site on map)
        </h4>
      "),
      box(title = "Amount Plot", width = 6, solidHeader = TRUE, status = "danger",
          plotlyOutput(outputId = "LP_A")
      ) #end box
    ), #end fluidRow
    
    
    ## API Tables
    fluidRow(
    ) #end fluidRow
    
  ) #end dashboardBody
) #end dashboardPage