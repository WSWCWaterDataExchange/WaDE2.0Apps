# App: MapAggPoly_ver2c
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
  
  
  #Change Report Year Slider to Default Value depending on tab
  observe({
    
    #County
    if (input$tab_being_displayed == "County") {
      ruLabel = 'County Report Year'
      Year = 2008
      YearList = c(1990, 1996, 2000, 2001, 2002, 2003,
                   2004, 2005, 2006, 2007, 2008, 2009,
                   2010, 2011, 2012, 2013, 2014, 2015, 2016)
    }
    
    #HUC8
    else if(input$tab_being_displayed == "HUC8") {
      ruLabel = 'HUC8 Report Year'
      Year = 2009
      YearList = c(2005, 2006, 2007, 2008, 2009,
                   2010, 2011, 2012, 2013, 2014)
    }
    
    #Custom
    else if (input$tab_being_displayed == "Custom") {
      ruLabel = 'Custom Report Year'
      Year = 2012
      YearList= c(2000,2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008,
                  2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016)
    }
    
    #USBR
    else if (input$tab_being_displayed == "USBR Upper Colorado River Basin Tributarys") {
      ruLabel = 'USBR Report Year'
      Year = 2009
      YearList = AllReportYearList
    }
    
    #Default
    else {
      ruLabel = 'Report Year'
      Year = input$ReportYearInput
      YearList = AllReportYearList
    }
    
    #Update the Input
    updateSelectInput(session, inputId = 'ReportYearInput', label = ruLabel,
                      choices = YearList, selected = Year)
  })
  
  
  ####### End Standalone Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  #For Empty Plots before Mouse Selection
  emptydata <- reactive({NULL})
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Line Plots Based on Observe Functions ########
  
  observe({
    
    #county
    if (input$tab_being_displayed == "County") {
      click <- input$CountyMap_shape_click$id
      tempCountySF <- CountySF %>% subset(ReportingUnitUUID %in% click)
      tempAggAmountTable <- AggAmountTable %>% filter(ReportingUnitID %in% tempCountySF$ReportingUnitID)
    }
    
    #HUC8
    if (input$tab_being_displayed == "HUC8") {
      click <- input$HUC8Map_shape_click$id
      tempHUCSF <- HUCSF %>% subset(ReportingUnitUUID %in% click)
      tempAggAmountTable <- AggAmountTable %>% filter(ReportingUnitID %in% tempHUCSF$ReportingUnitID)
    }
    
    #Custom
    if (input$tab_being_displayed == "Custom") {
      click <- input$CustomMap_shape_click$id
      tempCustomSF <- CustomSF %>% subset(ReportingUnitUUID %in% click)
      tempAggAmountTable <- AggAmountTable %>% filter(ReportingUnitID %in% tempCustomSF$ReportingUnitID)
    }
    
    #USBR_UCRB_Tributary
    if (input$tab_being_displayed == "USBR Upper Colorado River Basin Tributarys") {
      click <- input$USBR_UCRB_TributaryMap_shape_click$id
      tempUSBR_UCRB_TributarySF <- USBR_UCRB_TributarySF %>% subset(ReportingUnitUUID %in% click)
      tempAggAmountTable <- AggAmountTable %>% filter(ReportingUnitID %in% tempUSBR_UCRB_TributarySF$ReportingUnitID)
    }
    
    
    #Produce subset of data and Plot from info on click on map event
    if(is.null(click)) {
      
      output$LP_A <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
        
      })
      
      output$LP_B <- renderPlotly({
        #Display Empty plot until mouse click selection
        validate(
          need(nrow(emptydata()) > 0, 'No selection. Please select a Reporting Unit')
        )
        plot_ly(emptydata(), x = ~ReportYearCV, y = ~SumAmouts)
      })
      
    } else {
      
      #Plot Amount v ReportYearCV by WaterSourceUUID
      output$LP_A <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & WaterSourceID
        tempAggAmountTable_WS <- left_join(x = tempAggAmountTable, y = PWaSoTable, by = "WaterSourceID")
        finalAFF_WS <- tempAggAmountTable_WS %>% group_by(ReportYearCV, WaterSourceUUID) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        LPA <- ggplot(data=finalAFF_WS, aes(x=ReportYearCV, y=SumAmouts, group=WaterSourceUUID, col=WaterSourceUUID)) +
          geom_line(show.legend = FALSE) +
          geom_point(show.legend = FALSE) +
          ggtitle(paste("Reporting Area WaDE 2.0 ID: ",click)) +
          scale_x_continuous(breaks = seq(round(min(finalAFF_WS$ReportYearCV), digits =0),
                                          round(max(finalAFF_WS$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF_WS$ReportYearCV) - min(finalAFF_WS$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "WaterSourceType") +
          theme(legend.title = element_blank(), legend.text = element_text(size = 8),
                plot.title = element_text(hjust = 0.5, size = 8),
                panel.background = element_blank(),
                axis.title.y=element_text(size = 10), axis.text.y=element_text(size = 8), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 10), axis.text.x=element_text(size = 8), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=0, b=0, l=0, "cm"))
        
        ggplotly(LPA) %>%
          layout(legend = list(orientation = "h", xanchor = "center", x = 0.5, y = -0.3))
        
      })
      
      #Plot Amount v ReportyearCV by VariableCV
      output$LP_B <- renderPlotly({
        
        #Subset of data & group by ReportyearCV & VariableCV
        tempAggAmountTable_V <- left_join(x = tempAggAmountTable, y = VarTable, by = "VariableSpecificID")
        finalAFF_V <- tempAggAmountTable_V %>% group_by(ReportYearCV, VariableCV) %>% summarise(SumAmouts = sum(Amount))
        
        #The Plot
        LPB <- ggplot(data=finalAFF_V, aes(x=ReportYearCV, y=SumAmouts, group=VariableCV, col=VariableCV)) +
          geom_line(show.legend = FALSE) +
          geom_point(show.legend = FALSE) +
          ggtitle(paste("Reporting Area WaDE 2.0 ID: ",click)) +
          scale_x_continuous(breaks = seq(round(min(finalAFF_V$ReportYearCV), digits =0),
                                          round(max(finalAFF_V$ReportYearCV), digits =0),
                                          round(sqrt(max(finalAFF_V$ReportYearCV) - min(finalAFF_V$ReportYearCV)), digits =0))) +
          scale_y_continuous(labels = scales::comma) +
          labs(x="Report Year", y="Annual Water Use (Acre-Feet)", col = "VariableType") +
          theme(legend.title = element_blank(), legend.text = element_text(size = 8),
                plot.title = element_text(hjust = 0.5, size = 8),
                panel.background = element_blank(),
                axis.title.y=element_text(size = 10), axis.text.y=element_text(size = 8), axis.line.y = element_line(size = 1),
                axis.title.x=element_text(size = 10), axis.text.x=element_text(size = 8), axis.line.x = element_line(size = 1),
                plot.margin = margin(t=0, r=0, b=0, l=0, "cm"))
        
        ggplotly(LPB) %>%
          layout(legend = list(orientation = "h", xanchor = "center", x = 0.5, y = -0.3))
      })
    }
  })
  
  ####### End County Plots Based on Observe Functions s ########
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
    req(input$tab_being_displayed == "County")  # Helps solves issue of observe({ waiting for user input before implementing.
    
    #Join AggAmountTable & VarTable. Reduce to selected year.
    data <- left_join(x = AggAmountTable, y = VarTable, by = "VariableSpecificID") %>%
      filter(
        VariableCV %in% c("Consumptive use", "Consumptive Use"),
        ReportYearCV %in% input$ReportYearInput
      ) %>%
      group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    myNewCountySF <- merge(CountySF, data)
    
    #Map & Legend Color Palette
    pal <- colorNumeric(
      palette = "Blues", 
      domain = myNewCountySF$Amount,
      na.color = NA)
    
    #Create the Map
    leafletProxy(
      mapId = "CountyMap",
    ) %>%
      clearShapes() %>% #removes points
      clearControls() %>% #removes legend
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
          "Consumptive Use : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Consumptive Use (AF)",
                pal = pal,
                values = myNewCountySF$Amount
      ) 
  })
  
  
  
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
    
    #Join AggAmountTable & VarTable. Reduce to selected year.
    data <- left_join(x = AggAmountTable, y = VarTable, by = "VariableSpecificID") %>%
      filter(
        VariableCV %in% c("Consumptive use", "Consumptive Use"),
        ReportYearCV %in% input$ReportYearInput
      ) %>%
      group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    myNewHUCSF <- merge(HUCSF, data)
    
    #Map & Legend Color Palette
    pal <- colorNumeric(palette = "Blues", domain = myNewHUCSF$Amount)
    
    leafletProxy(
      mapId = "HUC8Map",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
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
          "Consumptive Use : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"
        ),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Consumptive Use (AF)",
                pal = pal,
                values = myNewHUCSF$Amount
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
    
    #Join AggAmountTable & VarTable. Reduce to selected year.
    data <- left_join(x = AggAmountTable, y = VarTable, by = "VariableSpecificID") %>%
      filter(
        VariableCV %in% c("Consumptive use", "Consumptive Use"),
        ReportYearCV %in% input$ReportYearInput
      ) %>%
      group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    myNewCustomSF<- merge(CustomSF, data)
    
    #Map & Legend Color Palette
    # RUTypePalette <- colorFactor(palette = c("#FFFF00", "#006400", "#0000FF", "#DC143C"),
    #                              levels = c("Basin", 
    #                                         "Subarea", 
    #                                         "Detailed Analysis Unit by County (DAUCO)",
    #                                         "Active Management Area"),
    #                              na.color = "#808080")
    pal <- colorNumeric(palette = "Blues", domain = myNewCustomSF$Amount)
    
    leafletProxy(
      mapId = "CustomMap",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
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
          "Consumptive Use : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Consumptive Use (AF)",
                pal = pal,
                values = myNewCustomSF$Amount
      ) 
  })
  
  ######## End Custom Map ########
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
    
    #Join AggAmountTable & VarTable. Reduce to selected year.
    data <- left_join(x = AggAmountTable, y = VarTable, by = "VariableSpecificID") %>%
      filter(
        VariableCV %in% c("Consumptive use", "Consumptive Use"),
        ReportYearCV %in% input$ReportYearInput
      ) %>%
      group_by(ReportingUnitID, ReportYearCV, VariableCV) %>%
      summarise(Amount = sum(Amount))
    
    #Merge SpatialPolygonsDataFrame with dataframe
    myNewUSBR_UCRB_TributarySF <- merge(USBR_UCRB_TributarySF, data)
    
    #Map & Legend Color Palette
    pal <- colorNumeric(palette = "Blues", domain = myNewUSBR_UCRB_TributarySF$Amount)
    
    leafletProxy(
      mapId = "USBR_UCRB_TributaryMap",
    ) %>%
      clearShapes() %>%
      clearControls() %>%
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
          "Consumptive Use : ", Amount, "<br>",
          "Additional Info: ", paste0('<a href = "https://waterdataexchangewswc.shinyapps.io/AggPlotApp_ver1/?RUUUIDInput=', ReportingUnitUUID, '"> Link </a>'), "<br>"),
        highlightOptions = highlightOptions(
          color = "white",
          weight = 2,
          bringToFront = TRUE)
      ) %>%
      addLegend(position = "bottomleft",
                title = "Consumptive Use (AF)",
                pal = pal,
                values = myNewUSBR_UCRB_TributarySF$Amount
      ) 
  })
  
  ######## End USBR_UCRB_Tributary Map ########
  ##################################################################
  
  
  
  ############ ######################################################
  ######## Create API Tables ########
  
  observe({
    #county
    if (input$tab_being_displayed == "County") {
      click <- input$CountyMap_shape_click$id
    }
    
    #HUC8
    if (input$tab_being_displayed == "HUC8") {
      click <- input$HUC8Map_shape_click$id
    }
    
    #Custom
    if (input$tab_being_displayed == "Custom") {
      click <- input$CustomMap_shape_click$id
    }
    
    #USBR_UCRB_Tributary
    if (input$tab_being_displayed == "USBR Upper Colorado River Basin Tributarys") {
      click <- input$USBR_UCRB_TributaryMap_shape_click$id
    }
    
    #Creating string to pass to API call function based on click$id value
    str1 <- "https://wade-api-qa.azure-api.net/v1/AggregatedAmounts?ReportingUnitUUID="
    str2 <- toString(click)
    outstring <- paste0(str1,str2)
    print(outstring)
    
    
    #API Call Function
    #This returns empty / shows nothing if null
    filteredSiteAPICall <- eventReactive(click, {
      if (is.null(click)) {
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