

runScript <- function(x){
  tryCatch(
    {
      source(x)
    },warning = function(w) { 
      #print("warning")
    }
    ,error = function(e) { 
      print(paste("ERR::", e,"in", x))
    }
  )
}


runScript("blogshare.r")
runScript("insta crawler.r")
runScript("twittercrawler.r")
runScript("pincrawler.r")
runScript("youtubeCount.R")
runScript("facebook.R")