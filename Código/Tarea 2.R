rm(list=ls())
#Package Install and Load
suppressMessages({
  if(!require("pacman")) install.packages("pacman")
  pacman::p_load("ggmap", "rgdal", "rgeos", "maptools", "dplyr", "tidyr", "tmap")
})

#Set path working directory
setwd("C:/Users/Joaquin/Desktop/UdeSA/Maestría en Economía/Herramientas Computacionales Para Investigación/Data Visualization (R)/Tarea-5")
#Check working directory
getwd()

#Load the data files
#polygons
lnd <- readOGR(dsn = "Inputs/london_sport.shp")
#crime
crime_data <- read.csv("Inputs/mps-recordedcrime-borough.csv",
                       stringsAsFactors = FALSE)


# Extract "Theft & Handling" crimes and save
crime_theft <- crime_data[crime_data$CrimeType == "Theft & Handling", ]

# Calculate the sum of the crime count for each district, save result
crime_ag <- aggregate(CrimeCount ~ Borough, FUN = sum, data = crime_theft)

# Compare the name column in lnd to Borough column in crime_ag to see which rows match.
lnd$name %in% crime_ag$Borough
# Return rows which do not match
lnd$name[!lnd$name %in% crime_ag$Borough]

# join
lnd@data <- left_join(lnd@data, crime_ag, by = c('name' = 'Borough'))

#Map with tmap (we dont use qtm, we use other functions from tmap package)
thieftm<-tm_shape(lnd) + 
  tm_fill("CrimeCount", title = "Counts 04/2011-03/2013")+
  tm_borders(alpha = 0.1,lwd = 1) +
  tm_layout(main.title = "Theft/Handouts London",
            legend.position = c("right", "bottom"),
            legend.outside = TRUE)
tmap_save(thieftm,"Outputs/thieftm.png",width=16, height=10,units = "cm")

## supplying data as data.frame
lnd_f <- broom::tidy(lnd)

# recovering attributes
lnd$id <- row.names(lnd) # allocate an id variable to the sp data
lnd_f <- left_join(lnd_f, lnd@data) # join the data


#Map with ggplot
## ----"Map of Lond Sports Participation"-------------------------------
thiefgg<- ggplot(lnd_f, aes(long, lat)) +
  geom_polygon(aes(group = name, fill = CrimeCount),colour = "black", 
               size = 0.15) + coord_equal() +
  labs(x = "Easting (m)", y = "Northing (m)",
       fill = "Counts",
       subtitle = "04/2011-03/2013",
       title = "Theft/Handouts London") +
scale_fill_gradient(low = "#fff7bc", high = "#d95f0e")+
  theme_minimal()
ggsave(filename="Outputs/thiefgg.png",plot=thiefgg,width=16, height=10,units = "cm")

