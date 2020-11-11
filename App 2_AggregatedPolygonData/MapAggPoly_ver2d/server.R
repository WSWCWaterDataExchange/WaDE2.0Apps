# App: App2_Aggregated_v2d
#Notes:
# 1) Map Logic: Site -> AggAmountTable -> BenUseTable

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Custom Functions ########
  
  #N/A
  
  ####### Custom Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Standalone Observe Functions ########
  
  
  #Reset Button - resest all inputs to starting values
  observeEvent(input$reset_input, {
    updatePickerInput(session, "StateInput", selected = StateList)
    updatePickerInput(session, "BenUseInput", selected = BenUseList)
  })
  
  
  #Change Report Year Slider to Default Value depending on tab
  observe({
    
    #County
    if (input$tab_being_displayed == "County") {
      ruLabel = 'County Report Year'
      VariableCV = "Consumptive Use"
      Year = 2008
      YearList = c(1990, 1996, 2000, 2001, 2002, 2003,
                   2004, 2005, 2006, 2007, 2008, 2009,
                   2010, 2011, 2012, 2013, 2014, 2015, 2016)
    }
    
    #HUC8
    else if(input$tab_being_displayed == "HUC8") {
      ruLabel = 'HUC8 Report Year'
      VariableCV = "Consumptive Use"
      Year = 2012
      YearList = c(2005, 2006, 2007, 2008, 2009,
                   2010, 2011, 2012, 2013, 2014,
                   2015, 2016, 2017, 2018, 2019, 2020)
    }
    
    #Custom
    else if (input$tab_being_displayed == "Custom") {
      ruLabel = 'Custom Report Year'
      VariableCV = "Consumptive Use"
      Year = 2012
      YearList= c(1985,
                  1986, 1987, 1988, 1989, 1990, 1991,
                  1992, 1993, 1994, 1995, 1996, 1997,
                  1998, 1999, 2000, 2001, 2002, 2003,
                  2004, 2005, 2006, 2007, 2008, 2009,
                  2010, 2011, 2012, 2013, 2014, 2015,
                  2016, 2017, 2018)
    }
    
    #DAUCO
    else if (input$tab_being_displayed == "Detailed Analysis Units by County") {
      ruLabel = 'Custom Report Year'
      VariableCV = "Consumptive Use"
      Year = 2011
      YearList= c(2011, 2012, 2013, 2014, 2015)
    }
    
    #HydrologicRegionSF
    else if (input$tab_being_displayed == "Hydrologic Region") {
      ruLabel = 'Hydrologic Region Report Year'
      VariableCV = "Consumptive Use"
      Year = 2012
      YearList= c(1985,
                  1986, 1987, 1988, 1989, 1990, 1991,
                  1992, 1993, 1994, 1995, 1996, 1997,
                  1998, 1999, 2000, 2001, 2002, 2003,
                  2004, 2005, 2006, 2007, 2008, 2009,
                  2010, 2011, 2012, 2013, 2014, 2015,
                  2016, 2017, 2018)
    }
    
    #USBR
    else if (input$tab_being_displayed == "USBR Upper Colorado River Basin Tributarys") {
      ruLabel = 'USBR Report Year'
      VariableCV = "Consumptive Use"
      Year = 2009
      YearList = c(1971,	1972,	1973,	1974,	1975,	1976,	1977,
                   1978,	1979,	1980,	1981,	1982,	1983,	1984,
                   1985,	1986,	1987,	1988,	1989,	1990,	1991,
                   1992,	1993,	1994,	1995,	1996,	1997,	1998,
                   1999,	2000,	2001,	2002,	2003,	2004,	2005,
                   2006,	2007,	2008,	2009,	2010,	2011,	2012,
                   2013,	2014,	2015,	2016,	2017,	2018)
    }
    
    #Default
    else {
      ruLabel = 'Report Year'
      VariableCV = input$VariableCVInput
      Year = input$ReportYearInput
      YearList = AllReportYearList
    }
    
    #Update the Input
    updateSelectInput(session, inputId = 'ReportYearInput', label = ruLabel,
                      choices = YearList, selected = Year)
    updateSelectInput(session, inputId = 'VariableCVInput', label = ruLabel,
                      choices = VariableCVList, selected = VariableCV)
  })
  
  
  ####### End Standalone Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  emptydataRec <- reactive({
    EmptyTable
  })
  
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Line Plots Based on Observe Functions ########
  
  observe({
    
    #county
    if (input$tab_being_displayed == "County") {
      clickVal <- input$CountyMap_shape_click$id
      tempCountySF <- CountySF %>% subset(ReportingUnitUUID %in% clickVal)
      tempPAggTable <- PAggTable %>% filter(
        (ReportingUnitUUID %in% tempCountySF$ReportingUnitUUID),
        (BeneficialUseCV %in% input$BenUseInput)
      )
    }
    
    #HUC8
    if (input$tab_being_displayed == "HUC8") {
      clickVal <- input$HUC8Map_shape_click$id
      tempHUCSF <- HUCSF %>% subset(ReportingUnitUUID %in% clickVal)
      tempPAggTable <- PAggTable %>% filter(
        (ReportingUnitUUID %in% tempHUCSF$ReportingUnitUUID),
        (BeneficialUseCV %in% input$BenUseInput)
      )
    }
    
    #Custom
    if (input$tab_being_displayed == "Custom") {
      clickVal <- input$CustomMap_shape_click$id
      tempCustomSF <- CustomSF %>% subset(ReportingUnitUUID %in% clickVal)
      tempPAggTable <- PAggTable %>% filter(
        (ReportingUnitUUID %in% tempCustomSF$ReportingUnitUUID),
        (BeneficialUseCV %in% input$BenUseInput)
      )
    }
    
    #DAUCO
    if (input$tab_being_displayed == "Detailed Analysis Units by County") {
      clickVal <- input$DAUCOMap_shape_click$id
      tempDAUCOSF <- DAUCOSF %>% subset(ReportingUnitUUID %in% clickVal)
      tempPAggTable <- PAggTable %>% filter(
        (ReportingUnitUUID %in% tempDAUCOSF$ReportingUnitUUID),
        (BeneficialUseCV %in% input$BenUseInput)
      )
    }
    
    #HydrologicRegion
    if (input$tab_being_displayed == "Hydrologic Region") {
      clickVal <- input$HydrologicRegionMap_shape_click$id
      tempHydrologicRegionSF <- HydrologicRegionSF %>% subset(ReportingUnitUUID %in% clickVal)
      tempPAggTable <- PAggTable %>% filter(
        (ReportingUnitUUID %in% tempHydrologicRegionSF$ReportingUnitUUID),
        (BeneficialUseCV %in% input$BenUseInput)
      )
    }
    
    #USBR_UCRB_Tributary
    if (input$tab_being_displayed == "USBR Upper Colorado River Basin Tributarys") {
      clickVal <- input$USBR_UCRB_TributaryMap_shape_click$id
      tempUSBR_UCRB_TributarySF <- USBR_UCRB_TributarySF %>% subset(ReportingUnitUUID %in% clickVal)
      tempPAggTable <- PAggTable %>% filter(
        (ReportingUnitUUID %in% tempUSBR_UCRB_TributarySF$ReportingUnitUUID),
        (BeneficialUseCV %in% input$BenUseInput)
      )
    }
    
    #Clear when Reset Button is Clicked
    if (input$reset_input == TRUE) {
      clickVal <- NULL
    }
    
    
    #Produce subset of data and Plot from info on clickVal on map event
    print(clickVal)
    if(is.null(clickVal) == TRUE) {
      
      output$LP_A <- renderPlotly({
        figLP_A <- plot_ly(emptydataRec(), type='scatter')
        figLP_A <- figLP_A %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figLP_A
      })
      
      output$LP_B <- renderPlotly({
        figLP_B <- plot_ly(emptydataRec(), type='scatter')
        figLP_B <- figLP_B %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figLP_B
      })
      
      output$LP_C <- renderPlotly({
        figLP_C <- plot_ly(emptydataRec(), type='scatter')
        figLP_C <- figLP_C %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figLP_C
      })
      
      output$LP_D <- renderPlotly({
        figLP_D <- plot_ly(emptydataRec(), type='scatter')
        figLP_D <- figLP_D %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figLP_D
      })
      
      output$PC_A <- renderPlotly({
        figPC_A <- plot_ly(emptydataRec(), type='pie')
        figPC_A <- figPC_A %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_A
      })
      
      output$PC_B <- renderPlotly({
        figPC_B <- plot_ly(emptydataRec(), type='pie')
        figPC_B <- figPC_B %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_B
      })
      
      output$PC_C <- renderPlotly({
        figPC_C <- plot_ly(emptydataRec(), type='pie')
        figPC_C <- figPC_C %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_C
      })
      
      output$PC_D <- renderPlotly({
        figPC_D <- plot_ly(emptydataRec(), type='pie')
        figPC_D <- figPC_D %>% layout(title = paste0("Please Make Selection"),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_D
      })
      
    } else {
      
      #Line Plot A: Amount v ReportYearCV by BeneficialUseCV
      output$LP_A <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & BeneficialUseCV
        finalAFF_Ben <- tempPAggTable %>% group_by(BeneficialUseCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figLP_A <- plot_ly(data=finalAFF_Ben, x=~ReportYearCV, y=~SumAmouts,
                           group=~BeneficialUseCV, color=~BeneficialUseCV,
                           type='scatter', mode='lines+markers')
        figLP_A <- figLP_A %>% layout(xaxis = list(title="Report Year"),
                                      yaxis = list(title="Annual Water Use (Acre-Feet)"),
                                      showlegend=TRUE)
        figLP_A
      })
      
      #Line Plot B: Amount v ReportYearCV by WaterSourceTypeCV
      output$LP_B <- renderPlotly({
        #Subset of data & group by ReportyearCV
        finalAFF_WS <- tempPAggTable %>% group_by(WaterSourceTypeCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figLP_B <- plot_ly(data=finalAFF_WS, x=~ReportYearCV, y=~SumAmouts,
                           group=~WaterSourceTypeCV, color=~WaterSourceTypeCV,
                           type='scatter', mode='lines+markers')
        figLP_B <- figLP_B %>% layout(xaxis = list(title="Report Year"),
                                      yaxis = list(title="Annual Water Use (Acre-Feet)"),
                                      showlegend=TRUE)
        figLP_B
      })
      
      #Line Plot C: Amount v ReportYearCV by VariableCV
      output$LP_C <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & VariableCV
        finalAFF_V <- tempPAggTable %>% group_by(VariableCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figLP_C <- plot_ly(data=finalAFF_V, x=~ReportYearCV, y=~SumAmouts,
                           group=~VariableCV, color=~VariableCV,
                           type='scatter', mode='lines+markers')
        figLP_C <- figLP_C %>% layout(xaxis = list(title="Report Year"),
                                      yaxis = list(title="Annual Water Use (Acre-Feet)"),
                                      showlegend=TRUE)
        figLP_C
      })
      
      #Line Plot D: Amount v ReportYearCV by VariableSpecificCV
      output$LP_D <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & VariableSpecificCV
        finalAFF_Vs <- tempPAggTable %>% group_by(VariableSpecificCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figLP_D <- plot_ly(data=finalAFF_Vs, x=~ReportYearCV, y=~SumAmouts,
                           group=~VariableSpecificCV, color=~VariableSpecificCV,
                           type='scatter', mode='lines+markers')
        figLP_D <- figLP_D %>% layout(xaxis = list(title="Report Year"),
                                      yaxis = list(title="Annual Water Use (Acre-Feet)"),
                                      showlegend=TRUE)
        figLP_D
      })
      
      
      #Pice Chart A: Amount v BeneficialUseCV Type
      output$PC_A <- renderPlotly({
        
        #Subset of data & group by ReportyearCV
        tempPAggTable2 <- tempPAggTable %>% filter(ReportYearCV %in% input$ReportYearInput)
        finalAFF_Ben <- tempPAggTable2 %>% group_by(BeneficialUseCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figPC_A <- plot_ly(data = finalAFF_Ben, type = 'pie', labels = ~BeneficialUseCV, values = ~SumAmouts, colors= ~BeneficialUseCV)
        figPC_A <- figPC_A %>% layout(title = paste0("Year: ", input$ReportYearInput),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_A
      })
      
      #Pice Chart B: Amount v Water Source Type
      output$PC_B <- renderPlotly({
        
        #Subset of data & group by ReportyearCV
        tempPAggTable2 <- tempPAggTable %>% filter(ReportYearCV %in% input$ReportYearInput)
        finalAFF_WS <- tempPAggTable2 %>% group_by(WaterSourceTypeCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figPC_B <- plot_ly(data = finalAFF_WS, type = 'pie', labels = ~WaterSourceTypeCV, values = ~SumAmouts,
                           group= ~WaterSourceTypeCV, colors =~WaterSourceTypeCV)
        figPC_B <- figPC_B %>% layout(title = paste0("Year: ", input$ReportYearInput),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_B
      })
      
      #Pice Chart C: Amount v Variable Type
      output$PC_C <- renderPlotly({
        
        #Subset of data & group by ReportyearCV
        tempPAggTable2 <- tempPAggTable %>% filter(ReportYearCV %in% input$ReportYearInput)
        finalAFF_VS <- tempPAggTable2 %>% group_by(VariableCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figPC_C <- plot_ly(data = finalAFF_VS, type = 'pie', labels = ~VariableCV, values = ~SumAmouts, colors= ~VariableCV)
        figPC_C <- figPC_C %>% layout(title = paste0("Year: ", input$ReportYearInput),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_C
      })
      
      #Pice Chart D: Amount v VariableSpecificCV Type
      output$PC_D <- renderPlotly({
        
        #Subset of data & group by ReportyearCV
        tempPAggTable2 <- tempPAggTable %>% filter(ReportYearCV %in% input$ReportYearInput)
        finalAFF_VS <- tempPAggTable2 %>% group_by(VariableSpecificCV, ReportYearCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        figPC_D <- plot_ly(data = finalAFF_VS, type = 'pie', labels = ~VariableSpecificCV, values = ~SumAmouts, colors= ~VariableSpecificCV)
        figPC_D <- figPC_D %>% layout(title = paste0("Year: ", input$ReportYearInput),
                                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        figPC_D
      })
      
    } #end else
  })
  
  ####### End Line Plots Based on Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ######## County Map ########
  
  #Base Map Creation
  output$CountyMap <- renderLeaflet({
    
    leaflet(
      options = leafletOptions(
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,  # map won't update tiles until zoom is done
          updateWhenIdle = TRUE)      # map won't load new tiles when panning
      ) %>%
      setView(lng = -107.50, lat = 34.00, zoom = 5)
  })
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "County")  # Helps solves issue of observe waiting for user input before implementing.
    
    #Filter P_AggAmountTable by Variable, Year, and State.
    data <- PAggTable %>%
      filter(
        ReportingUnitTypeCV == 'County',
        VariableCV %in% input$VariableCVInput,
        ReportYearCV %in% input$ReportYearInput,
        State %in% input$StateInput
      ) %>%
      # group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      group_by(ReportingUnitUUID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    # myNewCountySF <- merge(CountySF, data, by="ReportingUnitID")
    myNewCountySF <- merge(CountySF, data, by="ReportingUnitUUID")
    
    #Map & Legend Color Palette
    if (max(data$Amount) < 0) {
      minAmount <- 0
      maxAmount <- 0
    } else {
      minAmount <- min(data$Amount)
      maxAmount <- max(data$Amount)
    }
    pal <- colorNumeric(
      palette = "Blues",
      domain = c(minAmount, maxAmount),
      na.color = NA)
    
    #Create the Map
    leafletProxy(
      mapId = "CountyMap",
    ) %>%
      clearShapes() %>% #removes points
      clearControls() %>% #removes legend
      addProviderTiles(providers$Esri.DeLorme, group = "DeLorme") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "WorldStreetMap") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "WorldTopoMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "WorldImagery") %>%
      addPolygons(
        data = USStateLinesSF,
        layerId = ~STUSPS,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        group = "State Borders",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = CountySF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = myNewCountySF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.8,
        fillColor = ~pal(Amount),
        label = ~ReportingUnitName,
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "Type: ", ReportingUnitTypeCV, "<br>",
          "Area Name: ", ReportingUnitName, "<br>",
          "Area ID : ", ReportingUnitID, "<br>",
          "Amount : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Total Water (AF)",
                pal = pal,
                values = c(minAmount, maxAmount)
      ) %>%
      addLayersControl(
        baseGroups = c("DeLorme", "WorldStreetMap", "WorldTopoMap", "WorldImagery"),
        overlayGroups = c("State Borders"),
        options = layersControlOptions(collapsed = FALSE)
      )
  }) #endObserve
  
  
  ######## End County Map ########
  ##################################################################
  
  
  
  ##################################################################
  ######## HUC8 Map ########
  
  #Base Map Creation
  output$HUC8Map <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,
          updateWhenIdle = TRUE)
      ) %>%
      setView(lng = -111.40, lat = 39.50, zoom = 6)
  })
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "HUC8")
    
    #Filter P_AggAmountTable by Variable, Year, and State.
    data <- PAggTable %>%
      filter(
        ReportingUnitTypeCV == 'HUC8',
        VariableCV %in% input$VariableCVInput,
        ReportYearCV %in% input$ReportYearInput,
        State %in% input$StateInput
      ) %>%
      # group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      group_by(ReportingUnitUUID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    # myNewHUCSF <- merge(HUCSF, data, by="ReportingUnitID")
    myNewHUCSF <- merge(HUCSF, data, by="ReportingUnitUUID")
    
    #Map & Legend Color Palette
    if (max(data$Amount) < 0) {
      minAmount <- 0
      maxAmount <- 0
    } else {
      minAmount <- min(data$Amount)
      maxAmount <- max(data$Amount)
    }
    pal <- colorNumeric(
      palette = "Blues",
      domain = c(minAmount, maxAmount),
      na.color = NA)
    
    leafletProxy(
      mapId = "HUC8Map",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
      addProviderTiles(providers$Esri.DeLorme, group = "DeLorme") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "WorldStreetMap") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "WorldTopoMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "WorldImagery") %>%
      addPolygons(
        data = USStateLinesSF,
        layerId = ~STUSPS,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        group = "State Borders",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = HUCSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = myNewHUCSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444", 
        weight = 1, 
        smoothFactor = 0.5,
        opacity = 1.0, 
        fillOpacity = 0.8,
        fillColor = ~pal(Amount),
        label = ~ReportingUnitName,
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "Type: ", ReportingUnitTypeCV, "<br>",
          "Area Name: ", ReportingUnitName, "<br>",
          "Area ID : ", ReportingUnitID, "<br>",
          "Amount : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"
        ),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Total Water (AF)",
                pal = pal,
                values = c(minAmount, maxAmount)
      ) %>%
      addLayersControl(
        baseGroups = c("DeLorme", "WorldStreetMap", "WorldTopoMap", "WorldImagery"),
        overlayGroups = c("State Borders"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  ######## End HUC8 Map ########
  ##################################################################
  
  
  
  ##################################################################
  ######## Custom Map ########
  
  #Base Map Creation
  output$CustomMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,
          updateWhenIdle = TRUE)
      ) %>%
      setView(lng = -103.8080, lat = 36.6050, zoom = 4)
  })
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "Custom")
    
    #Filter P_AggAmountTable by Variable, Year, and State.
    data <- PAggTable %>%
      filter(
        ReportingUnitTypeCV == c('Subarea', 'Basin', 'Planning Area', 'Active Management Area'),
        VariableCV %in% input$VariableCVInput,
        ReportYearCV %in% input$ReportYearInput,
        State %in% input$StateInput
      ) %>%
      # group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      group_by(ReportingUnitUUID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    # myNewCustomSF<- merge(CustomSF, data, by="ReportingUnitID")
    myNewCustomSF<- merge(CustomSF, data, by="ReportingUnitUUID")
    
    #Map & Legend Color Palette
    if (max(data$Amount) < 0) {
      minAmount <- 0
      maxAmount <- 0
    } else {
      minAmount <- min(data$Amount)
      maxAmount <- max(data$Amount)
    }
    pal <- colorNumeric(
      palette = "Blues",
      domain = c(minAmount, maxAmount),
      na.color = NA)
    
    leafletProxy(
      mapId = "CustomMap",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
      addProviderTiles(providers$Esri.DeLorme, group = "DeLorme") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "WorldStreetMap") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "WorldTopoMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "WorldImagery") %>%
      addPolygons(
        data = USStateLinesSF,
        layerId = ~STUSPS,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        group = "State Borders",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = CustomSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = myNewCustomSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 1,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.8,
        fillColor = ~pal(Amount),
        label = ~ReportingUnitName,
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "Type: ", ReportingUnitTypeCV, "<br>",
          "Area Name: ", ReportingUnitName, "<br>",
          "Area ID : ", ReportingUnitID, "<br>",
          "Amount : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Total Water (AF)",
                pal = pal,
                values = c(minAmount, maxAmount)
      ) %>%
      addLayersControl(
        baseGroups = c("DeLorme", "WorldStreetMap", "WorldTopoMap", "WorldImagery"),
        overlayGroups = c("State Borders"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  ######## End Custom Map ########
  ##################################################################
  
  
  
  ##################################################################
  ######## DAUCO Map ########
  
  #Base Map Creation
  output$DAUCOMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,
          updateWhenIdle = TRUE)
      ) %>%
      setView(lng = -103.8080, lat = 36.6050, zoom = 4)
  })
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "Detailed Analysis Units by County")
    
    #Filter P_AggAmountTable by Variable, Year, and State.
    data <- PAggTable %>%
      filter(
        ReportingUnitTypeCV == 'Detailed Analysis Units by County',
        VariableCV %in% input$VariableCVInput,
        ReportYearCV %in% input$ReportYearInput,
        State %in% input$StateInput
      ) %>%
      group_by(ReportingUnitUUID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    myNewDAUCOSF <- merge(DAUCOSF, data, by="ReportingUnitUUID")
    
    #Map & Legend Color Palette
    if (max(data$Amount) < 0) {
      minAmount <- 0
      maxAmount <- 0
    } else {
      minAmount <- min(data$Amount)
      maxAmount <- max(data$Amount)
    }
    pal <- colorNumeric(
      palette = "Blues",
      domain = c(minAmount, maxAmount),
      na.color = NA)
    
    leafletProxy(
      mapId = "DAUCOMap",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
      addProviderTiles(providers$Esri.DeLorme, group = "DeLorme") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "WorldStreetMap") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "WorldTopoMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "WorldImagery") %>%
      addPolygons(
        data = USStateLinesSF,
        layerId = ~STUSPS,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        group = "State Borders",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = DAUCOSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = myNewDAUCOSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 1,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.8,
        fillColor = ~pal(Amount),
        label = ~ReportingUnitName,
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "Type: ", ReportingUnitTypeCV, "<br>",
          "Area Name: ", ReportingUnitName, "<br>",
          "Area ID : ", ReportingUnitID, "<br>",
          "Amount : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Total Water (AF)",
                pal = pal,
                values = c(minAmount, maxAmount)
      ) %>%
      addLayersControl(
        baseGroups = c("DeLorme", "WorldStreetMap", "WorldTopoMap", "WorldImagery"),
        overlayGroups = c("State Borders"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  ######## End DAUCO Map ########
  ##################################################################
  
  
  
  ##################################################################
  ######## Hydrologic Region Map ########
  
  #Base Map Creation
  output$HydrologicRegionMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,
          updateWhenIdle = TRUE)
      ) %>%
      setView(lng = -103.8080, lat = 36.6050, zoom = 4)
  })
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "Hydrologic Region")
    
    #Filter P_AggAmountTable by Variable, Year, and State.
    data <- PAggTable %>%
      filter(
        ReportingUnitTypeCV == 'Hydrologic Region',
        VariableCV %in% input$VariableCVInput,
        ReportYearCV %in% input$ReportYearInput,
        State %in% input$StateInput
      ) %>%
      # group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      group_by(ReportingUnitUUID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    # myNewHydrologicRegionSF <- merge(HydrologicRegionSF, data, by="ReportingUnitID")
    myNewHydrologicRegionSF <- merge(HydrologicRegionSF, data, by="ReportingUnitUUID")
    
    #Map & Legend Color Palette
    if (max(data$Amount) < 0) {
      minAmount <- 0
      maxAmount <- 0
    } else {
      minAmount <- min(data$Amount)
      maxAmount <- max(data$Amount)
    }
    pal <- colorNumeric(
      palette = "Blues",
      domain = c(minAmount, maxAmount),
      na.color = NA)
    
    leafletProxy(
      mapId = "HydrologicRegionMap",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
      addProviderTiles(providers$Esri.DeLorme, group = "DeLorme") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "WorldStreetMap") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "WorldTopoMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "WorldImagery") %>%
      addPolygons(
        data = USStateLinesSF,
        layerId = ~STUSPS,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        group = "State Borders",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = HydrologicRegionSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = myNewHydrologicRegionSF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 1,
        smoothFactor = 0.5,
        opacity = 1.0,
        fillOpacity = 0.8,
        fillColor = ~pal(Amount),
        label = ~ReportingUnitName,
        labelOptions = labelOptions(
          noHide = FALSE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "Type: ", ReportingUnitTypeCV, "<br>",
          "Area Name: ", ReportingUnitName, "<br>",
          "Area ID : ", ReportingUnitID, "<br>",
          "Amount : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Total Water (AF)",
                pal = pal,
                values = c(minAmount, maxAmount)
      ) %>%
      addLayersControl(
        baseGroups = c("DeLorme", "WorldStreetMap", "WorldTopoMap", "WorldImagery"),
        overlayGroups = c("State Borders"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  ######## End Hydrologic Region Map  ########
  ##################################################################
  
  
  
  ##################################################################
  ######## USBR_UCRB_Tributary Map ########
  
  #Base Map Creation
  output$USBR_UCRB_TributaryMap <- renderLeaflet({
    leaflet(
      options = leafletOptions(
        preferCanvas = TRUE)
    ) %>%
      addProviderTiles(
        providers$Esri.DeLorme,
        options = providerTileOptions(
          updateWhenZooming = FALSE,
          updateWhenIdle = TRUE)
      ) %>%
      setView(lng = -109.0816, lat = 39.5667, zoom = 6)
  })
  
  #Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "USBR Upper Colorado River Basin Tributarys")
    
    #Filter P_AggAmountTable by Variable and Year.
    data <- PAggTable %>%
      filter(
        ReportingUnitTypeCV == 'Tributary',
        VariableCV %in% input$VariableCVInput,
        ReportYearCV %in% input$ReportYearInput
      ) %>%
      # group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      group_by(ReportingUnitUUID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    # myNewUSBR_UCRB_TributarySF <- merge(USBR_UCRB_TributarySF, data, by="ReportingUnitID")
    myNewUSBR_UCRB_TributarySF <- merge(USBR_UCRB_TributarySF, data, by="ReportingUnitUUID")
    
    #Map & Legend Color Palette
    if (max(data$Amount) < 0) {
      minAmount <- 0
      maxAmount <- 0
    } else {
      minAmount <- min(data$Amount)
      maxAmount <- max(data$Amount)
    }
    pal <- colorNumeric(
      palette = "Blues",
      domain = c(minAmount, maxAmount),
      na.color = NA)
    
    leafletProxy(
      mapId = "USBR_UCRB_TributaryMap",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
      addProviderTiles(providers$Esri.DeLorme, group = "DeLorme") %>%
      addProviderTiles(providers$Esri.WorldStreetMap, group = "WorldStreetMap") %>%
      addProviderTiles(providers$Esri.WorldTopoMap, group = "WorldTopoMap") %>%
      addProviderTiles(providers$Esri.WorldImagery, group = "WorldImagery") %>%
      addPolygons(
        data = USStateLinesSF,
        layerId = ~STUSPS,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        group = "State Borders",
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = USBR_UCRB_TributarySF,
        layerId = ~ReportingUnitUUID,
        color = "#444444",
        weight = 3,
        opacity = 1.0,
        fillOpacity = 0,
        options = pathOptions(clickable = FALSE)
      ) %>%
      addPolygons(
        data = myNewUSBR_UCRB_TributarySF,
        layerId = ~ReportingUnitUUID,
        color = "#444444", 
        weight = 1, 
        smoothFactor = 0.5,
        opacity = 1.0, 
        fillOpacity = 0.8,
        fillColor = ~pal(Amount),
        label = ~ReportingUnitName,
        labelOptions = labelOptions(
          noHide = TRUE,
          textOnly = FALSE,
          textsize = "7px",
          opacity = 0.8,
          direction = 'top'),
        popup = ~paste(
          "State: ", StateCV, "<br>",
          "Type: ", ReportingUnitTypeCV, "<br>",
          "Area Name: ", ReportingUnitName, "<br>",
          "Area ID : ", ReportingUnitID, "<br>",
          "Amount : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Total Water (AF)",
                pal = pal,
                values = c(minAmount, maxAmount)
      ) %>%
      addLayersControl(
        baseGroups = c("DeLorme", "WorldStreetMap", "WorldTopoMap", "WorldImagery"),
        overlayGroups = c("State Borders"),
        options = layersControlOptions(collapsed = FALSE)
      )
  })
  
  ######## End USBR_UCRB_Tributary Map ########
  ##################################################################
  
  
  
  ############ ######################################################
  ######## Create API Tables ########
  
  observe({
    #county
    if (input$tab_being_displayed == "County") {
      clickVal <- input$CountyMap_shape_click$id
    }
    
    #HUC8
    if (input$tab_being_displayed == "HUC8") {
      clickVal <- input$HUC8Map_shape_click$id
    }
    
    #Custom
    if (input$tab_being_displayed == "Custom") {
      clickVal <- input$CustomMap_shape_click$id
    }
    
    #DAUCO
    if (input$tab_being_displayed == "Detailed Analysis Units by County") {
      clickVal <- input$DAUCOMap_shape_click$id
    }
    
    #HydrologicRegion
    if (input$tab_being_displayed == "Hydrologic Region") {
      clickVal <- input$HydrologicRegionMap_shape_click$id
    }
    
    #USBR_UCRB_Tributary
    if (input$tab_being_displayed == "USBR Upper Colorado River Basin Tributarys") {
      clickVal <- input$USBR_UCRB_TributaryMap_shape_click$id
    }
    
    #Clear when Reset Button is Clicked
    if (input$reset_input == TRUE) {
      clickVal <- NULL
    }
    
    #Creating string to pass to API call function based on clickVal$id value
    str1 <- "https://wade-api-qa.azure-api.net/v1/AggregatedAmounts?ReportingUnitUUID="
    str2 <- toString(clickVal)
    outstring <- paste0(str1,str2)
    
    
    #API Call Function
    #This returns empty / shows nothing if null
    filteredSiteAPICall <- eventReactive(clickVal, {
      if (is.null(clickVal)) {
        shiny::showNotification("No data", type = "error")
        NULL
      } else {
        val <- fromJSON(outstring)
      }
    })
    
    #Table OrganizationsTable
    output$OrganizationsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][1:7] , rownames = FALSE) %>% 
        formatStyle(
          columns=colnames(filteredSiteAPICall()[[2]][1:7]),
          background = 'white',
          color='black')
    })
    
    #Table WaterSourcesTable
    output$WaterSourcesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[8]][[1]], rownames = FALSE) %>% 
        formatStyle(
          columns=colnames(filteredSiteAPICall()[[2]][[8]][[1]]),
          background = 'white',
          color='black')
    })
    
    #Table VariableSpecificsTable
    output$VariableSpecificsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[10]][[1]],  rownames = FALSE) %>% 
        formatStyle(
          columns=colnames(filteredSiteAPICall()[[2]][[10]][[1]]),
          background = 'white',
          color='black')
    })
    
    #Table MethodsTable
    output$MethodsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[11]][[1]], rownames = FALSE) %>% 
        formatStyle(
          columns=colnames(filteredSiteAPICall()[[2]][[11]][[1]]),
          background = 'white',
          color='black')
    })
    
    #Table BeneficialUsesTable
    output$BeneficialUsesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[12]][[1]], rownames = FALSE) %>% 
        formatStyle(
          columns=colnames(filteredSiteAPICall()[[2]][[12]][[1]]),
          background = 'white',
          color='black')
    })
    
    #Table ReportingUnitsTable
    output$ReportingUnits <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[9]][[1]], rownames = FALSE) %>% 
        formatStyle(
          columns=colnames(filteredSiteAPICall()[[2]][[9]][[1]]),
          background = 'white',
          color='black')
    })
    
    #Table WaterAllocationsTable
    output$AggregatedAmountsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[13]][[1]], rownames = FALSE) %>% 
        formatStyle(
          columns=colnames(filteredSiteAPICall()[[2]][[13]][[1]]),
          background = 'white',
          color='black')
    })
    
  })
  
  ######## End Create API Tables ########
  ##################################################################
  
  
} #endServer