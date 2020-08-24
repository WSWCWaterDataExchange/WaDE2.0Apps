# App: MapPODSite_ver2b

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### Observe Functions ########
  
  #Reset Button - resest all inputs to starting values
  observeEvent(input$reset_input, {
    updateSliderInput(session, "DateInput", 
                      min = as.Date("1850-01-01","%Y-%m-%d"), 
                      max = as.Date("2016-09-09","%Y-%m-%d"),
                      value = c(as.Date("1850-01-01","%Y-%m-%d"), as.Date("2016-09-09","%Y-%m-%d")),
                      timeFormat="%Y-%m-%d")
    updatePickerInput(session, "StateInput", selected = StateList)
    updatePickerInput(session, "BenUseInput", selected = BenUseList)
    updateNumericInput(session, "minAA_CFS", value = 0)
    updateNumericInput(session, "maxAA_CFS", value = max(P_AlloLFSite$AA_CFS))
    updateNumericInput(session, "minAA_AF", value = 0)
    updateNumericInput(session, "maxAA_AF", value = max(P_AlloLFSite$AA_AF))
    updatePickerInput(session, "SiteTypeInput", selected = SiteTypeList)
    updatePickerInput(session, "WaterSourceTypeInput", selected = WaterSourceTypeList)
    updatePickerInput(session, "AllocationOwnerInput", selected = AllocationOwnerList)
  })
  


  ##################################################################
  ####### Reactive Data Sets ########
  
  #For Empty Plots before Mouse Selection
  emptydata <- reactive({NULL})
  
  
  #Filter Allow Table - to filter down sites according to the user Inputs selection
  filter_TableAllo <- reactive({
    P_AlloLFSite %>%
      filter(
        (PD >= input$DateInput[1]),
        (PD <= input$DateInput[2]),
        (AA_CFS >= input$minAA_CFS),
        (AA_CFS <= input$maxAA_CFS),
        (AA_AF >= input$minAA_AF),
        (AA_AF <= input$maxAA_AF),
        (State %in% input$StateInput),
        (SiteTypeCV %in% input$SiteTypeInput),
        (WaterSourceTypeCV %in% input$WaterSourceTypeInput),
        (AllocationOwner %in% input$AllocationOwnerInput)
      )
  })
  
  
  #Filter Site Map Basin - reduce Basin site map down based on user inputs from Allow Table
  filter_MapSite_Basins <- reactive({
    P_SiteLFAllo_Basins %>%
      filter(
        (Basin %in% input$RiverBasin),
        (WBenUse %in% input$BenUseInput),
        (SiteUUID %in% filter_TableAllo()$SiteUUID)
      )
  })
  
  
  #Filter Site Map All - reduce All site map down based on user inputs from Allow Table
  filter_MapSite_All <- reactive({
    P_SiteLFAllo %>%
      filter(
        (WBenUse %in% input$BenUseInput),
        (SiteUUID %in% filter_TableAllo()$SiteUUID)
      )
  })
  
  
  #Filter BasinsSF Polygon Shapefile
  filter_BasinsSF <- reactive({
    BasinsSF %>%
      filter(
        (BasinName %in% input$RiverBasin),
      )
  })
  

  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  
  ##################################################################
  ######## Create mapBasins ########
  
  #Base Map Creation
  output$mapBasins <- renderMapdeck({
    mapdeck(
      token = access_token,
      style = style_url,
      location = c(-100.9349, 40.27901),
      zoom = 3.5)
  })
  
  # Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "River Basins")
    
    #Create row index on the fl using seq.int() function.
    #For map click reaction.
    tempsite <- filter_MapSite_Basins()
    tempsite$SID <- seq.int(nrow(tempsite))
    
    #Custom Polygon Category Legend
    lePolygon <- legend_element(
      variables = c("Rio Grande Basin", "Colorado River Basin", "Columbia Basin"),
      colours = c("#FFFF00FF", "#800080FF", "#3CB371FF"),
      colour_type = "fill",
      variable_type = "category",
      title = "River Basin",
      css = "max-height: 500px;
             background-color: white;
             border-style: solid; border-width: 2px; border-color: black; border-radius: 10px;")
    lePolygon_js <- mapdeck_legend(lePolygon)
    
    #Custom Site Category Legend
    leSites <- legend_element(
      variables = c("Agricultural", "Commercial", "Domestic", "Environmental", "Fire", "Flood Control",
                    "Industrial", "Livestock", "Mining", "Municipal", "Power", "Recharge", 
                    "Recreation", "Snow Making", "Storage", "Wildlife", "State Specific"), 
      colours = c("#006400FF", "#FFFF00FF", "#0000FFFF", "#32CD32FF", "#FF0000FF", "#00FFFFFF",
                  "#800080FF", "#FFD700FF", "#A52A2AFF", "#4B0082FF", "#FFA500FF", "#D2691EFF", 
                  "#FFC0CBFF", "#F0FFF0FF", "#F5DEB3FF", "#ADFF2FFF", "#808080FF"),  
      colour_type = "fill", 
      variable_type = "category",
      title = "Primary Beneficial Use",
      css = "max-height: 500px; 
             background-color: white;
             border-style: solid; border-width: 2px; border-color: black; border-radius: 10px;")
    leSites_js <- mapdeck_legend(leSites)
    
    mapdeck_update(map_id = "mapBasins") %>%
      add_polygon(
        data = filter_BasinsSF(),
        stroke_colour = "#000000FF",
        stroke_width = 1000,
        fill_colour = "BasinName",
        fill_opacity = (255/2),
        auto_highlight = FALSE,
        update_view = FALSE,
        legend = lePolygon_js
      ) %>%
      add_scatterplot(
        data = tempsite,
        id = "SiteUUID",
        lat = "Lat",
        lon = "Long",
        fill_colour = "WBenUseColor",
        radius = 1000,
        tooltip = "SiteUUID",
        auto_highlight = TRUE,
        update_view = FALSE,
        legend = leSites_js
      )
  })
  
  ######## End Create mapBasins ########
  ##################################################################
  

  ##################################################################
  ######## Create mapAll ########
  
  ##Base Map Creation
  output$mapAll <- renderMapdeck({
    mapdeck(
      token = access_token,
      style = style_url,
      location = c(-100.9349, 40.27901),
      zoom = 3.5)
  })
  
  ##Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "All Sites")
    
    ##Create row index on the fl using seq.int() function.
    #For map click reaction.
    tempsite <- filter_MapSite_All()
    tempsite$SID <- seq.int(nrow(tempsite))
    
    ##Custom Category Legend
    #Create Use and Color list based in User Inputs and dictionary.
    BenUseDictList <- input$BenUseInput
    BenUseColDictList <- values(BenUseColorDict[BenUseDictList], USE.NAMES=FALSE)
    
    l1 <- legend_element(
      variables = BenUseDictList,
      colours = BenUseColDictList,
      colour_type = "fill", 
      variable_type = "category",
      title = "Primary Beneficial Use",
      css = "max-height: 500px; 
             background-color: white;
             border-style: solid; border-width: 2px; border-color: black; border-radius: 10px;")
    
    js <- mapdeck_legend(l1)
    
    mapdeck_update(map_id = 'mapAll') %>%
      add_scatterplot(
        data = tempsite,
        id = "SiteUUID",
        lat = "Lat",
        lon = "Long",
        stroke_colour = "#FFFFFFFF",
        stroke_width = 200,
        fill_colour = "WBenUseColor",
        radius = 2000,
        tooltip = "SiteUUID",
        auto_highlight = TRUE,
        update_view = FALSE,
        legend = js
      )
  })
  
  ######## End Create mapAll ########
  ##################################################################
  
  
  
  ##################################################################
  ######## Create Basin Map API Tables ########
  
  observeEvent({input$mapBasins_scatterplot_click},{
    req(input$tab_being_displayed == "River Basins")
    
    click <- input$mapBasins_scatterplot_click
    clickjs <- jsonlite::fromJSON(click)
    
    tempsite <- filter_MapSite_Basins()
    tempsite$SID <- seq.int(nrow(tempsite))
    
    #Table reaction to click
    #The Mapdeck return of index is off by 1 when it returns the table index.
    #Use row indexing of the table
    tablereturn <- (clickjs$index) + 1
    selectedLocations <- tempsite[tablereturn,]
    SQLInput <- selectedLocations$SiteUUID
    print(SQLInput)
    
    str1 <-  "https://wade-api-qa.azure-api.net/v1/SiteAllocationAmounts?SiteUUID="
    str2 <- toString(SQLInput)
    outstring <- paste0(str1,str2)
    print(outstring)
    
    #Reactive Dataset
    #This returns empty / shows nothing if null
    filteredSiteAPICall <- eventReactive(SQLInput, {
      if (SQLInput == "" || is.null(SQLInput)) {
        # return(shiny::showNotification("No data", type = "error"))
        val <- emptydata()
      } else {
        val <- fromJSON(outstring)
      }
      return(val)
    })
    
    #Table OrganizationsTable
    output$OrganizationsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][1:7],
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][1:7]),
                      background = 'white',
                      color='black')
    })
    
    
    
    
    #Table WaterSourcesTable
    output$WaterSourcesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[8]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[8]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table VariableSpecificsTable
    output$VariableSpecificsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[9]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[9]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table MethodsTable
    output$MethodsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[10]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[10]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table BeneficialUsesTable
    output$BeneficialUsesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[11]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[11]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table SitesTable
    output$SitesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[12]][[1]][[24]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[12]][[1]][[24]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table WaterAllocationsTable
    output$WaterAllocationsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[12]][[1]][1:23], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[12]][[1]][1:23]),
                      background = 'white',
                      color='black')
    })
    
  })
  
  ######## Create Basin Map API Tables ########
  ##################################################################
  
  
  
  ##################################################################
  ######## Create ALL Map API Tables ########
  
  observeEvent({input$mapAll_scatterplot_click},{
    
    req(input$tab_being_displayed == "All Sites")
    
    click <- input$mapAll_scatterplot_click
    clickjs <- jsonlite::fromJSON(click)
    
    tempsite <- filter_MapSite_All()
    tempsite$SID <- seq.int(nrow(tempsite))
    
    #Table reaction to click
    #The Mapdeck return of index is off by 1 when it returns the table index.
    #Use row indexing of the table
    tablereturn <- (clickjs$index) + 1
    selectedLocations <- tempsite[tablereturn,]
    SQLInput <- selectedLocations$SiteUUID
    print(SQLInput)
    
    str1 <-  "https://wade-api-qa.azure-api.net/v1/SiteAllocationAmounts?SiteUUID="
    str2 <- toString(SQLInput)
    outstring <- paste0(str1,str2)
    print(outstring)
    
    #Reactive Dataset
    #This returns empty / shows nothing if null
    filteredSiteAPICall <- eventReactive(SQLInput, {
      if (SQLInput == "") {
        shiny::showNotification("No data", type = "error")
        NULL
      } else {
        return(val <- fromJSON(outstring))
      }
    })
    
    #Table OrganizationsTable
    output$OrganizationsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][1:7] , 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][1:7]),
                      background = 'white',
                      color='black')
    })
    
    #Table WaterSourcesTable
    output$WaterSourcesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[8]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[8]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table VariableSpecificsTable
    output$VariableSpecificsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[9]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[9]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table MethodsTable
    output$MethodsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[10]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[10]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table BeneficialUsesTable
    output$BeneficialUsesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[11]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[11]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table SitesTable
    output$SitesTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[12]][[1]][[24]][[1]], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[12]][[1]][[24]][[1]]),
                      background = 'white',
                      color='black')
    })
    
    #Table WaterAllocationsTable
    output$WaterAllocationsTable <- DT::renderDataTable({
      DT::datatable(filteredSiteAPICall()[[2]][[12]][[1]][1:23], 
                    rownames = FALSE) %>% formatStyle(
                      columns=colnames(filteredSiteAPICall()[[2]][[12]][[1]][1:23]),
                      background = 'white',
                      color='black')
    })
    
  })
  
  ######## End Create ALL Map API Tables ########
  ##################################################################
  
  
} #endServer