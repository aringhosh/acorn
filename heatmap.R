# Tartu housing density map ###
library(ggplot2)
library(ggmap)

data <- read.csv("locations.csv")

# change parameters
tartu_map_g_str <- get_map(location="Salina,KS", zoom = 4, maptype = "terrain")
map <- ggmap(tartu_map_g_str, extent='device') + geom_density2d(data=data, aes(x=lon, y=lat), size=.2, colour = "black") + stat_density2d(data=data, aes(x=lon, y=lat,  fill = ..level.., alpha = ..level..), size = 0.01, geom = 'polygon')+ scale_fill_gradient(low = "blue", high = "red") + scale_alpha(range = c(0, 0.30), guide = FALSE)
map

#pin method 1
# location <-geocode("1410 North Scott Street , Apt 645ArlingtonVirginia")
# lon <- location['lon']
# lat <- location['lat']
# map <- map + geom_point(aes(x = lon, y = lat, size = 2), data = location, alpha = .5)

#pin method 2
# #Using GGPLOT, plot the Base World Map
# mp <- NULL
# mapWorld <- borders("world", colour="gray50", fill="gray50") # create a layer of borders
# mp <- ggplot() +   mapWorld
# 
# #Now Layer the cities on top
# mp <- mp+ geom_point(aes(x=visit.x, y=visit.y) ,color="blue", size=3) 
# mp

#summarize
#library('dplyr')
#name <- group_by (data, lat,lon)
#p <- summarise(name, n())