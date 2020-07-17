# App: MapPODSite_ver2

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  ##################################################################
  ####### ObserveEvent########
  
  #Reset Button - resest all inputs to starting values
  observeEvent(input$reset_input, {
    updateSliderInput(session, "DateInput", 
                      min = as.Date("1850-01-01","%Y-%m-%d"), 
                      max = as.Date("2016-09-09","%Y-%m-%d"),
                      value = c(as.Date("1850-01-01","%Y-%m-%d"), as.Date("2016-09-09","%Y-%m-%d")),
                      timeFormat="%Y-%m-%d")
    updateCheckboxGroupInput(session, "StateInput", selected = StateList)
    updateCheckboxGroupInput(session, "BenUseInput", selected = BenUseList)
    updateNumericInput(session, "minAA_CFS", value = 0)
    updateNumericInput(session, "maxAA_CFS", value = max(P_AlloLFSite$AA_CFS))
    updateNumericInput(session, "minAA_AF", value = 0)
    updateNumericInput(session, "maxAA_AF", value = max(P_AlloLFSite$AA_AF))
  })
  
  
  
  #Change Report Year Slider to Default Value depending on tab
  observe({
    
    #CRB
    if (input$tab_being_displayed == "CRB") {
      stLabel = 'Select CRB State'
      StateChoices = c("CA", "CO", "NM", "UT")
      StateSelected = c("CA", "CO", "NM", "UT")
      BenUseLabel = 'Select CRB Primary Benificial Use'
      BenUseChoices =  c("Agricultural", "Commercial", "Domestic", "Environmental", "Fire",
                         "Industrial", "Livestock", "Mining", "Municipal", "Other",
                         "Power", "Recharge", "Recreation", "Snow Making", "Storage", "Wildlife")
      BenUseSelected = c("Agricultural", "Commercial", "Domestic", "Environmental", "Fire",
                         "Industrial", "Livestock", "Mining", "Municipal", "Other",
                         "Power", "Recharge", "Recreation", "Snow Making", "Storage", "Wildlife")
    }
    
    #Default
    else {
      stLabel = "Select State"
      StateChoices = StateList
      StateSelected = StateList
      BenUseLabel = 'Select Primary Benificial Use'
      BenUseChoices = BenUseList
      BenUseSelected = BenUseList
    }
    
    #Update the Input
    updateCheckboxGroupInput(session, inputId = "StateInput", label = stLabel,
                             choices = StateChoices, selected = StateChoices)
    updateCheckboxGroupInput(session, inputId = "BenUseInput", label = BenUseLabel,
                             choices = BenUseChoices, selected = BenUseSelected)
  })
  
  
  ####### End ObserveEvent ########
  ##################################################################
  
  
  
  ##################################################################
  ####### Reactive Data Sets ########
  
  #For Empty Plots before Mouse Selection
  emptydata <- reactive({NULL})
  
  #Filter Allow Table
  filter_TableAllo <- reactive({
    P_AlloLFSite %>%
      filter(
        (PD >= input$DateInput[1]),
        (PD <= input$DateInput[2]),
        (AA_CFS >= input$minAA_CFS),
        (AA_CFS <= input$maxAA_CFS),
        (AA_AF >= input$minAA_AF),
        (AA_AF <= input$maxAA_AF),
        (State %in% input$StateInput)
      )
  })
  
  #Filter Site Map All
  filter_MapSite_All <- reactive({
    P_SiteLFAllo %>%
      filter(
        (WBenUse %in% input$BenUseInput),
        (SiteUUID %in% filter_TableAllo()$SiteUUID)
      )
  })
  
  
  #Filter Site Map CRB
  filter_MapSite_CRB <- reactive({
    P_SiteLFAllo_CRB %>%
      filter(
        (WBenUse %in% input$BenUseInput),
        (SiteUUID %in% filter_TableAllo()$SiteUUID)
      )
  })
  
  ####### End Reactive Data Sets ########
  ##################################################################
  
  
  ##################################################################
  ####### mapAll text input from click Observe Functions ########
  
  ## use an observer to respond to the click event.
  observeEvent({input$mapAll_scatterplot_click},{
    click <- input$mapAll_scatterplot_click
    clickjs <- jsonlite::fromJSON(click)
    
    #Table reaction to click
    #The Mapdeck return of index is off by 1 when it returns the table index.
    #Use row indexing of the table
    tablereturn <- (clickjs$index) + 1
    selectedLocations <- filter_MapSite_All()[tablereturn,]
    tempAlloTable <- merge(x = P_AlloLFSite, y = selectedLocations, by = "SiteUUID")
    
    #Produce subset of data and Plot from info on click on map event
    if(is.null(click)) {
      output$mytable <- renderDataTable({
        validate(need(nrow(emptydata()) > 0, 'No selection. Please select a Site'))
        DT::datatable(emptydata(), options = list(lengthMenu = c(10, 30, 50), pageLength = 10))
      })
    } else {
      output$mytable <- renderDataTable({
        DT::datatable(tempAlloTable, options = list(lengthMenu = c(10, 30, 50), pageLength = 10))
      })
    }
  })
  
  ####### End mapAll text input from click Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ####### mapCRB text input from click Observe Functions ########
  
  ## use an observer to respond to the click event.
  observeEvent({input$mapCRB_scatterplot_click},{
    click <- input$mapCRB_scatterplot_click
    clickjs <- jsonlite::fromJSON(click)
    
    #Table reaction to click
    #The Mapdeck return of index is off by 1 when it returns the table index.
    #Use row indexing of the table
    tablereturn <- (clickjs$index) + 1
    selectedLocations <- filter_MapSite_CRB()[tablereturn,]
    tempAlloTable <- merge(x = P_AlloLFSite, y = selectedLocations, by = "SiteUUID")
    
    #Produce subset of data and Plot from info on click on map event
    if(is.null(click)) {
      output$mytable <- renderDataTable({
        validate(need(nrow(emptydata()) > 0, 'No selection. Please select a Site'))
        DT::datatable(emptydata(), options = list(lengthMenu = c(10, 30, 50), pageLength = 10))
      })
    } else {
      output$mytable <- renderDataTable({
        DT::datatable(tempAlloTable, options = list(lengthMenu = c(10, 30, 50), pageLength = 10))
      })
    }
  })
  
  ####### End mapCRB text input from click Observe Functions ########
  ##################################################################
  
  
  
  ##################################################################
  ######## mapAll MapDeck ########
  
  #Base Map Creation
  output$mapAll <- renderMapdeck({
    mapdeck(
      token = access_token,
      location = c(-100.9349, 40.27901),
      zoom = 3.5)
  })
  
  # Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "All Sites")
    
    #Create row index on the fl using seq.int() function.
    #For map click reaction.
    tempsite <- filter_MapSite_All()
    tempsite$SID <- seq.int(nrow(tempsite))
    
    #Custom Category Legend
    l1 <- legend_element(
      variables = c("Agricultural", "Commercial", "Domestic", "Environmental", "Fire", "Flood Control",
                    "Industrial", "Livestock", "Mining", "Municipal", "Power", "Recharge", 
                    "Recreation", "Snow Making", "Storage", "Wildlife", "State Specific"), 
      colours = c("#FFFF00FF", "#008000FF", "#0000FFFF", "#32CD32FF", "#FF0000FF", "#00FFFFFF",
                  "#800080FF", "#FFD700FF", "#A52A2AFF", "#4B0082FF", "#FFA500FF", "#D2691EFF", 
                  "#FFC0CBFF", "#F0FFF0FF", "#F5DEB3FF", "#ADFF2FFF", "#808080FF"),  
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
        fill_colour = "WBenUseColor",
        radius = 1500,
        tooltip = "SiteUUID",
        auto_highlight = TRUE,
        update_view = FALSE,
        legend = js
      )
  })
  
  ######## End mapAll MapDeck ########
  ##################################################################
  
  
  
  ##################################################################
  ######## mapCRB MapDeck ########
  
  #Base Map Creation
  output$mapCRB <- renderMapdeck({
    mapdeck(
      token = access_token,
      location = c(-108.50, 36.50),
      zoom = 5)
  })
  
  # Incremental Changes to the Map
  observe({
    req(input$tab_being_displayed == "CRB")
    
    #Create row index on the fl using seq.int() function.
    #For map click reaction.
    tempsite <- filter_MapSite_CRB()
    tempsite$SID <- seq.int(nrow(tempsite))
    
    #Custom Category Legend
    l1 <- legend_element(
      variables = c("Agricultural", "Commercial", "Domestic", "Environmental", "Fire", "Industrial",
                    "Livestock", "Mining", "Municipal", "Power", "Recharge", "Recreation",
                    "Snow Making", "Storage", "Wildlife", "State Specific"), 
      colours = c("#FFFF00FF", "#008000FF", "#0000FFFF", "#32CD32FF", "#FF0000FF", "#800080FF",
                  "#FFD700FF", "#A52A2AFF", "#4B0082FF", "#FFA500FF", "#D2691EFF", "#FFC0CBFF",
                  "#F0FFF0FF", "#F5DEB3FF", "#ADFF2FFF", "#808080FF"), 
      colour_type = "fill", 
      variable_type = "category",
      title = "Primary Beneficial Use",
      css = "max-height: 500px; 
             background-color: white;
             border-style: solid; border-width: 2px; border-color: black; border-radius: 10px;")
    
    js <- mapdeck_legend(l1)
    
    mapdeck_update(map_id = "mapCRB") %>%
      add_polygon(
        data = CRBasinSF,
        stroke_colour = "#000000FF",
        stroke_width = 1000,
        fill_opacity = (255/2),
        legend = FALSE,
        auto_highlight = FALSE,
        update_view = FALSE
      ) %>%
      add_scatterplot(
        data = tempsite,
        id = "SiteUUID",
        lat = "Lat",
        lon = "Long",
        fill_colour = "WBenUseColor",
        radius = 1500,
        tooltip = "SiteUUID",
        auto_highlight = TRUE,
        update_view = FALSE,
        legend = js
      )
  })
  
  ######## End mapCRB MapDeck ########
  ##################################################################
  
  
  
  
  
  
  
  
  
  
  
  
  #####################################
  ## Functions and Reactive Data ## 
  
  observeEvent({input$mapCRB_scatterplot_click},{
    click <- input$mapCRB_scatterplot_click
    clickjs <- jsonlite::fromJSON(click)
    
    #Table reaction to click
    #The Mapdeck return of index is off by 1 when it returns the table index.
    #Use row indexing of the table
    tablereturn <- (clickjs$index) + 1
    selectedLocations <- filter_MapSite_CRB()[tablereturn,]
    SQLInput <- selectedLocations$SiteUUID
    print(SQLInput)
    
    
    str1 <-  "https://wade-api-qa.azure-api.net/v1/SiteAllocationAmounts?SiteUUID="
    str2 <- toString(SQLInput)
    outstring <- paste0(str1,str2)
    
    
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
    
    # #Reactive Dataset
    # #This returns empty / shows nothing if null
    # filteredSiteAPICall <- eventReactive(input$SQPInput, {
    #   if (input$SQPInput == "") {
    #     shiny::showNotification("No data", type = "error")
    #     NULL
    #   } else {
    #     return(val <- fromJSON(assignAPICallSiteUUID(input$SQPInput)))
    #   }
    # })
    
    #####################################
    ## Outputs ## 
    
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
    
    ## EndOutputs ## 
    #####################################
    
    
  })
  
  ## EndFunctions and Reactive Data ## 
  #####################################
  
  
  
  
  
  
} #endServer