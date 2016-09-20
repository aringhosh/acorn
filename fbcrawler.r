library("rjson")
library("httr")


report.df <- data.frame(character(), character(), numeric(), numeric(), numeric(), numeric(), logical())

api_url <- "https://api.datarank.com/facebook/post/stats"
auth.id <- "08fde929d0b62c4f2c58cf53801f42d4ab9a49d11dd3d95c6252db1b31a24e56"

list.of.urls <- read.csv("fb_list.csv", stringsAsFactors=FALSE)

error.count <- 0

for(i in 1:nrow(list.of.urls))
{
	print(paste("fetching",i,"/",nrow(list.of.urls)))
	fb.post.url <- list.of.urls[i,]

	raw.body <- list(link=c(fb.post.url))
	request.body <- toJSON(raw.body) #convert plain text into JSON text for a key-value pair

	r <- POST(url = api_url, add_headers(Authorization = auth.id), content_type_json(), accept("application/vnd.datarank.v1+json"), body = request.body)

	text <- content(r, "text", encoding = "UTF-8") 
	data.frame <- fromJSON(text)

	if(FALSE == as.logical(data.frame$processedCorrectly))
	{
		print(paste("verify url: ", as.character(data.frame$url)))
		print(paste("probable reason: ", as.character(data.frame$id) ))

		error.count <- error.count + 1
	}

	data.frame <- data.frame(as.character(data.frame$url), as.character(data.frame$id),
	as.numeric(data.frame$pageLikeCount), as.numeric(data.frame$likeCount),
	as.numeric(data.frame$shareCount), as.numeric(data.frame$commentCount), as.logical(data.frame$processedCorrectly) ) 
	report.df <- rbind(report.df, data.frame)

}

colnames(report.df) <- c("url", "id", "reach","likeCount", "shareCount", "commentCount", "processedCorrectly")
write.csv(report.df, file = "export-fb.csv", row.names = F)
print("FINISHED! Exported to export-fb.csv")

if(error.count > 0 )
	print(paste ("Total Error/Warnings =  ", error.count))