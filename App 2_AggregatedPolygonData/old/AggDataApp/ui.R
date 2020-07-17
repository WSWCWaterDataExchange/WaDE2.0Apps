# App: AggDataApp

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
    checkboxGroupInput(inputId = "BenUseInput", label = "Select Benificial Use", choices = BenUseList, selected = BenUseList)
  ), #enddashboardSidebar
  
  dashboardBody(
    tabsetPanel(
      
      id = "tab_being_displayed", # will set input$tab_being_displayed
      
      ##CountyMap
      tabPanel(title = "County Polygon Map",
               fluidRow(withSpinner(leafletOutput(outputId="CountyMap", height=600)))
      ),
      
      ##HUC8Map
      tabPanel(title = "HUC8 Polygon Map",
               fluidRow(withSpinner(leafletOutput(outputId="HUC8Map", height=600)))
      ),

      
      ##Table
      tabPanel(title = "Table", 
               withSpinner(DT::dataTableOutput("mytable")),
               downloadButton('download',"Download the data to csv")) #used with DT library
    ) #endtabsetPanel
  ) #enddashboardBody
  
) #end dashboardPage