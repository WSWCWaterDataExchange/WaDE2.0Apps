# App: MapAggPoly_ver2a

################################################################################################
################################################################################################
# Sec 2. The UI (HTML Page)

ui <- dashboardPage(
  skin = "black",
  
  dashboardHeader(
    title = titleWSWC,
    titleWidth = 400
  ), #enddashboardHeader
  
  dashboardSidebar(
    width = 150,
    tags$head(tags$style(HTML(".sidebar { height: 90vh; overflow-y: auto; }" )) # Adds scrollbar to Sidebar.
    ),
    helpText("----------------------------", align = "center"),
    helpText("Filter Data.", align = "center"),
    selectInput(inputId = 'ReportYearInput', label = 'Report Year', 
                choices = AllReportYearList, selected = 2005)
  ), #enddashboardSidebar
  
  dashboardBody(
    tabsetPanel(
      
      id = "tab_being_displayed", # will set input$tab_being_displayed
      
      ##CountyMap
      # tabPanel(title = "County",
      #          fluidRow(
      #            column(
      #              width=12, 
      #              leafletOutput(
      #                outputId="CountyMap", height=400
      #              )
      #            )
      #          ),
      #          fluidRow(
      #            column(
      #              width=12, 
      #              box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "primary",
      #                  plotlyOutput(outputId="LP_County_A", height=300)),
      #              box(title = "VariableType", width = 6, solidHeader = TRUE, status = "primary",
      #                  plotlyOutput(outputId="LP_County_B", height=300))
      #            )
      #          )
      # ),
      tabPanel(title = "County",
               fluidRow(
                 column(
                   width = 12, leafletOutput(outputId="CountyMap"))),
               fluidRow(
                 column(
                   width = 12, 
                   box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "primary",
                       plotlyOutput(outputId = "LP_County_A")),
                   box(title = "VariableType", width = 6, solidHeader = TRUE, status = "primary",
                       plotlyOutput(outputId = "LP_County_B"))))),
               
               ##HUC8Map
               tabPanel(title = "HUC8",
                        fluidRow(
                          leafletOutput(outputId = "HUC8Map", height = 400)
                        ),
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
                          leafletOutput(outputId = "CustomMap", height = 400)
                        ),
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
                          leafletOutput(outputId = "USBR_UCRB_TributaryMap", height=400)
                        ),
                        fluidRow(
                          box(title = "WaterSourceType", width = 6, solidHeader = TRUE, status = "primary",
                              plotlyOutput(outputId="LP_USBR_UCRB_Tributary_A", height = 300)),
                          box(title = "VariableType", width = 6, solidHeader = TRUE, status = "primary",
                              plotlyOutput(outputId="LP_USBR_UCRB_Tributary_B", height = 300))
                        )
               )
               
      ) #endtabsetPanel
    ) #enddashboardBody
    
  ) #end dashboardPage