library(httr)

graph_api_base <-"https://graph.facebook.com/v2.8"
access_token <- "EAACEdEose0cBAI0iCAK1Ut66M4gPMVhBv670RJvt71SBX7nk3qjwBk3Wg1JeAPuCMvfqRb61pwjHuVLqJZAVzS8yUPjKq7ZBAqKyQ6ZAe4SowBkZCM6rxZAAx6P0vXMHM93wbZCkkerwYuFg3AMUzNlF4mzoPVcvezXZCu9sbeNMAZDZD"

export.result <- data.frame(link=character(), created=character(), share=numeric(), coment=numeric(), id=character(), like=numeric(), love=numeric(), wow=numeric(), haha=numeric(), sad=numeric(), angry=numeric(), thankful=numeric(), total_reaction=numeric(), reach=numeric(), success=character())
df <- read.csv('fb_list.csv')
for (i in 1:nrow(df))
{
  process_success <- ""
  fburl <- toString(df[i,])
  print(paste("fetching",i,"of",nrow(df)))
  
  split <- strsplit(fburl, "facebook.com/")
  fb_page <- strsplit(split[[1]][2],"/")[[1]][1]
  
  #get page id and fan count
  api_endpoint <- "?fields=fan_count"
  url <- sprintf("%s/%s%s&access_token=%s",graph_api_base, fb_page, api_endpoint,access_token)
  src <- GET(url)
  r <- content(src, "text", encoding = "UTF-8")
  page_id <- jsonlite::fromJSON(r)$id
  if(is.null(page_id)) page_id <- ""
  page_fan_count <- jsonlite::fromJSON(r)$fan_count
  if(is.null(page_fan_count)) page_fan_count <- 0
  
    
  url <- sprintf("https://graph.facebook.com/%s?access_token=%s", fb_page,access_token)
  src <- GET(url)
  r <- content(src, "text", encoding = "UTF-8")
  data.frame <- jsonlite::fromJSON(r)
  page_id <- ""
  if(!is.null(data.frame$id))
    page_id <- data.frame$id
  #print(data.frame)
  
  link <- strsplit(fburl, "\\?")[[1]][1] #get rid of any string to the right of ?
  split <- strsplit(link, "/") #split based on / s
  post_id <- tail(split[[1]], n=1) #get the last element from the resulted list
  post_id <- strsplit(post_id, ":")[[1]][1] #in case the reported url contains a :
  
  fb_id <- sprintf("%s_%s", page_id, post_id)
  
  #get likes for post, created time and share count
  
  api_endpoint <- "shares,created_time,reactions.type(LIKE).summary(total_count).limit(0).as(like),reactions.type(LOVE).summary(total_count).limit(0).as(love),reactions.type(WOW).summary(total_count).limit(0).as(wow),reactions.type(HAHA).summary(total_count).limit(0).as(haha),reactions.type(SAD).summary(total_count).limit(0).as(sad),reactions.type(ANGRY).summary(total_count).limit(0).as(angry),reactions.type(THANKFUL).summary(total_count).limit(0).as(thankful)"
  url <- sprintf("%s/%s?fields=%s&access_token=%s",graph_api_base, fb_id, api_endpoint,access_token)
  src <- GET(url)
  r <- content(src, "text", encoding = "UTF-8")
  
  error <- !is.null(jsonlite::fromJSON(r)$error)
  if(error)
  {
    fb_shares <- 0
    fb_created_time <- "n/a"
    fb_likes <- 0
    fb_love <- 0
    fb_wow <- 0
    fb_haha <- 0
    fb_sad <- 0
    fb_angry <- 0
    fb_thankful <- 0
    fb_reaction_total <- 0
    process_success <- "ERR"
  }
  else
  {
    #share endpoint dont return anything if the post haven't been shared
    fb_shares <- jsonlite::fromJSON(r)$shares$count
    if(is.null(fb_shares)) fb_shares <- 0
    
    fb_created_time <- jsonlite::fromJSON(r)$created_time
    fb_likes <- jsonlite::fromJSON(r)$like$summary$total_count
    fb_love <- jsonlite::fromJSON(r)$love$summary$total_count
    fb_wow <- jsonlite::fromJSON(r)$wow$summary$total_count
    fb_haha <- jsonlite::fromJSON(r)$haha$summary$total_count
    fb_sad <- jsonlite::fromJSON(r)$sad$summary$total_count
    fb_angry <- jsonlite::fromJSON(r)$angry$summary$total_count
    fb_thankful <- jsonlite::fromJSON(r)$thankful$summary$total_count
    fb_reaction_total <- fb_likes+ fb_love+ fb_wow+ fb_haha+ fb_sad+ fb_angry+ fb_thankful
  }
  #print(reaction.df)
  
  #comment counts
  api_endpoint <- "comments?summary=1&limit=0"
  url <- sprintf("%s/%s/%s&access_token=%s",graph_api_base, fb_id, api_endpoint,access_token)
  src <- GET(url)
  r <- content(src, "text", encoding = "UTF-8")
  fb_comment <- jsonlite::fromJSON(r)$summary$total_count
  if(is.null(fb_comment)) fb_comment <- 0
  
  #write and export
  row <- data.frame(fburl, fb_created_time, fb_shares, fb_comment, fb_id,fb_likes, fb_love, fb_wow, fb_haha, fb_sad, fb_angry, fb_thankful, fb_reaction_total, page_fan_count, process_success)
  export.result <- rbind(export.result, row)
}

print(export.result)
#engagement
export.result["eng"] <- export.result$fb_shares + export.result$fb_comment + export.result$fb_reaction_total
write.csv(export.result, file = "export-fb.csv", row.names = F)
print("FINISHED! Exported to export-fb.csv")


