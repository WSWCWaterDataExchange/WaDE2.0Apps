# App: MapPODSite_ver2

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
    tags$head(tags$style(HTML(".sidebar { height: 90vh; overflow-y: auto; }" ))), # Adds scrollbar to Sidebar.
    
    fluidRow(
      column(width = 2,
             box(width = NULL, status="primary",
                 HTML("
                   <h3 style='text-align:center'; class='parallax'> WSWC POD Water Allocation Map </h3>
                   <p style='text-align:center'; class='parallax_description'>A wep tool used to located point of diversions sites for water rights across the Western United States.</p>
                 ")
             ),
             box(width = NULL, status="primary", title = "Inputs",
                 actionButton(inputId="reset_input", label="Reset inputs"),
                 sliderInput("DateInput", "Priority Date (yyyy-mm-dd)",
                             min = as.Date("1850-01-01","%Y-%m-%d"),
                             max = as.Date("2016-09-09","%Y-%m-%d"),
                             value = c(as.Date("1850-01-01","%Y-%m-%d"), as.Date("2016-09-09","%Y-%m-%d")),
                             timeFormat="%Y-%m-%d"),
                 checkboxGroupInput(inputId = "StateInput", label = "Select State", choices = StateList, selected = StateList),
                 checkboxGroupInput(inputId = "BenUseInput", label = "Select Primary Benificial Use", choices = BenUseList, selected = BenUseList),
                 helpText("-----------------------------------------------", align = "center"),
                 helpText("Allocation Flow", align = "center"),
                 numericInput(inputId = "minAA_CFS", label = "Minimum CFS", value = 0,
                              min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
                 numericInput(inputId = "maxAA_CFS", label = "Maximum CFS", value = max(P_AlloLFSite$AA_CFS),
                              min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
                 helpText("-----------------------------------------------", align = "center"),
                 helpText("Allocation Volume", align = "center"),
                 numericInput(inputId = "minAA_AF", label = "Minimum AF", value = 0,
                              min = 0, max = max(P_AlloLFSite$AA_AF), step = NA, width = NULL),
                 numericInput(inputId = "maxAA_AF", label = "Maximum AF", value = max(P_AlloLFSite$AA_AF),
                              min = 0, max = max(P_AlloLFSite$AA_AF), step = NA, width = NULL)
             )
      ),
      column(width = 10,
             box(width = NULL, status="primary",
                 tabsetPanel(
                   id = "tab_being_displayed", # will set input$tab_being_displayed
                   
                   
                   ### CRB Sites Map ###
                   tabPanel(title = "CRB",
                            withSpinner(mapdeckOutput(outputId = "mapCRB", height = 600))
                   ), #endtabPanel
                   
                   
                   ### All Sites Map ###
                   tabPanel(title = "All Sites",
                            withSpinner(mapdeckOutput(outputId = "mapAll", height = 600))
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
               h3(strong("WaterSources"), align = "center"),
               div(style = 'overflow-x: scroll', DT::dataTableOutput('VariableSpecifics'))
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
  ) #enddashboardBody
) #end dashboardPage







#Old code to hold onto temproary

# # App: MapPODSite_ver2
# 
# ################################################################################################
# ################################################################################################
# # Sec 2. The UI (HTML Page)
# 
# ui <- dashboardPage(
#   skin = "black",
#   
#   # dashboardHeader(
#   #   title =titleWSWC,
#   #   titleWidth = 500
#   # ), #enddashboardHeader
#   
#   dashboardHeader(
#     disable = TRUE
#   ),
#   
#   dashboardSidebar(
#     
#     tags$head(tags$style(HTML(".sidebar { height: 90vh; overflow-y: auto; }" ))), # Adds scrollbar to Sidebar.
#     
#     actionButton(inputId="reset_input", label="Reset inputs"),
#     helpText("-----------------------------------------------", align = "center"),
#     helpText("Filter Data.", align = "center"),
#     sliderInput("DateInput", "Priority Date (yyyy-mm-dd)",
#                 min = as.Date("1850-01-01","%Y-%m-%d"),
#                 max = as.Date("2016-09-09","%Y-%m-%d"),
#                 value = c(as.Date("1850-01-01","%Y-%m-%d"), as.Date("2016-09-09","%Y-%m-%d")),
#                 timeFormat="%Y-%m-%d"),
#     checkboxGroupInput(inputId = "StateInput", label = "Select State", choices = StateList, selected = StateList),
#     checkboxGroupInput(inputId = "BenUseInput", label = "Select Primary Benificial Use", choices = BenUseList, selected = BenUseList),
#     helpText("-----------------------------------------------", align = "center"),
#     helpText("Allocation Flow", align = "center"),
#     numericInput(inputId = "minAA_CFS", label = "Minimum CFS", value = 0,
#                  min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
#     numericInput(inputId = "maxAA_CFS", label = "Maximum CFS", value = max(P_AlloLFSite$AA_CFS),
#                  min = 0, max = max(P_AlloLFSite$AA_CFS), step = NA, width = NULL),
#     helpText("-----------------------------------------------", align = "center"),
#     helpText("Allocation Volume", align = "center"),
#     numericInput(inputId = "minAA_AF", label = "Minimum AF", value = 0,
#                  min = 0, max = max(P_AlloLFSite$AA_AF), step = NA, width = NULL),
#     numericInput(inputId = "maxAA_AF", label = "Maximum AF", value = max(P_AlloLFSite$AA_AF),
#                  min = 0, max = max(P_AlloLFSite$AA_AF), step = NA, width = NULL)
#   ), #enddashboardSidebar
#   
#   dashboardBody(
#     
#     fluidRow(
#       HTML("
#         <div class='col-md-3'>
#           <img src='wswclogo.jpg' alt='https://www.westernstateswater.org/' width='90' height='120'>
#         </div>
#         <div class='col-md-7'>
#           <h1 style='text-align:center'; class='parallax'> WSWC POD Water Allocation Map </h1>
#           <p style='text-align:center'; class='parallax_description'>A wep tool used to located point of diversions sites for water rights across the Western United States.</p>
#         </div>
#         ")
#     ),
#     
#     fluidRow(
#       tabsetPanel(
#         id = "tab_being_displayed", # will set input$tab_being_displayed
#         
#         
#         ### CRB Sites Map ###
#         tabPanel(title = "CRB",
#                  fluidRow(withSpinner(mapdeckOutput(outputId = "mapCRB", height = 600)))
#         ), #endtabPanel
#         
#         
#         ### All Sites Map ###
#         tabPanel(title = "All Sites",
#                  fluidRow(withSpinner(mapdeckOutput(outputId = "mapAll", height = 600)))
#         ) #endtabPanel
#         
# 
#         
#       ) # endtabsetPanel
#     ), # endfluidRow
#     
#     ### Click Return Table ###
#     fluidRow( DT::dataTableOutput("mytable") )
#     
#   ) #enddashboardBody
#   
# ) #end dashboardPage
