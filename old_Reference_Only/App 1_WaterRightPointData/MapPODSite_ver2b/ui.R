# App: App1_WaterRightPointData_v2b

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
      # color = "#ccffff",
      color = "#0F6B99",
      shinydashboard = TRUE
    ),
    
    fluidRow(
      box(width = 12, height = 260, status="primary",
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
              <img src='wswclogo.jpg' alt='https://www.westernstateswater.org/' width='160' height='220' class='center'>
            </div>
            <div class='col-md-9'>
              <h1 style='text-align:center'><b><u> WSWC POD Water Allocation Map </b></u></h1>
              <p style='text-align:center'> A web tool used to summarize aggregated annual water use for a given area across the Western United States.</p>
              <br>
              <p style='color:red; text-align:center'> DISCLAIMER: This tool is under construction, not for public use, and has not yet been fully approved by our member states.</p>
              <p style='color:red; text-aglgn:center'><b> WARNING: Individual states use separate methods to estimate water use.  As a result, water use data comparison across states lines is not necessarily exact.  Before drawing any conclusions or making comparison, consult the state's utilized method on water data creation. </b></p>
            </div>
          </body>
        </html>
        ")
      )
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
                 
                 # checkboxGroupInput(inputId="StateLines", label="State Lines", choices=TRUE),
                 
                 selectInput(inputId="MapDeckBGInput",label="Background Layer", 
                             choices=MapDeckStyleList, selected="dark"),
                 
                 
                 pickerInput(inputId='LegendTypeInput', label='Legend Type Color', 
                             choices=LegendTypeList, selected='Beneficial Use', 
                             multiple = FALSE),
                 
                 
                 helpText("-------------", align = "center"),
                 pickerInput(inputId='SiteTypeInput', label='Site Type', 
                             choices=SiteTypeList, selected=SiteTypeList,
                             multiple = TRUE),
                 pickerInput(inputId='WaterSourceTypeInput', label='Water Source Type', 
                             choices=WaterSourceTypeList, selected=WaterSourceTypeList,
                             multiple = TRUE),
                 pickerInput(inputId='AllocationOwnerInput', label='Allocation Owner', 
                             choices=AllocationOwnerList, selected=AllocationOwnerList,
                             multiple = TRUE),
                 
                 
                 helpText("-------------", align = "center"),
                 sliderInput("DateInput", "Priority Date (yyyy-mm-dd)",
                             min = as.Date("1850-01-01","%Y-%m-%d"),
                             max = as.Date("2020-06-24","%Y-%m-%d"),
                             value = c(as.Date("1850-01-01","%Y-%m-%d"), as.Date("2020-06-24","%Y-%m-%d")),
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
                 materialSwitch(inputId = "Null_CFS", label = "Include Empty Values (Null)?", 
                                value = TRUE, status = "primary"),
                 numericInput(inputId = "minAA_CFS", label = "Minimum CFS", value = 0,
                              min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
                 numericInput(inputId = "maxAA_CFS", label = "Maximum CFS", value = max(P_AlloLFSite$AA_CFS),
                              min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
                 helpText("-------------", align = "center"),
                 helpText("Allocation Volume", align = "center"),
                 materialSwitch(inputId = "Null_AF", label = "Include Empty Values (Null)?", 
                                value = TRUE, status = "primary"),
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
                            withSpinner(mapdeckOutput(outputId = "mapAll", height = 800))
                   ), #endtabPanel
                   
                   #Basins Sites Map
                   tabPanel(title = "River Basins",
                            withSpinner(mapdeckOutput(outputId = "mapBasins", height = 800))
                   ) #endtabPanel
                 ) # endtabsetPanel
             ),
             
             fluidRow(
               HTML("
                 <h3 style='text-align:center'; class='parallax'> 
                 <br>
                 <b>
                 WaDE Data Tables (click desired site on map)
                 </b>
                 </h3>
               ")),
             
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