library("httr")
library("jsonlite")

link = "https://www.instagram.com/tiamowry/media/"
source <- GET(link)
source <- content(source, "text", encoding = "UTF-8")
result.df <- fromJSON(source)

username <- result.df$items$user$username
link <- result.df$items$link
commentCount <- result.df$items$comments$count
likeCount <- result.df$items$likes$count
createdTime <- result.df$items$created_time
createdTime <- as.POSIXct(as.integer(createdTime), origin="1970-01-01" )

df <- data.frame(username, link, commentCount, likeCount, createdTime)
write.csv(df, file = "export-instagram.csv", row.names = F)
