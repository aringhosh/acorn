library(httr)
library(jsonlite)

#helper function
percent <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(x, format = format, digits = digits, ...), "%")
}

topics_df <- read.csv("weekly topics list.csv", stringsAsFactors = F)
report.df <- data.frame(character(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric(), stringsAsFactors = F)


base_url <- "https://api.datarank.com/topics/"

for (i in 1:nrow(topics_df))
{
  slug <- topics_df[i,1]
  start <- topics_df[i,2]
  end <- topics_df[i,3]
  
  print(paste("processing :", slug))
  
  Datasource <- "T"
  param_url <- paste("/reach/weekly?datasource=",Datasource,"&start_date=",start,"&end_date=",end, sep = "")
  callback_url <- paste(base_url,slug,param_url, sep = "")
  r <- GET(callback_url, accept("application/vnd.datarank.v1+json"), add_headers(authorization = "08fde929d0b62c4f2c58cf53801f42d4ab9a49d11dd3d95c6252db1b31a24e56"))
  jsontext <- content(r, "text", encoding = "UTF-8")
  parsedDataframe <- fromJSON(jsontext)
  data <- parsedDataframe$reach$data
  T_total <- parsedDataframe$last90
  T_last_week <- data[nrow(data),2]
  T_last_week_per <- percent(T_last_week/T_total)
  
  Datasource <- "INSTAGRAM"
  param_url <- paste("/reach/weekly?datasource=",Datasource,"&start_date=",start,"&end_date=",end, sep = "")
  callback_url <- paste(base_url,slug,param_url, sep = "")
  r <- GET(callback_url, accept("application/vnd.datarank.v1+json"), add_headers(authorization = "08fde929d0b62c4f2c58cf53801f42d4ab9a49d11dd3d95c6252db1b31a24e56"))
  jsontext <- content(r, "text", encoding = "UTF-8")
  parsedDataframe <- fromJSON(jsontext)
  data <- parsedDataframe$reach$data
  I_total <- parsedDataframe$last90
  I_last_week <- data[nrow(data),2]
  I_last_week_per <- percent(I_last_week/I_total)
  
  total_reach <- T_total + I_total
  total_reach_last_week <- T_last_week + I_last_week
  
  row <- data.frame(slug, T_total, T_last_week, T_last_week_per, I_total, I_last_week, I_last_week_per, total_reach, total_reach_last_week)
  report.df <- rbind( report.df, row)
}

write.csv(report.df, file = "export-weekly-topic-reach.csv", row.names = F)

