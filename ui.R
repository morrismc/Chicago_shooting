ui = fluidPage(
  
  
  
  sliderInput(inputId = "DoY", 
              label = "Day of Year:", 
              min = 1, 
              max = 365, 
              value = 0, 
              step = 1),
  
  #Leaflet map
  # h5("integrating leafleft and shiny")
  leafletOutput("MapPlot1",width = "100%",height = "100%")
  
  
)