#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(httr)
library(tidyverse)
library(sf)
library(leaflet)
library(RColorBrewer)
library(opentripplanner)

iso <- st_read("/Users/emmettmckinney/Documents/CodeAcademy/Transit_Equity_Viz/data_viz/iso.geojson")
iso <- iso %>% st_transform(4326) #read static default file 
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    #set pallette
    
    pal=colorBin(palette = 'Spectral', bins = 4, domain = iso$time)
    
    start_lat <- 42.337127
    start_lng <- -71.149224
    
    #set up palette
    output$mymap <- renderLeaflet({
        
        leaflet(iso) %>%
            setView(lng = -71.100003, lat = 42.340479, zoom = 12) %>%
            addProviderTiles(providers$Stamen.TonerLite,
                             options = providerTileOptions(opacity = 0.8)) %>%  
            addPolygons(stroke = TRUE, weight=0.5,
                        smoothFactor = 0.3, color="black",
                        fillOpacity = 0.2, fillColor = ~pal(iso$time)) %>%
            addMarkers(lng = start_lng, lat = start_lat, group = 'temp', popup = (paste("You chose","<br>",start_lat,",",start_lng))) %>%
            addLegend(position="bottomleft", 
                      colors = c("#d7191c", "#fdae61", "#abdda4", "#2b83ba"), 
                      values = ~(iso$time),
                      labels= rev(c("60 min","45 min", "30 min","15 min")),
                      opacity = 0.6,
                      title="Travel Time with Public Transport")
        
        })
        
    #set values based on user click (but leave static values for testing)
   
    ## FUNCTION TO UPDATE MAP
    
    observeEvent(input$mymap_click, { 
        
    lat <- input$mymap_click$lat
    lng <- input$mymap_click$lng 
    
    leafletProxy("mymap") %>%  ## add a marker showing selected location
        clearGroup('temp') %>%
        flyTo(lng = lng, lat = lat, zoom = 12) %>%
        addMarkers(lng = lng, lat = lat, group = 'temp', popup = (paste("You chose","<br>",lat,",",lng)))

    })
    
    observeEvent(input$go, {
    
    lat <- input$mymap_click$lat ## add default value here
    lng <- input$mymap_click$lng ## add default value here
    
    current <- GET(
        "http://localhost:8080/otp/routers/mbta/isochrone", ##depends on OTP running on local host. Use opentripplanner package to start new OTP server, using files stored with ShinyApp. 
        query = list(
            toPlace = "53.3627432,-2.2729342",
            fromPlace = paste(lat,lng,sep = ","), # latlong of place
            mode = paste(input$modes, collapse = ","), # modes we want the route planner to use
            date = "10-22-2020",
            time= paste0(input$hh,":",input$mm,input$am_pm),
            maxTimeSec = as.numeric(input$mins)*60,
            maxWalkDistance = (as.numeric(input$walk)*1609.344), #convert mile input to metres
            walkReluctance = 5,
            minTransferTime = (as.numeric(input$transfer)*60),
            wheelchair = input$wheelchair,
            maxTransfers = input$max_transfer, # in secs
            cutoffSec = 900,
            cutoffSec = 1800,
            cutoffSec = 2700,
            cutoffSec = 3600)
        ) 
   
        current <- content(current, as = "text", encoding = "UTF-8")
        new_data <- st_read(current) %>% st_transform(4326)
        
        st_write(new_data, delete_dsn = TRUE, "/Users/emmettmckinney/Documents/CodeAcademy/Transit_Equity_Viz/data_viz/icon.geojson")
     
    leafletProxy("mymap") %>%
                 clearShapes() %>%
                 addPolygons(data = new_data, group = 'temp', stroke = TRUE, weight=0.5,
                                 smoothFactor = 0.3, color="black",
                                 fillOpacity = 0.2,fillColor = ~pal(new_data$time) )   
        
    })
    
    
    
    
    
    
    })

## /otp/routers/{routerId}/index/stops <- use this to get stops associated with a particular coordinate (input$map_click)
## /otp/routers/{routerId}/index/stops/{stopId}/routes <- use this to get routes associated with stop (input$map_marker_click)


