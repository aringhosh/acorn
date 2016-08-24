library("httr")

getJSONResponseAsDF <- function(url) {
	response <- GET(url)
	response <- content(response, "text", encoding = "UTF-8")
	data.frame <- fromJSON(response)
	return (data.frame)
}

getKloutID <- function(twitter.user.name) {
	baseurl <- "http://api.klout.com/v2/identity.json/twitter?key=8h2taatuj8rttxbze6knfe4p"
	url = paste(baseurl, "&screenName=", twitter.user.name, sep="")
	klout <- getJSONResponseAsDF(url)
	return (klout)
}


getKloutTopicForId <- function(kloutId) {
	baseurl <- paste("http://api.klout.com/v2/user.json/",kloutId, "/topics?key=8h2taatuj8rttxbze6knfe4p", sep= "")
	topics <- getJSONResponseAsDF(baseurl)
	return (topics)
}

username= "aringhosh"

k <- getKloutID(username)
print( k$id)

t <- getKloutTopicForId(k$id)

for (i in 1:length(t) ) {
	print( t[i][[1]]$displayName )
}
	
