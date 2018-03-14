#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# 
# library(shiny)
# library(beepr)
# library(ggrepel)
# library(RCurl)
# 
# library(leaflet)
# library(htmlwidgets)
# library(htmltools)
# library(geojsonio)
# library(shiny)
# # Get Data
# #Download Up to date data from the City of Chicago
# url <- 'https://data.cityofchicago.org/api/views/k9xv-yxzs/rows.csv?accessType=DOWNLOAD'
# x <- getURL(url)
# Homocides <- read.csv(textConnection(x))

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
                    animationOptions(interval = 100, loop = TRUE)),
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
    
        #create a 2 column matrix, 1 col DoY, 2 col cumsum homocides
        D <- data.frame(Day = rep(NA,365),
                        Homocide_cnt = rep(0,365))
        
        # Zip through all of the homocides and then calculate the number of 
        # homocides per day.
        Homocides_flt <- Homocides_flt[order(Homocides_flt$Day),]
        a = 1
        for (r in 1:nrow(Homocides_flt)){
            if(Homocides_flt[r,23] == a){
              
              
              D[a,2] <- D[a,2] + 1
              
            }
          else {
            D[a,1] <- a
            a<- a + 1
          }
          
        }
        D$Homocide_cnt = cumsum(D$Homocide_cnt)
    
    # Then be ready to plot by Day of Year
    sites <- filter(Homocides_flt,Day == input$DoY)
    
    
    leafletProxy("MapPlot1", data = sites) %>% 
      
      
        addCircleMarkers(lng = sites$Longitude,
                         lat = sites$Latitude,
                         color = sites$color,
                         fill = sites$color,
                         radius = 2)
    
        
      
    

    output$histCentile <- renderPlot({

      plot(input$DoY,
           D[input$DoY,2],
           main = "Cumulative Homocides",
           xlab = "Day of Year",
           xlim = c(0, 365),
           ylim = c(0, 100)
      )


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

