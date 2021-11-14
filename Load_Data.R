setwd('/Users/matthew/Documents/GitHub/Chicago_shooting/')



library(ggplot2)
# library(countrycode)
library(progress)
library(tidyverse)
require(knitr)
require(scales)
library(BBmisc)
library(ggrepel)
library(RCurl)

library(leaflet)
library(htmlwidgets)
library(htmltools)
library(geojsonio)
library(shiny)
#Download Up to date data from the City of Chicago
url <- 'https://data.cityofchicago.org/api/views/k9xv-yxzs/rows.csv?accessType=DOWNLOAD'
x <- getURL(url)
Homocides <- read.csv(textConnection(x))
#################################### Extract 2018 ####################################

Homocides_2018 <- filter(Homocides, Year == 2018)


m <- leaflet(width = 400, height = 400) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  
  addCircleMarkers(lng = Homocides_2018$Longitude, 
                   lat = Homocides_2018$Latitude,
                   radius = 6)




m  # Print the map

#################################### Process data ####################################
# In this section, I want to convert from the date to Day of the Year

library(lubridate)
DayofYear <- data.frame(Day = rep(NA,nrow(Homocides)),
                        ID = rep(NA,nrow(Homocides)))


DayofYear[,1] <- yday(mdy_hms(Homocides$Date))
DayofYear[,2] <- Homocides$ID

Homocides <- merge(Homocides, DayofYear, by = c("ID"))

#################################### Determine Color for data ####################################

D <- data.frame(color = rep(NA,nrow(Homocides)),
                ID = rep(NA,nrow(Homocides)))

for (r in 1:nrow(Homocides)) {
  if(Homocides[r,3] == 'true'){
    D[r,1] <- 'blue'
    D[r,2] <- Homocides[r,1]
  }
  else {
    D[r,1] <- 'red'
    D[r,2] <- Homocides[r,1]
  }
}
  
Homocides <- merge(Homocides, D, by = c("ID"))

# rm(DayofYear,D,,m,a)
#################################### SECTION TITLE ####################################

url <- 'https://data.cityofchicago.org/api/views/k9xv-yxzs/rows.csv?accessType=DOWNLOAD'
x <- getURL(url)
Homocides <- read.csv(textConnection(x))


library(lubridate)
DayofYear <- data.frame(Day = rep(NA,nrow(Homocides)),
                        ID = rep(NA,nrow(Homocides)))


DayofYear[,1] <- yday(mdy_hms(Homocides$Date))
DayofYear[,2] <- Homocides$ID

Homocides <- merge(Homocides, DayofYear, by = c("ID"))

#################################### Determine Color for data ####################################

D <- data.frame(color = rep(NA,nrow(Homocides)),
                ID = rep(NA,nrow(Homocides)))

for (r in 1:nrow(Homocides)) {
  if(Homocides[r,3] == 'true'){
    D[r,1] <- 'blue'
    D[r,2] <- Homocides[r,1]
  }
  else {
    D[r,1] <- 'red'
    D[r,2] <- Homocides[r,1]
  }
}

Homocides <- merge(Homocides, D, by = c("ID"))
setwd('/Users/matthew/Documents/GitHub/Chicago_shooting/Homocides')
write.csv(Homocides, file = "Homocides.csv")