#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# 
setwd('/Users/matthew/Documents/GitHub/Chicago_shooting/Homocides')
library(beepr)
library(ggrepel)
library(RCurl)

library(leaflet)
library(htmlwidgets)
library(htmltools)
# library(geojsonio)
library(shiny)

library(progress)
library(tidyverse)
require(knitr)
require(scales)


# Get Data
#Download Up to date data from the City of Chicago
Homocides <- read.csv('Homocides.csv')


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
    sidebarPanel(
      selectInput('Yr','Year',(unique(Homocides$Year))),  
      sliderInput(inputId = "DoY", 
                  label = "Day of Year:", 
                  min = 0, 
                  max = 365, 
                  value = 0, 
                  step = 1,
                  animate = 
                    animationOptions(interval = 100, loop = FALSE)),
      actionButton("resetB","Reset Plot",class = "btn-block")
      
    ),
    
    #Leaflet map
    # h5("integrating leafleft and shiny")
    mainPanel(
      leafletOutput("MapPlot1",width = "100%",height = "800")
    ),
    
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                  draggable = FALSE, top = 300, left = 20, right = 20, bottom = "auto",
                  width = 300, height = "auto",

                  plotOutput("histCentile", height = 400)


                  )
    
)



# Define server logic required to draw the map
a = rep(0, 366)
server <- function(input, output) {
   
  output$MapPlot1 <- renderLeaflet({
    leaflet() %>% 
      addProviderTiles(providers$OpenStreetMap) %>%
      setView(lng = -87.62317, lat = 41.881832, zoom = 10)
  })
  
  
  
  
  observe({
    # Filter by Year
    Homocides_flt <- filter(Homocides,Year == input$Yr)
    # 
    #     #create a 1 column matrix,1 col cumsum homocides
        D <- data.frame(Homocide_cnt = rep(1,nrow(Homocides_flt)),
                        DoY = rep(0,nrow(Homocides_flt)))
        D$Homocide_cnt <- ave(D$Homocide_cnt,  FUN=cumsum)
        D$DoY <- Homocides_flt$Day
    #     #filter the homocides to be ordered by day of year
        Homocides_flt <- Homocides_flt[order(Homocides_flt$Day),]
    #     
        
    
    # Then be ready to plot by Day of Year
    sites <- filter(Homocides_flt,Day == input$DoY)
    
    
    leafletProxy("MapPlot1", data = sites) %>% 
      
      
        addCircleMarkers(lng = sites$Longitude,
                         lat = sites$Latitude,
                         color = sites$color,
                         fill = sites$color,
                         radius = 2)
    
        
      
    

     output$histCentile <- renderPlot({
    
       plot(Homocides_flt$Day,
           D$Homocide_cnt,
            main = "Cumulative Homocides",
            xlab = "Day of Year",
            ylab = "Cumulative Count",
            xlim = c(0, 365),
            ylim = c(0, 700),
            type = 'l'
       )
       abline(v = input$DoY)
       


     })
     # browser()
  })
  
  
  
  
  
  # Observe for a Reset Button Press
  observeEvent(input$resetB, {
    leafletProxy("MapPlot1") %>%
      clearMarkers()
    # browser()
  })
  
  
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

