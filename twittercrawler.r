library("twitteR")
library("stringr")
library("jsonlite")

c_key = "aW7HdzD7T8bddh6XZQsF9fV9S"
c_sec = "DW6tly9zOZz1SWdnHF0HmGi7CMwZQf6bbWxFNKH02ge8apjKtC"
a_tok = "9478372-uNoENCNbAcU6x82gji20sOE9orH30ZUfy7e7vKt93c"
a_sec = "Ru7pwWvE2tTEAuGRRSbk8SXcWEjCBCamQ4PrRJLJY"

#setup for TwitteR package
setup_twitter_oauth(consumer_key = c_key, consumer_secret = c_sec, access_token = a_tok, access_secret = a_sec)

# setup for non TwitteR API call here
#Use basic auth
secret <- jsonlite::base64_enc(paste(c_key, c_sec, sep = ":"))
req <- httr::POST("https://api.twitter.com/oauth2/token",
                  httr::add_headers(
                    "Authorization" = paste("Basic", gsub("\n", "", secret)),
                    "Content-Type" = "application/x-www-form-urlencoded;charset=UTF-8"
                  ),
                  body = "grant_type=client_credentials"
);

#Extract the access token
httr::stop_for_status(req, "authenticate with twitter")
token <- paste("Bearer", httr::content(req)$access_token)



calculate_RT = TRUE

if(calculate_RT){
  print("calculating RT reach") 
} else{
  print("not calculating RT reach")
}

rt.df <- data.frame("id"=character())

getRTreach <- function(id)
{
  rt_reach <- 0
  url<- sprintf("https://api.twitter.com/1.1/statuses/retweets/%s.json?count=100", id)
  req <- httr::GET(url, httr::add_headers(Authorization = token))
  json <- httr::content(req, as = "text")
  results <- fromJSON(json)
  rt_reach <- sum(results$user$followers_count)
  #print(sprintf("total RT reach : %d", rt_reach))
  return (rt_reach)
}

#helper function
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

#check current rate limit using this
#twitteR::getCurRateLimitInfo("users")

list.of.urls <- read.csv("twitter_list.csv", stringsAsFactors=FALSE)
report.df <- data.frame(character(), numeric(), numeric(), numeric(), numeric(), character())

if(nrow(list.of.urls) != 0) #only if there is any link to analyze
{
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
        created <- st$created
        
        #RT reach count
        if(calculate_RT)
        {
          reach2 <- getRTreach(status_id)
        }
        
      },
      warning = function(w) { 
        #print("warning")
      },error = function(e) { 
        print(paste("ERR:: ", e, status.url))
      }
    )
    
    row <- data.frame(status.url, fav, rt, reach, reach2, created)
    report.df <- rbind(report.df, row)
    print(paste("fav: ", fav," RT: ", rt, " reach: ", reach, "RT Reach:", reach2))
    
    Sys.sleep(1) #make sure 900 API calls/ 15 mins
  }
}else{
  print("No Twitter links present - exporting empty data frame")
}

rownames(report.df) <- NULL
colnames(report.df) <- c("twitter", "fav", "retweets","reach", "rt reach", "created")
write.csv(report.df, file = "export-twitter.csv", row.names = F)
print("finished exporting results to export-twitter.csv")