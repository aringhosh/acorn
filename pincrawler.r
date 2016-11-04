library("httr")
library("jsonlite")
library("stringr")

#CONSTANTS
startElement <- "\"resourceDataCache\": \\[\\],"
endElement <- "\"canDebug\""
pin.access.token <- "ATBrNxK1vemReIfXbUuWkYGssmS2FINNAdAG-39DQY5lZeBE4gAAAAA"
pin.api.base.url <- "https://api.pinterest.com/v1/boards"

#output df
report.df <- data.frame(character(), numeric(), numeric())

#helper function
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

list.of.urls <- read.csv("pins_list.csv", stringsAsFactors=FALSE)

for(i in 1:nrow(list.of.urls))
{
  #read from input csv file
  print(paste("fetching",i,"of",nrow(list.of.urls)))
  url <- trim(list.of.urls[i,])
  repin.url <- sprintf("%s%s",url,"repins/") #assuming the url ends with /
  
  source <- GET(repin.url)
  r <- content(source, "text", encoding = "UTF-8")
  
  resourceDataCache.json <- strsplit(r, startElement)
  resourceDataCache.json <- strsplit(resourceDataCache.json[[1]][2], endElement)
  resourceDataCache.json <- trim(resourceDataCache.json[[1]][1]) #still start with tree : & ends with ,
  resourceDataCache.json <- substr(resourceDataCache.json,nchar("\"\"tree\": "), nchar(resourceDataCache.json)-1)
  #json parsing
  boards <- fromJSON(resourceDataCache.json)$data
  
  total.repin.follower <- 0
  repins.count <- 0
  
  if(length(boards) == 0)
  {
    print("no repin board found!")
  }
  else#(length(boards) > 0)
  {
    print( sprintf("found %d repinned boards", nrow(boards)) )
    repins.count <- nrow(boards)
    
    for(j in 1:nrow(boards))
    {
      #board.id <- "60446888687716253"
      board.id <- boards$id[j]
      board.count.url <- sprintf("%s/%s/?fields=counts&access_token=%s", pin.api.base.url,board.id,pin.access.token)
      response <- GET(board.count.url)
      response <- content(response, "text", encoding = "UTF-8")
      api.response <- fromJSON(response)
      
      #print(api.response$data$counts$followers)
      total.repin.follower <- total.repin.follower + api.response$data$counts$followers
    }
    
    print(sprintf("finished all repin boards. total repin follower is %d", total.repin.follower))
  }
  
  #prepare row to export
  row <- data.frame(as.character(url),total.repin.follower, repins.count)
  report.df <- rbind(report.df, row)
}

#write output csv ; export
colnames(report.df) <- c("url", "repin follwers", "repin boards")
write.csv(report.df, file = "export-pinterest.csv", row.names = F)
print("FINISHED! Exported to export-pinterest.csv")

#example urls
#url <- "https://www.pinterest.com/pin/60446819978407551/repins/" #1 repin
#url<- "https://www.pinterest.com/pin/81768549464921980/repins/" # 16 repins
#url <- "https://www.pinterest.com/pin/3659243426573151/repins/" # 0 repins


