library(XLConnect)
wb <- loadWorkbook("pa-report/PA sheet.xlsx")
sheetName <- "new campaign value"



#read all the input files
fb.data <- read.csv("export-fb.csv")
insta.data <- read.csv("export-instagram.csv")
pin.data <- read.csv("export-pinterest.csv")
twitter.data <- read.csv("export-twitter.csv")
blog.data <- read.csv("export-blog.csv")
youtube.data <- read.csv("export-youtube.csv")

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

insta.likes <- sum(insta.data$Likes)
insta.comments <- sum(insta.data$Comments)

pin.likes <- sum(pin.data$likes)
pin.repins <- sum(pin.data$repins)
pin.comments <- sum(pin.data$comments)

twit.favs <- sum(twitter.data$fav)
twit.rts <- sum(twitter.data$retweets)

blog.comment <- 0
blog.shares <- sum(blog.data$TOTAL.sum.)

youtube.views <- sum(youtube.data$view)
youtube.comments <- sum(youtube.data$comments)

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
writeWorksheet(wb,reach,sheetName,startRow = 5, startCol = 7, header = FALSE)

#write to excel
setForceFormulaRecalculation(wb, sheetName, T)
saveWorkbook(wb)
