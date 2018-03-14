library(leaflet)
library(shiny)

server = function(input, output) {
  
  
  output$MapPlot1 <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles(providers$OpenStreetMap) %>%
      setView(lng = -87.62317, lat = 41.881832, zoom = 11)
  })
  
  
  observe({
    
    sites <- filter(Homocides_2018,Day == input$DoY)
    
    browser()
    leafletProxy("MapPlot1") %>% 
      clearMarkers() %>% 
      addProviderTiles(providers$OpenStreetMap) %>% 
      addCircleMarkers(lng = sites$Longitude,
                       lat = sites$Latitude)
  })
}


