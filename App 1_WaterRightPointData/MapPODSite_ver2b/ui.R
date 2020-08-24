# App: MapPODSite_ver2b

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
    fluidRow(
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
              <h1 style='text-align:center'; class='parallax'> WSWC POD Water Allocation Map </h1>
              <p style='text-align:center'; class='parallax_description'>A web tool used to located point of diversion sites for water rights across the Western United States.</p>
              <p style='color:red; text-align:center'; class='parallax_description'>DISCLAIMER: This tool is under construction, not for public use, and has not yet been approved by our member states.</p>
            </div>
          </body>
        </html>
        ")
    ),
    
    fluidRow(
      
      ## App & WSWC Description, App Inputs
      column(width = 2,
             box(width = NULL, status="primary",
                 HTML("
                   <h4 style='text-align:center'; class='parallax'> Instructions </h4>
                   <p style='text-align:left'; class='parallax_description'>Use filters tools to reduce selection.  Click on point to view more information in tables below.</p>
                 ")
             ),
             box(width = NULL, status="primary", title = "Inputs",
                 actionButton(inputId="reset_input", label="Reset Inputs"),
                 
                 helpText("-------------", align = "center"),
                 pickerInput(inputId='SiteTypeInput', label='Site Type', 
                             choices=SiteTypeList, selected=SiteTypeList,
                             multiple = TRUE),
                 pickerInput(inputId='WaterSourceTypeInput', label='Watersource Type', 
                             choices=WaterSourceTypeList, selected=WaterSourceTypeList,
                             multiple = TRUE),
                 pickerInput(inputId='AllocationOwnerInput', label='Allocation Owner', 
                             choices=AllocationOwnerList, selected=AllocationOwnerList,
                             multiple = TRUE),
                 
                 
                 helpText("-------------", align = "center"),
                 sliderInput("DateInput", "Priority Date (yyyy-mm-dd)",
                             min = as.Date("1850-01-01","%Y-%m-%d"),
                             max = as.Date("2016-09-09","%Y-%m-%d"),
                             value = c(as.Date("1850-01-01","%Y-%m-%d"), as.Date("2016-09-09","%Y-%m-%d")),
                             timeFormat="%Y-%m-%d"),
                 pickerInput(inputId = 'RiverBasin', label = 'River Basin', 
                             choices = RiverBasinList, selected = RiverBasinList,
                             multiple = TRUE),
                 pickerInput(inputId = "StateInput", label = "State", 
                             choices = StateList, selected = StateList,
                             multiple = TRUE),
                 pickerInput(inputId = "BenUseInput", label = "Primary Benificial Use", 
                             choices = BenUseList, selected = BenUseList,
                             multiple = TRUE),
                 helpText("-------------", align = "center"),
                 helpText("Allocation Flow", align = "center"),
                 numericInput(inputId = "minAA_CFS", label = "Minimum CFS", value = 0,
                              min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
                 numericInput(inputId = "maxAA_CFS", label = "Maximum CFS", value = max(P_AlloLFSite$AA_CFS),
                              min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
                 helpText("-------------", align = "center"),
                 helpText("Allocation Volume", align = "center"),
                 numericInput(inputId = "minAA_AF", label = "Minimum AF", value = 0,
                              min = 0, max = max(P_AlloLFSite$AA_AF), step = NA, width = NULL),
                 numericInput(inputId = "maxAA_AF", label = "Maximum AF", value = max(P_AlloLFSite$AA_AF),
                              min = 0, max = max(P_AlloLFSite$AA_AF), step = NA, width = NULL)
             )
      ), #endColumn
      
      ## Output Maps & API Tables
      column(width = 10,
             box(width = NULL, status="primary",
                 tabsetPanel(
                   id = "tab_being_displayed", # will set input$tab_being_displayed
                   
                   #All Sites Map
                   tabPanel(title = "All Sites",
                            withSpinner(mapdeckOutput(outputId = "mapAll", height = 600)),
                            HTML("
                      <h4 style='text-align:center'; class='parallax'> 
                        <br>
                        Point of Diversion Sites (click desired site on map for more info)
                      </h4>
                    "),
                   ), #endtabPanel
                   
                   #Basins Sites Map
                   tabPanel(title = "River Basins",
                            withSpinner(mapdeckOutput(outputId = "mapBasins", height = 800)),
                            HTML("
                      <h4 style='text-align:center'; class='parallax'> 
                        <br>
                        Point of Diversion Sites (click desired site on map for more info)
                      </h4>
                    "),
                   ) #endtabPanel
                 ) # endtabsetPanel
             ),
             
             #Organizations API Table
             box(
               width = NULL,
               status="info",
               h3(strong("Organizations"), align = "center"),
               div(style = 'overflow-x: scroll', DT::dataTableOutput('OrganizationsTable'))
             ),
             
             #WaterSources API Table
             box(
               width = NULL, 
               status="info",
               h3(strong("WaterSources"), align = "center"),
               div(style = 'overflow-x: scroll', DT::dataTableOutput('WaterSourcesTable'))
             ),
             
             #VariableSpecifics API Table
             box(
               width = NULL, 
               status="info",
               h3(strong("VariableSpecifics"), align = "center"),
               div(style = 'overflow-x: scroll', DT::dataTableOutput('VariableSpecificsTable'))
             ),
             
             #Methods API Table
             box(
               width = NULL, 
               status="info",
               h3(strong("Methods"), align = "center"),
               div(style = 'overflow-x: scroll', DT::dataTableOutput('MethodsTable'))
             ),
             
             #BeneficialUses API Table
             box(width = NULL, 
                 status="info",
                 h3(strong("BeneficialUses"), align = "center"),
                 div(style = 'overflow-x: scroll', DT::dataTableOutput('BeneficialUsesTable'))
             ),
             
             #Sites API Tables
             box(
               width = NULL, 
               status="info",
               h3(strong("Sites"), align = "center"),
               div(style = 'overflow-x: scroll', DT::dataTableOutput('SitesTable'))
             ),
             
             #AggregatedAmounts Table
             box(
               width = NULL, 
               status="info",
               h3(strong("WaterAllocations"), align = "center"),
               div(style = 'overflow-x: scroll', DT::dataTableOutput('WaterAllocationsTable'))
             )
             
      ) #endColumn
    ) #endFluidRow
    
    # tags$head(includeHTML(("google-analytics.html")))  # for use with Google Analytics
    
  ) #enddashboardBody
) #enddashboardPage