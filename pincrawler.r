library("httr")
library("jsonlite")
library("stringr")

#CONSTANTS
startElement <- "\"resourceDataCache\": \\[\\],"
endElement <- "\"canDebug\""
pin.access.token <- "ATBrNxK1vemReIfXbUuWkYGssmS2FINNAdAG-39DQY5lZeBE4gAAAAA"
pin.api.base.url <- "https://api.pinterest.com/v1/pins"
user.api.base.url <- "https://api.pinterest.com/v1/users"
board.api.base.url <- "https://api.pinterest.com/v1/boards"

#setup output df
report.df <- data.frame(character(), character(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric())

#helper function
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
get.pin.id <- function(x)
{
  splits <- strsplit(x, "/")
  return( splits[[1]] [length(splits[[1]])] )
}

get.source <- function(x)
{
  source <- GET(x)
  return( content(source, "text", encoding = "UTF-8") )
}

list.of.urls <- read.csv("pins_list.csv", stringsAsFactors=FALSE)

for(i in 1:nrow(list.of.urls))
{
  #read from input csv file
  print(paste("fetching",i,"of",nrow(list.of.urls)))
  url <- trim(list.of.urls[i,])
  #first make sure that the last char in url is /
  if(!endsWith(url, "/")) url <- sprintf("%s%s", url, "/")
  pin.id <- get.pin.id(url)
  
  #pin calc
  pin.api.count.api <- sprintf("%s/%s/?fields=counts,creator&access_token=%s", pin.api.base.url, pin.id, pin.access.token)
  json.resp <- get.source(pin.api.count.api)
  result.df <- fromJSON(json.resp)
  pin.likes <- result.df$data$counts$likes
  pin.comments <- result.df$data$counts$comments
  pin.repins <- result.df$data$counts$repins
  pin.user.id <- result.df$data$creator$id
  
  #print(sprintf("like -%d comment -%d repins -%d", pin.likes, pin.comments, pin.repins))
  
  #user calc
  user.api.count.api <- sprintf("%s/%s/?fields=username,counts&access_token=%s", user.api.base.url, pin.user.id, pin.access.token)
  json.resp <- get.source(user.api.count.api)
  result.df <- fromJSON(json.resp)
  user.followers <- result.df$data$counts$followers
  user.username <- result.df$data$username
  
  #print(sprintf("username %s followers %d", user.username, user.followers))
  
  #repin calc
  repin.url <- sprintf("%s%s",url,"repins/") #assuming the url ends with /
  r <- get.source(repin.url)
  resourceDataCache.json <- strsplit(r, startElement)
  resourceDataCache.json <- strsplit(resourceDataCache.json[[1]][2], endElement)
  resourceDataCache.json <- trim(resourceDataCache.json[[1]][1]) #still start with tree : & ends with ,
  resourceDataCache.json <- substr(resourceDataCache.json,nchar("\"\"tree\": "), nchar(resourceDataCache.json)-1)
  boards <- fromJSON(resourceDataCache.json)$data
  
  total.repin.follower <- 0
  repins.count <- 0
  
  if(length(boards) == 0)
  {
    print("no repin boards found!")
  }
  else#(length(boards) > 0)
  {
    cat( sprintf(" found %d repinned boards", nrow(boards)) )
    repins.count <- nrow(boards)
    
    for(j in 1:nrow(boards))
    {
      #board.id <- "60446888687716253"
      board.id <- boards$id[j]
      board.count.url <- sprintf("%s/%s/?fields=counts&access_token=%s", board.api.base.url,board.id,pin.access.token)
      response <- GET(board.count.url)
      response <- content(response, "text", encoding = "UTF-8")
      api.response <- fromJSON(response)
      
      #print(api.response$data$counts$followers)
      total.repin.follower <- total.repin.follower + api.response$data$counts$followers
    }
    
    print(sprintf("finished all repin boards. total repin follower is %d", total.repin.follower))
  }
  
  #prepare row to export
  total.followers <- user.followers+total.repin.follower
  row <- data.frame(as.character(user.username), as.character(url), pin.likes, pin.comments, pin.repins, user.followers, total.repin.follower, total.followers, repins.count)
  report.df <- rbind(report.df, row)
}

#write output csv ; export
colnames(report.df) <- c("username", "url", "likes", "comments", "repins", "user followers", "repin followers", "total followers", "repin boards")
write.csv(report.df, file = "export-pinterest.csv", row.names = F)
print("FINISHED! Exported to export-pinterest.csv")

#example urls
#url <- "https://www.pinterest.com/pin/60446819978407551/repins/" #1 repin
#url<- "https://www.pinterest.com/pin/81768549464921980/repins/" # 16 repins
#url <- "https://www.pinterest.com/pin/3659243426573151/repins/" # 0 repins


