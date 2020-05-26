# App: MapPODSite_CRBver1

################################################################################################
################################################################################################
# Sec 2. The UI (HTML Page)

ui <- dashboardPage(
  skin = "black",
  
  dashboardHeader(
    title =titleWSWC,
    titleWidth = 500
  ), #enddashboardHeader
  
  dashboardSidebar(
    tags$head(tags$style(HTML(".sidebar { height: 90vh; overflow-y: auto; }" ))), # Adds scrollbar to Sidebar.
              
    helpText("-----------------------------------------------", align = "center"),
    helpText("Filter Data.", align = "center"),
    sliderInput("DateInput", "Priority Date (yyyy-mm-dd)",
                min = as.Date("1850-01-01","%Y-%m-%d"),
                max = as.Date("2016-09-09","%Y-%m-%d"),
                value = c(as.Date("1850-01-01","%Y-%m-%d"), as.Date("2016-09-09","%Y-%m-%d")),
                timeFormat="%Y-%m-%d"),
    textInput("SiteUUIDInput", "Text Input SiteUUID", value = ""),
    checkboxGroupInput(inputId = "StateInput", label = "Select State", choices = StateList, selected = StateList),
    checkboxGroupInput(inputId = "BenUseInput", label = "Select Benificial Use", choices = BenUseList, selected = BenUseList),
    helpText("-----------------------------------------------", align = "center"),
    helpText("Allocation Flow", align = "center"),
    numericInput(inputId = "minAA_CFS", label = "Minimum CFS", value = min(P_dfAllo$AA_CFS), min = min(P_dfAllo$AA_CFS), max = max(P_dfAllo$AA_CFS), step = NA, width = NULL),
    numericInput(inputId = "maxAA_CFS", label = "Maximum CFS", value = max(P_dfAllo$AA_CFS), min = min(P_dfAllo$AA_CFS), max = max(P_dfAllo$AA_CFS), step = NA, width = NULL),
    helpText("-----------------------------------------------", align = "center"),
    helpText("Allocation Volume", align = "center"),
    numericInput(inputId = "minAA_AF", label = "Minimum AF", value = min(P_dfAllo$AA_AF), min = min(P_dfAllo$AA_AF), max = max(P_dfAllo$AA_AF), step = NA, width = NULL),
    numericInput(inputId = "maxAA_AF", label = "Maximum AF", value = max(P_dfAllo$AA_AF), min = min(P_dfAllo$AA_AF), max = max(P_dfAllo$AA_AF), step = NA, width = NULL)
  ), #enddashboardSidebar
  
  dashboardBody(
    tabsetPanel(
      
      id = "tab_being_displayed", # will set input$tab_being_displayed
      
      ##MapA
      tabPanel("Point of Diversion Site Map",
               fluidRow(withSpinner(leafletOutput(outputId="mapA", height=650))),
               fluidRow(withSpinner(htmlOutput("textOutA")))
               ),
      
      ##Table
      tabPanel("Table", 
               withSpinner(DT::dataTableOutput("mytable")),
               downloadButton('download',"Download the data to csv")) #used with DT library
    ) #endtabsetPanel
  ) #enddashboardBody
  
) #end dashboardPage