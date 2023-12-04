# Define UI

ui <- dashboardPage(
  title = "Regulatory Overlay Area Dashboard Demo",
  dashboardHeader(
    title = "Regulatory Overlay Area"
  ), #end dashboardHeader
  
  dashboardSidebar(
    HTML("<h3 style='text-align:center'; class='parallax'>Instructions</h3>
         <p style='text-align:left'; class='parallax_description'>Use filters to narrow down selection if desired.</p>"),
    hr(),
    selectInput(inputId = "states", label = "Select State", choices = State, multiple = TRUE, selected = State),
    selectInput(inputId = "ws", label = "Select Water Source Type", choices = WaterSource, multiple = TRUE),
    selectInput(inputId = "overlay", label = 'Select Overlay', choices = Overlay, multiple = TRUE),
    selectInput(inputId = "AoR", label = "Select Administrative or Regulatory", choices = Type, multiple = TRUE),
    actionButton(inputId = "button", label = "Apply Changes", width='90%')
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
              <h1 style='text-align:center'; class='parallax'><strong>DEMO:</strong> WaDE <span style=color:Indigo><b>Regulatory Overlay Area</b></span> Data</h1>
              <p style='text-align:center'; class='parallax_description'>A web tool used to visualize and query historic water data in a recognized area.</p>
              <p style='color:red; text-align:center'; class='parallax_description'>DISCLAIMER: This tool is under construction, not for public use, and has not yet been fully approved by our member states.</p>
            </div>
          </body>
        </html>
        "
        ) #end HTML
      ) #end box
    ), #end fluidRow
    
    
    fluidRow(
      box(
        width=NULL, status="primary",
        shinycssloaders::withSpinner(leafletOutput(outputId="map", height=600))
      ) #end box
    ) #end fluidRow
  ) #end dashboardBody
)#end dashboardPage