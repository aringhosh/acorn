#ref: https://gist.github.com/jonathanmoore/2640302
library(httr)
library(jsonlite)

df <- read.csv('bloglist.csv')
report.df <- data.frame( character(), numeric(), numeric(), numeric() , numeric(), numeric(), numeric())

url <- "https://count.donreach.com/"

for (i in 1:nrow(df))
{
	blogurl <- df[i,]
	print(paste("fetching",i,"of",nrow(df)))


	#stumbleUpon
	sucallurl <- paste("http://www.stumbleupon.com/services/1.01/badge.getinfo?url=",blogurl, sep="")
	r2 <- GET(sucallurl)
	jsontext <- content(r2, "text", encoding = "UTF-8")
	parsedDataframe <- fromJSON(jsontext)

	su_views <- parsedDataframe$result$views
	if(is.null(su_views)) su_views <- 0
	su_views <- as.numeric(su_views)
	#print(paste("StumbleUpon",su_views))

	#donreach
	
	callURL <- paste(url,"?url=",blogurl, sep="")

	r1 <- GET(callURL)
	jsontext <- content(r1, "text", encoding = "UTF-8")
	parsedDataframe2 <- fromJSON(jsontext)

	fb_total <- parsedDataframe2$shares$facebook
	gplus_total <- parsedDataframe2$shares$google
	li_total <- parsedDataframe2$shares$linkedin
	pintrest_total <- parsedDataframe2$shares$pinterest

	if(is.null(fb_total)) fb_total <- 0
	if(is.null(pintrest_total)) pintrest_total <- 0
	if(is.null(li_total)) li_total <- 0
	if(is.null(gplus_total)) gplus_total <- 0

	t.social_share <- fb_total+pintrest_total+li_total+su_views+gplus_total

	row <- data.frame(as.character(blogurl), as.numeric(fb_total),as.numeric(pintrest_total),as.numeric(li_total),as.numeric(su_views), as.numeric(gplus_total), t.social_share)
	report.df <- rbind(report.df, row)
}	#print(row)

rownames(report.df) <- NULL
colnames(report.df) <- c("Blog", "Facebook", "Pinterest", "LinkedIn","Stumble Upon", "Google+", "total_social_share")
write.csv(report.df, file = "export-blog.csv", row.names = F)
print(report.df[2:6])
print("Exported to export-blog.csv")

