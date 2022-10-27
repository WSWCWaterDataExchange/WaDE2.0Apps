# App: MapAggPoly_ver1

################################################################################################
################################################################################################
# Sec 2. The UI (HTML Page)

ui <- dashboardPage(
  skin = "black",
  
  dashboardHeader(
    title =titleWSWC,
    titleWidth = 400
  ), #enddashboardHeader
  
  dashboardSidebar(
    tags$head(tags$style(HTML(".sidebar { height: 90vh; overflow-y: auto; }" )) # Adds scrollbar to Sidebar.
    ),
    helpText("-----------------------------------------------", align = "center"),
    helpText("Filter Data.", align = "center"),
    sliderInput(inputId = 'ReportYearInput', label = 'Report Year', min = min(ReportYearList), max = max(ReportYearList), value="2008", step = NULL,
                round = FALSE, format = NULL, locale = NULL, ticks = TRUE,
                animate = FALSE, width = NULL, sep = ",", pre = NULL,
                post = NULL, timeFormat = NULL, timezone = NULL,
                dragRange = TRUE)
  ), #enddashboardSidebar
  
  dashboardBody(
    tabsetPanel(
      
      id = "tab_being_displayed", # will set input$tab_being_displayed
      
      ##CountyMap
      tabPanel(title = "County Reporting Unit",
               fluidRow((leafletOutput(outputId = "CountyMap", height = 500))),
               fluidRow(
                 box((plotlyOutput("linePlotCountyA"))),
                 box((plotlyOutput("linePlotCountyB")))
               )
      ),
      
      ##HUC8Map
      tabPanel(title = "HUC8 Reporting Unit",
               fluidRow(withSpinner(leafletOutput(outputId = "HUC8Map", height = 500))),
               fluidRow(
                 box((plotlyOutput("linePlotHUC8A"))),
                 box((plotlyOutput("linePlotHUC8B")))
               )
      ),
      
      ##BasinMap
      tabPanel(title = "Basin Reporting Unit",
               fluidRow(withSpinner(leafletOutput(outputId = "BasinMap", height = 500))),
               fluidRow(
                 box((plotlyOutput("linePlotBasinA"))),
                 box((plotlyOutput("linePlotBasinB")))
               )
      )
    ) #endtabsetPanel
  ) #enddashboardBody
  
) #end dashboardPage