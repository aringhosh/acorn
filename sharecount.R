library(httr)
library(jsonlite)

df <- read.csv('bloglist.csv')
report.df <- data.frame( numeric(), numeric(), numeric() , numeric(), numeric())

url <- "https://free.sharedcount.com/url?"
apikey <- "11365db3eb1e7220a8d549fcf8161b1d44b4b16e"

for (i in 1:nrow(df))
{
	blogurl <- df[i,]
	callURL <- paste(url,"apikey=",apikey,"&url=",blogurl, sep="")
	
	print(blogurl)

	r1 <- GET(callURL)
	jsontext <- content(r1, "text", encoding = "UTF-8")
	parsedDataframe1 <- fromJSON(jsontext)
	
	fb_total <- parsedDataframe1$Facebook$total_count
	pintrest_total <- parsedDataframe1$Pinterest
	li_total <- parsedDataframe1$LinkedIn
	gplus_total <- parsedDataframe1$GooglePlusOne

	if(is.null(fb_total)) fb_total <- 0
	if(is.null(pintrest_total)) pintrest_total <- 0
	if(is.null(li_total)) li_total <- 0
	if(is.null(gplus_total)) gplus_total <- 0
	
	#print(paste("Facebook",fb_total))
	#print(paste("Pintrest",pintrest_total))
	#print(paste("LinkedIn",li_total))


	#stumbleUpon
	sucallurl <- paste("http://www.stumbleupon.com/services/1.01/badge.getinfo?url=",blogurl, sep="")
	r2 <- GET(sucallurl)
	jsontext <- content(r2, "text", encoding = "UTF-8")
	parsedDataframe <- fromJSON(jsontext)

	su_views <- parsedDataframe$result$views
	if(is.null(su_views)) su_views <- 0
	#print(paste("StumbleUpon",su_views))

	row <- c(as.numeric(fb_total),as.numeric(pintrest_total),as.numeric(li_total),as.numeric(su_views), as.numeric(gplus_total))
	print(row)
	report.df <- rbind(report.df, row)
}

rownames(report.df) <- NULL
colnames(report.df) <- c("Facebook", "Pinterest", "LinkedIn","Stumble Upon", "Google+")
write.csv(report.df, file = "social share.csv", row.names = F)
