# Define Server

server <- function(input, output, session) {
  # Create reactive data
  reactive_data <- reactive({raw_data})
  
  # Create interaction between selectInputs
  observe(
    
    updateSelectInput(inputId = 'overlay', label = 'Select Overlay', 
                      choices = reactive_data() %>%
                        filter(StateCV %in% input$states)%>%
                        pull(Regulato_4) %>% unique()
    ) # end updateSelectInput 
  ) # end observe
  
  # Create base map with all polygons loaded
  output$map <- renderLeaflet({
    
    leaflet()%>%
      addProviderTiles(providers$OpenStreetMap) %>%
      setView(lng = -105.0, lat = 37.0, zoom = 5) %>%
      addPolygons(
        data = reactive_data(),
        weight = 1,
        popup = paste(
          "<b>WaDE Area ID:</b>", reactive_data()$ReportingU, "<br>",
          "<b>Area Name:</b>", reactive_data()$Reportin_1, "<br>",
          "<b>WaDE Overlay Type:</b>", reactive_data()$Regulato_4, "<br>",
          "<b>WaDE Regulatory Type:</b>", reactive_data()$WaDENameRO, "<br>",
          "<b>WaDE Water Source Type:</b>", reactive_data()$WaDENameWS, "<br>",
          "<b>Oversight Agency:</b>", reactive_data()$OversightA, "<br>",
          "<b>Regulatory Direct Info", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/Rshiny_RO_LandingPage/?SQPInput=', reactive_data()$ReportingU, '", target=\"_blank\"> Link </a>')
        ))
  })# end map
  
  observeEvent(input$button, {
    try({
      rdt <- reactive_data()
      rdt <- rdt %>% subset(StateCV %in% input$states)
      rdt <- rdt %>% subset(WaDENameWS %in% input$ws)
      rdt <- rdt %>% subset(Reportin_3 %in% input$overlay)
      rdt <- rdt %>% subset(WaDENameRO %in% input$AoR)
      #RORODataTable$polylabel <- paste(RORODataTable$State, " : ", RORODataTable$WaDENameRU, " : ", RORODataTable$ReportingUnitName)
      
      leafletProxy('map') %>%
        clearShapes() %>%
        addPolygons(
          data = rdt,
          weight = 1,
          popup = paste(
            "<b>WaDE Area ID:</b>", rdt$ReportingU, "<br>",
            "<b>Area Name:</b>", rdt$Reportin_1, "<br>",
            "<b>WaDE Overlay Type:</b>", rdt$Regulato_4, "<br>",
            "<b>WaDE Regulatory Type:</b>", rdt$WaDENameRO, "<br>",
            "<b>WaDE Water Source Type:</b>", rdt$WaDENameWS, "<br>",
            "<b>Oversight Agency:</b>", rdt$OversightA, "<br>",
          "<b>Regulatory Direct Info", paste0('<a href="https://waterdataexchangewswc.shinyapps.io/Rshiny_RO_LandingPage/?SQPInput=', rdt$ReportingU, '", target=\"_blank\"> Link </a>')
          ))
    })# end try
  })# end observe
  
} # end server