# App: AggPlotApp_ver1

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  

  #####################################
  ## Observer to change Inputs ## 
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['RUUUIDInput']])) {
      updateTextInput(session, "RUUUIDInput", value = query[['RUUUIDInput']])
    }
  })
  
  ## EndObserver to change Inputs ## 
  #####################################
  
  #####################################
  ## Functions and Reactive Data ## 
  
  #Function to concatenate strings together to form URL and API call.
  assignAPICallSiteUUID <- function(x) {
    str1 <-  "https://wade-api-qa.azure-api.net/v1/AggregatedAmounts?ReportingUnitUUID="
    str2 <- toString(x)
    outstring <- paste0(str1,str2)
    return(outstring)
  }
  

  #Reactive Dataset
  #This returns empty / shows nothing if null
  filterAPICall <- eventReactive(input$RUUUIDInput, {
    if (input$RUUUIDInput == "") {
      shiny::showNotification("No data", type = "error")
      NULL
    } else {
      return(val <- fromJSON(assignAPICallSiteUUID(input$RUUUIDInput)))
    }
  })
  

  ## EndFunctions and Reactive Data ## 
  #####################################
  
  
  
  #####################################
  ## Text & Table Outputs ## 
  
  #Table OrganizationsTable
  output$OrganizationsTable = renderDataTable({
    if(length(filterAPICall()[[2]][1:7]) == 0) {
      Organizations <- list('Empty')
    } else {
      Organizations <- filterAPICall()[[2]][1:7]
    }
  })
  
  #Table WaterSourcesTable
  output$WaterSourcesTable = renderDataTable({
    if(length(filterAPICall()[[2]][[8]][[1]]) == 0) {
      WaterSources <- list('Empty')
    } else {
      WaterSources <- filterAPICall()[[2]][[8]][[1]]
    }
  })
  
  
  #Table ReportingUnitsTable
  output$ReportingUnitsTable = renderDataTable({
    # filterAPICall()[[2]][[9]][[1]]
    if(length(filterAPICall()[[2]][[9]][[1]]) == 0) {
      ReportingUnits <- list('Empty')
    } else {
      ReportingUnits <- filterAPICall()[[2]][[9]][[1]]
    }
      })
  
  #Table VariableSpecificsTable
  output$VariableSpecificsTable = renderDataTable({
    if(length(filterAPICall()[[2]][[10]][[1]]) == 0) {
      VariableSpecifics <- list('Empty')
    } else {
      VariableSpecifics <- filterAPICall()[[2]][[10]][[1]]
    }
  })
  
  #Table MethodsTable
  output$MethodsTable = renderDataTable({
    if(length(filterAPICall()[[2]][[11]][[1]]) == 0) {
      Methods <- list('Empty')
    } else {
      Methods <- filterAPICall()[[2]][[11]][[1]]
    }
  })
  
  #Table BeneficialUsesTable
  output$BeneficialUsesTable = renderDataTable({
    if(length(filterAPICall()[[2]][[12]][[1]]) == 0) {
      BeneficialUses <- list('Empty')
    } else {
      BeneficialUses <- filterAPICall()[[2]][[12]][[1]]
    }
  })
  
  #Table AggregatedAmountsTable
  output$WaterAllocationsTable = renderDataTable({
    if(length(filterAPICall()[[2]][[13]][[1]]) == 0) {
      WaterAllocations <- list('Empty')
    } else {
      WaterAllocations <- filterAPICall()[[2]][[13]][[1]]
    }
  })
  

  
  ## Text & Table EndOutputs ## 
  #####################################
  
  
  #####################################
  ## Export Tables to Excel ## 
  
  #### Write an Excel workbook with one sheet per dataframe ####
  output$downloadExcel <- downloadHandler(
    
    
    filename = function() {
      "AggDataExcelDownload.xlsx"
    },
    content = function(file) {
      
      ## Need to recreate export variables here

      #Organizations
      if(length(filterAPICall()[[2]][1:7]) == 0) {
        Organizations <- list('Empty')
      } else {
        Organizations <- filterAPICall()[[2]][1:7] 
      }
      
      #WaterSources
      if(length(filterAPICall()[[2]][[8]][[1]]) == 0) {
        WaterSources <- list('Empty')
      } else {
        WaterSources <- filterAPICall()[[2]][[8]][[1]] 
      }
      
      #Reporting Units
      if(length(filterAPICall()[[2]][[9]][[1]]) == 0) {
        ReportingUnits <- list('Empty')
      } else {
        ReportingUnits <- filterAPICall()[[2]][[9]][[1]] 
      }

      #Variables
      if(length(filterAPICall()[[2]][[10]][[1]]) == 0) {
        VariableSpecifics <- list('Empty')
      } else {
        VariableSpecifics <- filterAPICall()[[2]][[10]][[1]]
      }
      
      #Methods
      if(length(filterAPICall()[[2]][[11]][[1]]) == 0) {
        Methods <- list('Empty')
      } else {
        Methods <- filterAPICall()[[2]][[11]][[1]]
      }
      
      #BeneficialUses
      if(length(filterAPICall()[[2]][[12]][[1]]) == 0) {
        BeneficialUses <- list('Empty')
      } else {
        BeneficialUses <- filterAPICall()[[2]][[12]][[1]]
      }
      
      #AggregatedAmounts
      if(length(filterAPICall()[[2]][[13]][[1]]) == 0) {
        AggregatedAmounts <- list('Empty')
      } else {
        AggregatedAmounts <- filterAPICall()[[2]][[13]][[1]][1:12]
      }
      
      # #Text OutputA
      # if(is.null(filterAPICall())) {
      #   APIStringReturn <- list('Empty')
      # } else {
      #   APIStringReturn <- filterAPICall()[]
      # }
      
      # write workbook and first sheet
      write.xlsx(Organizations, file, sheetName = "Organizations", append = FALSE)
      
      # add other sheets for each dataframe
      listOtherFiles <- list(WaterSources = WaterSources,
                             ReportingUnits = ReportingUnits,
                             VariableSpecifics = VariableSpecifics,
                             Methods = Methods,
                             BeneficialUses = BeneficialUses,
                             AggregatedAmounts = AggregatedAmounts)
                             # APIStringReturn = APIStringReturn)

      for(i in 1:length(listOtherFiles)) {
        write.xlsx(listOtherFiles[i], file, 
                   sheetName = names(listOtherFiles)[i], append = TRUE)
      }
    }
  )
  
  ## End Export Tables to Excel ## 
  #####################################


}
