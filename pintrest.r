library("httr")
library("jsonlite")
library("stringr")

trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#example urls
url <- "https://www.pinterest.com/pin/60446819978407551/repins/" #1 repin
url<- "https://www.pinterest.com/pin/81768549464921980/repins/" # 16 repins
url <- "https://www.pinterest.com/pin/3659243426573151/repins/" # 0 repins

source <- GET(url)
r <- content(source, "text", encoding = "UTF-8")

startElement <- "\"resourceDataCache\": \\[\\],"
endElement <- "\"canDebug\""

json <- strsplit(r, startElement)
json <- strsplit(json[[1]][2], endElement)
json2 <- trim(json[[1]][1]) #still start with tree : & ends with ,
json2 <- substr(json2,nchar("\"\"tree\": "), nchar(json2)-1)

#json parsing
boards <- fromJSON(json2)$data
board.id <- "60446888687716253"

#pinterest API

pin.access.token <- "ATBrNxK1vemReIfXbUuWkYGssmS2FINNAdAG-39DQY5lZeBE4gAAAAA"
pin.api.base.url <- "https://api.pinterest.com/v1/boards"
board.count.url <- sprintf("%s/%s/?fields=counts&access_token=%s", pin.api.base.url,board.id,pin.access.token)
response <- GET(board.count.url)
response <- content(response, "text", encoding = "UTF-8")
api.response <- fromJSON(response)
api.response$data$counts$followers
