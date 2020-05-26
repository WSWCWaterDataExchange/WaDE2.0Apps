# App: SitePlotApp_ver1

################################################################################################
################################################################################################
# Sec 3. The Server (function)

server <- function(input, output, session) {
  
  
  #####################################
  ## Observer to change Inputs ## 
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['SQPInput']])) {
      updateTextInput(session, "SQPInput", value = query[['SQPInput']])
    }
  })
  
  ## EndObserver to change Inputs ## 
  #####################################
  
  #####################################
  ## Functions and Reactive Data ## 
  
  #Function to concatenate strings together to form URL and API call.
  assignAPICallSiteUUID <- function(x) {
    str1 <-  "https://wade-api-qa.azure-api.net/v1/SiteAllocationAmounts?SiteUUID="
    str2 <- toString(x)
    outstring <- paste0(str1,str2)
    return(outstring)
  }
  

  #Reactive Dataset
  #This returns empty / shows nothing if null
  filteredSite <- eventReactive(input$SQPInput, {
    if (input$SQPInput == "") {
      shiny::showNotification("No data", type = "error")
      NULL
    } else {
      return(val <- fromJSON(assignAPICallSiteUUID(input$SQPInput)))
    }
  })
  
# 
#   observeEvent(input$SQPInput, {
#     Organizations <- filteredSite()[[2]][1:7]
#   })
  
  
  ## EndFunctions and Reactive Data ## 
  #####################################
  
  
  
  #####################################
  ## Outputs ## 
  
  # #Text OutputA
  # output$textOutA = renderText({
  #   paste0(filteredSite())
  # })
  # 
  
  #Table OrganizationsTable
  output$OrganizationsTable = renderDataTable({
    if(length(filteredSite()[[2]][1:7]) == 0) {
      Organizations <- list('Empty')
    } else {
      Organizations <- filteredSite()[[2]][1:7] 
    }
  })
  
  #Table WaterSourcesTable
  output$WaterSourcesTable = renderDataTable({
    if(length(filteredSite()[[2]][[8]][[1]]) == 0) {
      WaterSources <- list('Empty')
    } else {
      WaterSources <- filteredSite()[[2]][[8]][[1]]
    }
  })
  
  #Table VariableSpecificsTable
  output$VariableSpecificsTable = renderDataTable({
    if(length(filteredSite()[[2]][[9]][[1]]) == 0) {
      VariableSpecifics <- list('Empty')
    } else {
      VariableSpecifics <- filteredSite()[[2]][[9]][[1]]
    }
  })
  
  #Table MethodsTable
  output$MethodsTable = renderDataTable({
    if(length(filteredSite()[[2]][[10]][[1]]) == 0) {
      Methods <- list('Empty')
    } else {
      Methods <- filteredSite()[[2]][[10]][[1]]
    }
  })
  
  #Table BeneficialUsesTable
  output$BeneficialUsesTable = renderDataTable({
    if(length(filteredSite()[[2]][[11]][[1]]) == 0) {
      BeneficialUses <- list('Empty')
    } else {
      BeneficialUses <- filteredSite()[[2]][[11]][[1]]
    }
  })
  
  #Table SitesTable
  output$SitesTable = renderDataTable({
    if(length(filteredSite()[[2]][[12]][[1]][[24]][[1]]) == 0) {
      Sites <- list('Empty')
    } else {
      Sites <- filteredSite()[[2]][[12]][[1]][[24]][[1]]
    }
  })
  
  #Table WaterAllocationsTable
  output$WaterAllocationsTable = renderDataTable({
    #WaterAllocations
    if(length(filteredSite()[[2]][[12]][[1]][1:23]) == 0) {
      WaterAllocations <- list('Empty')
    } else {
      WaterAllocations <- filteredSite()[[2]][[12]][[1]][1:23]
    }
  })
  
  ## EndOutputs ## 
  #####################################
  
  
  #####################################
  ## Export Tables to Excel ## 
  
  #### Write an Excel workbook with one sheet per dataframe ####
  output$downloadExcel <- downloadHandler(
    
    
    filename = function() {
      "PodExcelDownload.xlsx"
    },
    content = function(file) {
      
      ## Need to recreate export variables here
      #Organizations
      if(length(filteredSite()[[2]][1:7]) == 0) {
        Organizations <- list('Empty')
      } else {
        Organizations <- filteredSite()[[2]][1:7] 
      }
      
      #WaterSources
      if(length(filteredSite()[[2]][[8]][[1]]) == 0) {
        WaterSources <- list('Empty')
      } else {
        WaterSources <- filteredSite()[[2]][[8]][[1]]
      }
      
      #Variables
      if(length(filteredSite()[[2]][[9]][[1]]) == 0) {
        VariableSpecifics <- list('Empty')
      } else {
        VariableSpecifics <- filteredSite()[[2]][[9]][[1]]
      }
      
      #Methods
      if(length(filteredSite()[[2]][[10]][[1]]) == 0) {
        Methods <- list('Empty')
      } else {
        Methods <- filteredSite()[[2]][[10]][[1]]
      }
      
      #BeneficialUses
      if(length(filteredSite()[[2]][[11]][[1]]) == 0) {
        BeneficialUses <- list('Empty')
      } else {
        BeneficialUses <- filteredSite()[[2]][[11]][[1]]
      }
      
      #WaterAllocations
      if(length(filteredSite()[[2]][[12]][[1]][1:23]) == 0) {
        WaterAllocations <- list('Empty')
      } else {
        WaterAllocations <- filteredSite()[[2]][[12]][[1]][1:23]
      }
      
      #Sites
      if(length(filteredSite()[[2]][[12]][[1]][[24]][[1]]) == 0) {
        Sites <- list('Empty')
      } else {
        Sites <- filteredSite()[[2]][[12]][[1]][[24]][[1]]
      }
      
      # write workbook and first sheet
      write.xlsx(Organizations, file, sheetName = "Organizations", append = FALSE)
      
      # add other sheets for each dataframe
      listOtherFiles <- list(WaterSources = WaterSources, 
                             VariableSpecifics = VariableSpecifics, 
                             Methods = Methods,
                             BeneficialUses = BeneficialUses,
                             WaterAllocations = WaterAllocations,
                             Sites = Sites)
      for(i in 1:length(listOtherFiles)) {
        write.xlsx(listOtherFiles[i], file, 
                   sheetName = names(listOtherFiles)[i], append = TRUE)
      }
    }
  )
  
  ## End Export Tables to Excel ## 
  #####################################

  

}
