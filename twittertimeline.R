library("twitteR")

c_key = "aW7HdzD7T8bddh6XZQsF9fV9S"
c_sec = "DW6tly9zOZz1SWdnHF0HmGi7CMwZQf6bbWxFNKH02ge8apjKtC"
a_tok = "9478372-uNoENCNbAcU6x82gji20sOE9orH30ZUfy7e7vKt93c"
a_sec = "Ru7pwWvE2tTEAuGRRSbk8SXcWEjCBCamQ4PrRJLJY"

setup_twitter_oauth(consumer_key = c_key, consumer_secret = c_sec, access_token = a_tok, access_secret = a_sec)

username <- "healthyvoyager"
u <- getUser(username)
statuses <- userTimeline(u, n= 20, includeRts = T)
df <- twitteR::twListToDF(statuses)
df["follower"] <- followersCount(u)
write.csv(df[c(1,3,11,12,13,17)], file = "export-twitter.csv", row.names = F)