################################################################################################
################################################################################################
# Sec 2. The UI (HTML Page)

ui <- dashboardPage(
  
  dashboardHeader(
    title ="Western States Allocation Site Information"
  ), #enddashboardHeader
  
  dashboardSidebar(
    # helpText("Click button to refresh ouput.", align = "center"),
    # submitButton("Update View", icon("refresh")),
    # helpText("---------------------------------------------------"),
    helpText("Search for Location.", align = "center"),
    sidebarSearchForm(textId = "searchText", buttonId = "searchButton", label = "Search..."),
    helpText("---------------------------------------------------"),
    helpText("Filter Data.", align = "center"),
    sliderInput("DateInput", "Priority Date (yyyy-mm-dd)",
                min = as.Date("1845-01-01","%Y-%m-%d"),
                max = as.Date("2018-06-21","%Y-%m-%d"),
                value = c(as.Date("1845-01-011","%Y-%m-%d"), as.Date("2018-06-21","%Y-%m-%d")),
                timeFormat="%Y-%m-%d"),
    selectInput("StateInput", "Select State Box", choices = StateList, multiple = TRUE, selected = "Select All"),
    selectInput("BenUseInput", "Select Benificial Use Box", choices = BenUseList, multiple = TRUE, selected = "Select All"),
    helpText("---------------------------------------------------"),
    helpText("Click on the download button to download selected data to csv.", align = "center"),
    downloadButton('download',"Download the data to csv")
  ), #enddashboardSidebar
  
  dashboardBody(
    tabsetPanel(
      tabPanel("Map", 
               fluidRow(withSpinner(leafletOutput("mapA"))),
               fluidRow(
                 box(withSpinner(plotOutput("barplotA"))),
                 box(withSpinner(plotOutput("barplotB")))
               )
      ),
      tabPanel("Table", withSpinner(DT::dataTableOutput("mytable"))) #used with DT library
    ) #endtabsetPanel
  ) #enddashboardBody
  
) #end dashboardPage