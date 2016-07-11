library("httr")
library("jsonlite")
library("stringr")

list.of.urls <- read.csv("instagram_list.csv")
report.df <- data.frame(numeric(), numeric(), logical() , numeric(), numeric())

for(i in 1:nrow(list.of.urls))
{
	url <- list.of.urls[i,]
	#print(url)
	instaPostDF <- crawlMyInsta(url)

	comment_count <- as.numeric(instaPostDF$entry_data$PostPage$media$comments$count)
	likes_count <- as.numeric(instaPostDF$entry_data$PostPage$media$likes$count)
	#print(comment_count)

	video_views = 0
	is_video <- as.logical(instaPostDF$entry_data$PostPage$media$is_video)
	
	if(!is_video)
	{
		
	}
	else
	{
		video_views <- as.numeric(df$entry_data$PostPage$media$video_views)
	}

	username <- as.character(instaPostDF$entry_data$PostPage$media$owner$username)

	#create the profile URL
	instaProfileURL <- paste("https://www.instagram.com/",username, sep="")
	profileDF <- crawlMyInsta(instaProfileURL)
	followed_by <- as.numeric(profileDF$entry_data$ProfilePage$user$followed_by$count)
	#print(followed_by)

	row <- c(comment_count, likes_count, is_video, video_views, followed_by)
	print(row)
	report.df <- rbind(report.df, row)
}

colnames(report.df) <- c("Comments", "Likes","is_video", "Video Views", "Reach")
write.csv(report.df, file = "export-instagram.csv", row.names = F)


crawlMyInsta <- function(url)
{
	source <- GET(toString(url))
	r <- content(source, "text", encoding = "UTF-8")
	spilit <- strsplit(r, "<script type=\"text/javascript\">window._sharedData =")
	data <- spilit[[1]][2] #get second element
	s <- strsplit(data, "</script")
	data <- s[[1]][1]
	data <- substr(data, 1, str_length(data)-1) #remove the trailing ;
	data.frame <- fromJSON(data)
	return (data.frame)
}