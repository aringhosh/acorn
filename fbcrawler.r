library(rjson)
library(httr)

api_url <- "https://api.datarank.com/facebook/post/stats"
fb.post.url <- "https://www.facebook.com/SouthernMomLoves/posts/1086417188117773"
auth.id <- "08fde929d0b62c4f2c58cf53801f42d4ab9a49d11dd3d95c6252db1b31a24e56"

raw.body <- list(link=c(fb.post.url))
request.body <- toJSON(raw.body)

r <- POST(url = api_url, add_headers(Authorization = auth.id), content_type_json(), accept("application/vnd.datarank.v1+json"), body = request.body)