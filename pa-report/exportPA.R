library(XLConnect)
wb <- loadWorkbook("pa-report/PA sheet.xlsx")
sheetName <- "new campaign value"



#read all the input files
fb.data <- read.csv("export-fb.csv")
colnames(fb.data)[1] <- "url"
insta.data <- read.csv("export-instagram.csv")
colnames(insta.data)[1] <- "url"
pin.data <- read.csv("export-pinterest.csv")
#colnames(pin.data)[1] <- "url" (pin already has the name as column)
twitter.data <- read.csv("export-twitter.csv")
colnames(twitter.data)[1] <- "url"
blog.data <- read.csv("export-blog.csv")
colnames(blog.data)[1] <- "url"
youtube.data <- read.csv("export-youtube.csv")
colnames(youtube.data)[1] <- "url"

fb.poc <- nrow(fb.data) 
insta.poc <- nrow(insta.data)
pin.poc <- nrow(pin.data)
twitter.poc <- nrow(twitter.data)
youtube.poc <- nrow(youtube.data)
snap.poc <- 0
blog.poc <- nrow(blog.data)

poc <- c(fb.poc, insta.poc, pin.poc, twitter.poc, youtube.poc, snap.poc, blog.poc)
poc <- data.frame(poc)
writeWorksheet(wb,poc,sheetName,startRow = 4, startCol = 2, header = FALSE)

#engagements
fb.likes <- sum(fb.data$likeCount)
fb.comments <- sum(fb.data$commentCount)
fb.shares <- sum(fb.data$shareCount)
fb.data["eng"] <- fb.data$commentCount + fb.data$likeCount + fb.data$shareCount
  
insta.likes <- sum(insta.data$Likes)
insta.comments <- sum(insta.data$Comments)
insta.data["eng"] <- insta.data$Likes + insta.data$Comments + insta.data$Video.Views

pin.likes <- sum(pin.data$likes)
pin.repins <- sum(pin.data$repins)
pin.comments <- sum(pin.data$comments)
pin.data["eng"] <- pin.data$likes + pin.data$repins+ pin.data$comments

twit.favs <- sum(twitter.data$fav)
twit.rts <- sum(twitter.data$retweets)
twitter.data["eng"] <- twitter.data$fav + twitter.data$retweets

blog.comment <- 0
blog.shares <- sum(blog.data$TOTAL.sum.)

youtube.views <- sum(youtube.data$view)
youtube.comments <- sum(youtube.data$comments)
youtube.data["eng"] <- youtube.data$view # youtube views here

fb.video.views <- 0
insta.video.views <- sum(insta.data$Video.Views)

engagements <- c(fb.likes, fb.comments, fb.shares, insta.likes, insta.comments, pin.likes, pin.repins, pin.comments, twit.favs, twit.rts, blog.comment, blog.shares, youtube.views, youtube.comments, fb.video.views, insta.video.views)
engagements <- data.frame(engagements)
writeWorksheet(wb,engagements,sheetName,startRow = 15, startCol = 2, header = FALSE)

#reach
fb.reach <- sum(fb.data$reach)
insta.reach <- sum(insta.data$Reach)
pin.reach <- sum(pin.data$total.followers)
twitter.reach <- 0
youtube.reach <- sum(youtube.data$reach)

reach <- c(fb.reach, insta.reach, pin.reach, twitter.reach, youtube.reach)
reach <- data.frame(reach)

#write to excel
writeWorksheet(wb,reach,sheetName,startRow = 5, startCol = 7, header = FALSE)
setForceFormulaRecalculation(wb, sheetName, T)

#standout contents
fb.standout <- fb.data[order(fb.data$eng, decreasing = T),][1:3 ,c("url","eng")]
insta.standout <- insta.data[order(insta.data$eng, decreasing = T),][1:3 ,c("url","eng")]
pin.standout <- pin.data[order(pin.data$eng, decreasing = T),][1:3 ,c("url","eng")]
twitter.standout <- twitter.data[order(twitter.data$eng, decreasing = T),][1:3 ,c("url","eng")]
youtube.standout <- youtube.data[order(youtube.data$eng, decreasing = T),][1:3 ,c("url","eng")]
colnames(blog.data)[ncol(blog.data)] <- "eng"
blog.standout <- blog.data[order(blog.data$eng, decreasing = T),][1:3 ,c("url","eng")]

fb.standout["type"] <- "FB"
insta.standout["type"] <- "INSTAGRAM"
pin.standout["type"] <- "PIN"
twitter.standout["type"] <- "TWITTER"
youtube.standout["type"] <- "YOUTUBE"
blog.standout["type"] <- "BLOG"

standout.sheet.name <- "standout contents"
writeWorksheet(wb,rbind(fb.standout, insta.standout, pin.standout, twitter.standout, youtube.standout, blog.standout),standout.sheet.name,startRow = 1, startCol = 1, header = TRUE)

#save changes
saveWorkbook(wb)
print("finished exporting PA")

