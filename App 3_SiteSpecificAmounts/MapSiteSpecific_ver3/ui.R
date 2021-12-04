# App: App 3_SiteSpecificAmounts_v3

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
      box(width=8, status="warning",
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
              <h1 style='text-align:center'; class='parallax'> WestDAAT Site Specific Amounts Map </h1>
              <p style='text-align:center'; class='parallax_description'>A web tool used to summarize gauge data for a given area across the Western United States.</p>
              <p style='color:red; text-align:center'; class='parallax_description'>DISCLAIMER: This tool is under construction, not for public use, and has not yet been fully approved by our member states.</p>
            </div>
          </body>
        </html>
        ")
      ), 
      
      ## Input & Instructions
      box(width = 4, status="warning",
          #Title
          HTML("<h3 style='text-align:center'; class='parallax'> Instructions </h3>
               <p style='text-align:left'; class='parallax_description'> Use filters if necessary. Click on desired site marker for more info.</p>"),
          hr(),
          materialSwitch(inputId = "NoRecordInput", label = "Hide No Record Sites?", value = FALSE, status = "warning"),
          pickerInput(inputId='StateInput', label='Select State', choices=StateList, selected=StateList, multiple=TRUE),
          pickerInput(inputId="WaterSourceTypeInput", label="Select Water Source Type", choices=WaterSourceTypeList, selected=WaterSourceTypeList, multiple=TRUE)
      )
    ), #endfluidRow
    
    
    ## Output Map
    fluidRow(
      box(width = NULL, status="warning",
          tabsetPanel(
            id = "tab_being_displayed", # will set input$tab_being_displayed
            tabPanel(title = "Site Specific", leafletOutput(outputId="mapA", height=600)
            ) #end tabPanel
          ) #end tabsetPanel
      ) #end box
    ), #end fluidRow
    
    
    ## Output Plots A-B
    fluidRow(
      HTML("
        <h4 style='text-align:center'; class='parallax'> 
        <br>
        Amounts Plots (click desired site on map)
        </h4>
      "),
      tabBox(title = "Site Water Use by Beneficial Use", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_A")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_A"))),
      tabBox(title = "DCII Community Water Supply System Water Use by Site Use", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_B")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_B")))
    ), #end fluidRow
    
    ## Output Plots C-D
    fluidRow(
      tabBox(title = "Site Water Use by Variable Specific Type", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_C")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_C"))),
      tabBox(title = "DCII Community Water Supply System Water Use by SiteUUID", width = 6, side='right', selected = "Line Plot",
             tabPanel("Line Plot",  plotlyOutput(outputId = "LP_D")),
             tabPanel("Pie Chart", plotlyOutput(outputId = "PC_D")))
    ), #end fluidRow
    
    
    ## API Tables
    fluidRow(
    ) #end fluidRow
    
  ) #end dashboardBody
) #end dashboardPage