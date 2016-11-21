df <- read.csv('links.csv', stringsAsFactors = F)

fb.pattern <- ".facebook|fb.co."
insta.pattern = ".instagram."
twitter.pattern = ".twitter."
pin.pattern = ".pinterest|pin/."
youtube.pattern = ".youtube|tu.be/."

fb.df <- data.frame(link= character())
insta.df <- data.frame(link= character())
twitter.df <- data.frame(link= character())
pin.df <- data.frame(link= character())
youtube.df <- data.frame(link= character())
blog.df <- data.frame(link= character())

#helper function
trim <- function (x) gsub("^\\s+|\\s+$", "", x)

for (i in 1:nrow(df))
{
  
  link <- trim(df[i,])
  #print(paste("fetching",i,"of",nrow(df)))
  
  #check for FB
  if (  length(grep(fb.pattern, link, ignore.case = T)) > 0)
  {
    fb.df <- rbind(fb.df, data.frame(link))
  }
  #check for INSTA
  else if (  length(grep(insta.pattern, link, ignore.case = T)) > 0)
  {
    insta.df <- rbind(insta.df, data.frame(link))
  }
  #check for TWITTER
  else if (  length(grep(twitter.pattern, link, ignore.case = T)) > 0)
  {
    twitter.df <- rbind(twitter.df, data.frame(link))
  }
  #check for PINTEREST
  else if (  length(grep(pin.pattern, link, ignore.case = T)) > 0)
  {
    pin.df <- rbind(pin.df, data.frame(link))
  }
  #check for YOUTUBE 
  else if (  length(grep(youtube.pattern, link, ignore.case = T)) > 0)
  {
    youtube.df <- rbind(youtube.df, data.frame(link))
  }
  #check for BLOG
  else
  {
    blog.df <- rbind(blog.df, data.frame(link))
  }
  
}

#write into csvs
write.csv(fb.df, file = "fb_list.csv", row.names = F)
write.csv(insta.df, file = "instagram_list.csv", row.names = F)
write.csv(twitter.df, file = "twitter_list.csv", row.names = F)
write.csv(pin.df, file = "pins_list.csv", row.names = F)
write.csv(youtube.df, file = "youtube-list.csv", row.names = F)
write.csv(blog.df, file = "bloglist.csv", row.names = F)

print(sprintf("facebook : %d", nrow(fb.df)))
print(sprintf("instagram : %d", nrow(insta.df)))
print(sprintf("pinterest : %d", nrow(pin.df)))
print(sprintf("twitter : %d", nrow(twitter.df)))
print(sprintf("youtube : %d", nrow(youtube.df)))
print(sprintf("blog : %d", nrow(blog.df)))
print("finished exporting to input csv")
