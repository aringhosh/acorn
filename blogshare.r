library(httr)
library(jsonlite)


df <- read.csv('bloglist.csv')
report.df <- data.frame( character(), numeric(), numeric(), numeric(), numeric())

url <- "https://count.donreach.com/"

if(nrow(df) != 0) #only if there is any link to analyze
{
  for (i in 1:nrow(df))
  {
    blogurl <- df[i,]
    print(paste("BLOG fetching",i,"of",nrow(df)))
    
    
    #stumbleUpon
    sucallurl <- paste("http://www.stumbleupon.com/services/1.01/badge.getinfo?url=",blogurl, sep="")
    r2 <- GET(sucallurl)
    jsontext <- content(r2, "text", encoding = "UTF-8")
    parsedDataframe <- fromJSON(jsontext)
    
    su_views <- parsedDataframe$result$views
    if(is.null(su_views)) su_views <- 0
    #print(paste("StumbleUpon",su_views))
    su_views <- as.numeric(su_views)
    
    #fb
    fburl <- sprintf("http://graph.facebook.com/?id=%s",blogurl)
    r2 <- GET(fburl)
    jsontext <- content(r2, "text", encoding = "UTF-8")
    parsedDataframe <- fromJSON(jsontext)
    fb_share_count <- parsedDataframe$share$share_count
    if(is.null(fb_share_count)) fb_share_count <- 0
    fb_share_count <- as.numeric(fb_share_count)
    
    #pin
    pinurl <- sprintf("http://api.pinterest.com/v1/urls/count.json?url=%s",blogurl)
    r2 <- GET(pinurl)
    jsontext <- content(r2, "text", encoding = "UTF-8")
    jsontext <- sub('[^\\{]*', '', jsontext) #output is jsonp format # remove function name and opening parenthesis
    jsontext <- sub('\\)$', '', jsontext) # remove closing parenthesis
    parsedDataframe <- fromJSON(jsontext)
    pin_share_count <- parsedDataframe$count
    if(is.null(pin_share_count)) pin_share_count <- 0
    pin_share_count <- as.numeric(pin_share_count)
    
    #google TBD
    
    total <- su_views + fb_share_count + pin_share_count
    row <- data.frame(as.character(blogurl), su_views, fb_share_count, pin_share_count, total)
    report.df <- rbind(report.df, row)
    
    
  }
}else{
  print("No BLOG links present - exporting empty data frame")
}
rownames(report.df) <- NULL
colnames(report.df) <- c("Blog", "SU", "FB", "PIN", "TOTAL(sum)")
write.csv(report.df, file = "export-blog.csv", row.names = F)
print(report.df[2:5])
print("Exported to export-blog.csv")
