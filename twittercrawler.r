library("twitteR")
library("stringr")

c_key = "aW7HdzD7T8bddh6XZQsF9fV9S"
c_sec = "DW6tly9zOZz1SWdnHF0HmGi7CMwZQf6bbWxFNKH02ge8apjKtC"
a_tok = "9478372-uNoENCNbAcU6x82gji20sOE9orH30ZUfy7e7vKt93c"
a_sec = "Ru7pwWvE2tTEAuGRRSbk8SXcWEjCBCamQ4PrRJLJY"

setup_twitter_oauth(consumer_key = c_key, consumer_secret = c_sec, access_token = a_tok, access_secret = a_sec)

calculate_RT = FALSE

if(calculate_RT){
  print("calculating RT reach") 
} else{
  print("not calculating RT reach")
}


getRTreach <- function(st)
{
  rt_reach <- 0

  rts <- retweeters(st$getId(), n=100)
  print(rts)
  rt_count <- length(rts)
  print(sprintf("%d RTs", rt_count))
        
        for(j in 1:rt_count)
        {
          tryCatch(
          {
            print(paste("RT:: ",j, "of", rt_count))
            userreach <- getUser(rts[j])$followersCount
            #print(sprintf(" reach %d", userreach))
            rt_reach <- rt_reach + userreach
          },warning = function(w) { 
            #print("warning")
          }
          ,error = function(e) { 
            print(paste("ERR:: ", rts[j]))
            #print(rts)
          }
          )
        }

  print(sprintf("total RT reach : %d", rt_reach))
  return (rt_reach)
}

#helper function
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

list.of.urls <- read.csv("twitter_list.csv", stringsAsFactors=FALSE)
report.df <- data.frame(character(), numeric(), numeric(), numeric(), numeric())

for (i in 1:nrow(list.of.urls))
{
  fav <- 0
  rt <- 0
  reach <- 0
  reach2 <- 0

  status.url<- trim(list.of.urls[i,1])
  print(paste("TWIT", i, " of ", nrow(list.of.urls)))
  #print( paste("url: ", status.url))

  tryCatch(
    {
      split <- str_split(status.url,"/")
      status_id <- split[[1]][length(split[[1]])]
      st <- showStatus(status_id)
      fav <- st$favoriteCount
      rt <- st$retweetCount
      u <- getUser(st$screenName)
      reach <- u$followersCount
      
      #RT reach count
      if(calculate_RT)
      {
        reach2 <- getRTreach(st)
      }
      
    },
    warning = function(w) { 
        #print("warning")
    },error = function(e) { 
        print(paste("ERR:: ", status.url))
      }
    )

  row <- data.frame(status.url, fav, rt, reach, reach2)
  report.df <- rbind(report.df, row)
  print(paste("fav: ", fav," RT: ", rt, " reach: ", reach, "RT Reach:", reach2))
}

rownames(report.df) <- NULL
colnames(report.df) <- c("twitter", "fav", "retweets","reach", "rt reach")
write.csv(report.df, file = "export-twitter.csv", row.names = F)
print("finished exporting results to export-twitter.csv")