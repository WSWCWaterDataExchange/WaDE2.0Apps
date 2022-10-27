# App: SSRG Demo

################################################################################################
################################################################################################
# Sec 2. The UI (HTML Page)

ui <- dashboardPage(
  
  dashboardHeader(
    title = "WSWC Dashboard"
  ), #end dashboardHeader
  
  
  dashboardSidebar(
    HTML("<h3 style='text-align:center'; class='parallax'>Instructions</h3>
         <p style='text-align:left'; class='parallax_description'>Use filters to narrow down selection if desired.</p>"),
    hr(),
    materialSwitch(inputId="NoRecordInput", label="Hide No Record (Grey) Sites?", value=FALSE, status="warning"),
    pickerInput(inputId='StateInput', label='Select State', choices=StateList, selected=StateList, multiple=TRUE),
    pickerInput(inputId="WaterSourceTypeInput", label="Select Water Source Type", choices=WaterSourceTypeList, selected=WaterSourceTypeList, multiple=TRUE)
  ), # end dashboardSidebar
  
  dashboardBody(
    # Header Box
    fluidRow(
      box(
        width=NULL, status="primary",
        HTML(
          "
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
              <h1 style='text-align:center'; class='parallax'><strong>DEMO:</strong> WestDAAT Site-Specific <span style=color:green><b>Reservoir and Gage</b></span> Time Series Data</h1>
              <p style='text-align:center'; class='parallax_description'>A web tool used to visualize and query historic water data for reservoir and gage data across the Western United States.</p>
              <p style='color:red; text-align:center'; class='parallax_description'>DISCLAIMER: This tool is under construction, not for public use, and has not yet been fully approved by our member states.</p>
            </div>
          </body>
        </html>
        "
        ) #end HTML
      ) #end box
    ), #end fluidRow
    
    ## Output: Leaflet Map "mapA"
    fluidRow(
      box(
        width=NULL, status="primary",
        shinycssloaders::withSpinner(leafletOutput(outputId="mapA", height=600))
      ) #end box
    ) #end fluidRow
    
  ) #end dashboardBody
) #end dashboardPage