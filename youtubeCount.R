library(httr)
library(jsonlite)

df <- read.csv('youtube-list.csv')
report.df <- data.frame(character(), numeric(), numeric(), numeric(), numeric())

apikey <- "AIzaSyAvAQVvBy4H--aUNquBgzuOqvljQ4HPewg"
url <- paste("https://www.googleapis.com/youtube/v3/videos?key=",apikey, sep="")
url_channels <- paste("https://www.googleapis.com/youtube/v3/channels?key=",apikey, sep="")

for (i in 1:nrow(df))
{
	youtubeURL <- df[i,]
	parsedURL <- parse_url(youtubeURL)
	videoid <- NULL
	print(paste("fetching",i,"of",nrow(df)))

	if(!is.null(parsedURL$query$v))
	{
		videoid <- parsedURL$query$v
	}
	else if(!is.null(parsedURL$path))
	{
		videoid <- parsedURL$path
	}
	else
	{
		videoid <- NULL	
	}

	if(!is.null(videoid))
	{
		#id found, valid url
		
		#part snippet (video)
		part <- "snippet"
		callURL <- paste(url,"&part=",part,"&id=",videoid, sep="")
		r1 <- GET(callURL)
		jsontext <- content(r1, "text", encoding = "UTF-8")
		parsedDataframe <- fromJSON(jsontext)

		channelId <- parsedDataframe$items$snippet$channelId
		title <- parsedDataframe$items$snippet$title
		description <- parsedDataframe$items$snippet$description

		#print(channelId)
		#print(title)
		#print(description)

		#part statistics (video)
		part <- "statistics"
		callURL <- paste(url,"&part=",part,"&id=",videoid, sep="")
		r1 <- GET(callURL)
		jsontext <- content(r1, "text", encoding = "UTF-8")
		parsedDataframe <- fromJSON(jsontext)

		viewCount <- parsedDataframe$items$statistics$viewCount
		if (is.null(viewCount)) viewCount = 0
		likeCount <- parsedDataframe$items$statistics$likeCount
		if (is.null(likeCount)) likeCount = 0
		commentCount <- parsedDataframe$items$statistics$commentCount
		if (is.null(commentCount)) commentCount = 0

		#part statistic- (for channel)
		part <- "statistics"
		callURL <- paste(url_channels,"&part=",part,"&id=",channelId, sep="")
		r1 <- GET(callURL)
		jsontext <- content(r1, "text", encoding = "UTF-8")
		parsedDataframe <- fromJSON(jsontext)

		subscriberCount <- parsedDataframe$items$statistics$subscriberCount
		#print(subscriberCount)

		# store results
		row <- data.frame(as.character(youtubeURL), as.numeric(viewCount),as.numeric(likeCount), as.numeric(subscriberCount), as.numeric(commentCount))
		#print(row)
		report.df <- rbind(report.df, row)
	}
	else
	{
		#invalid id, next
	}
	
	#print(videoid)
	
}

rownames(report.df) <- NULL
colnames(report.df) <- c("url", "view", "like", "reach", "comments")
write.csv(report.df, file = "export-youtube.csv", row.names = F)
print("exported to export-youtube.csv")
