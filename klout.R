library("httr")
library("jsonlite")

getJSONResponseAsDF <- function(url) {
	response <- GET(url)
	if(response$status_code != 404)
	{
		response <- content(response, "text", encoding = "UTF-8")
		data.frame <- fromJSON(response)
		return (data.frame)
	}
	else
		return (NULL)
	
}

getKloutID <- function(twitter.user.name) {
	baseurl <- "http://api.klout.com/v2/identity.json/twitter?key=8h2taatuj8rttxbze6knfe4p"
	url = paste(baseurl, "&screenName=", twitter.user.name, sep="")
	#print(url)
	klout <- getJSONResponseAsDF(url)
	return (klout)
}


getKloutTopicForId <- function(kloutId) {
	baseurl <- paste("http://api.klout.com/v2/user.json/",kloutId, "/topics?key=8h2taatuj8rttxbze6knfe4p", sep= "")
	#print(baseurl)
	topics <- getJSONResponseAsDF(baseurl)
	return (topics)
}

fetchMyTopics <- function(username)
{
	k <- getKloutID(username)
	if(is.null(k))
	{
		return (k)
	}
	else
	{
		print( k$id)

		t <- getKloutTopicForId(k$id)
		my.topics <- username
		for (i in 1:5) {
			#print(t[i][[1]]["displayName"])
			my.topics <- c(my.topics, t[2][[1]][i])
		}
		#print(my.topics)
		return(my.topics)
	}
	
}

main <- function(){
  for(i in 1:nrow(usernames))
  {
    tryCatch(
      {
        username <- usernames[i,]
        print(paste("fetching",i,"of",nrow(usernames), " = ", username))
        my.topics <- fetchMyTopics(username)
        if(is.null(my.topics))
        {
          print("ERR")
          #my.topics <- c(username, "NA", "NA", "NA", "NA", "NA")
          next
        }
        
        report.df <- rbind(report.df, my.topics)
        #print(ncol(my.topics))
        #print(report.df)
      },
      warning = function(w) { 
        print(w)
      },
      error = function(e) { 
        print(e)
      }
    )
    
    Sys.sleep(1)
  }
  
  return(report.df)
}

usernames <- read.csv("t_usernames.csv", stringsAsFactors=FALSE)
report.df <- NULL #data.frame(character(),character(),character(),character(),character(),)

df <- main()
colnames(df) <- c("Username", "topic1", "topic2","topic3", "topic4", "topic5")
write.csv(df, file = "export-topics.csv", row.names = F)

