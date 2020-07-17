# App: AggDataApp_ver2

################################################################################################
################################################################################################
# Sec 2. The UI (HTML Page)

ui <- dashboardPage(
  
  dashboardHeader(
    title = "Western States Aggreated Polygon Information",
    titleWidth = 450
  ), #enddashboardHeader
  
  dashboardSidebar(
    tags$head(tags$style(HTML(".sidebar { height: 90vh; overflow-y: auto; }" )) # Adds scrollbar to Sidebar.
    ),
    helpText("-----------------------------------------------", align = "center"),
    helpText("Filter Data.", align = "center"),
    selectInput(inputId='ReportYearInput', label="Reprt year", choices=ReportYearList, selected ="2005", multiple = FALSE)
  ), #enddashboardSidebar
  
  dashboardBody(
    tabsetPanel(
      
      id = "tab_being_displayed", # will set input$tab_being_displayed
      
      ##CountyMap
      tabPanel(title = "County Polygon Map",
               fluidRow(withSpinner(leafletOutput(outputId="CountyMap", height=800)))
      ),
      
      ##HUC8Map
      tabPanel(title = "HUC8 Polygon Map",
               fluidRow(withSpinner(leafletOutput(outputId="HUC8Map", height=800)))
      )
    ) #endtabsetPanel
  ) #enddashboardBody
  
) #end dashboardPage