library("twitteR")
library("stringr")

c_key = "aW7HdzD7T8bddh6XZQsF9fV9S"
c_sec = "DW6tly9zOZz1SWdnHF0HmGi7CMwZQf6bbWxFNKH02ge8apjKtC"
a_tok = "9478372-uNoENCNbAcU6x82gji20sOE9orH30ZUfy7e7vKt93c"
a_sec = "Ru7pwWvE2tTEAuGRRSbk8SXcWEjCBCamQ4PrRJLJY"

setup_twitter_oauth(consumer_key = c_key, consumer_secret = c_sec, access_token = a_tok, access_secret = a_sec)

list.of.urls <- read.csv("twitter_list.csv", stringsAsFactors=FALSE)
report.df <- data.frame(character(), numeric())

for (i in 1:nrow(list.of.urls))
{
  fav <- 0
  rt <- 0
  reach <- 0

  screenName<- list.of.urls[i,1]
  print(paste(i, " of ", nrow(list.of.urls)))
  #print( paste("url: ", status.url))

  tryCatch(
    {
      u <- getUser(screenName)
      reach <- u$followersCount
      #retweeters(st$getId(), n=100)
    },
    warning = function(w) { 
        #print("warning")
    }
      ,error = function(e) { 
        print(paste("ERR:: ", status.url))
      }
    )

  row <- data.frame(status.url , reach)
  report.df <- rbind(report.df, row)
  print(paste(" reach: ", reach))
}

rownames(report.df) <- NULL
colnames(report.df) <- c("screenName","reach")
write.csv(report.df, file = "export-twitter.csv", row.names = F)
print("finished exporting results to export-twitter.csv")