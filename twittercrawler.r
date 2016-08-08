library("httr")
library("stringr")

#source <- GET("https://twitter.com/mandipie4u/status/743951935703678978")
source <- GET("https://twitter.com/JaMonkey/status/751862371195420672")
r <- content(source, "text", encoding = "UTF-8")

text <- "data-activity-popup-title=\""
split <- strsplit(r, text)

loop <- length(split[[1]])
likeCount <- 0
rtCount <- 0

while(loop > 1)
{
  data <- split[[1]][loop]
  endtag <- "\">"
  output <- str_split(data, endtag)
  result <- output[[1]][1]
  loop <- loop - 1
  
  #like
  count <- strsplit(result, " like")
  
  if (length(count[[1]]) > 1)
  {
    likeCount <- as.integer(count[[1]][1])
    next
  }
  
  #rt
  count <- strsplit(result, " retweet")
  if (length(count[[1]]) > 1)
  {
    rtCount <- as.integer(count[[1]][1])
  }
}

print(likeCount)
print(rtCount)