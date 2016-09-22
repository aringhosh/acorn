library(httr)
library(jsonlite)
library("mailR")

#helper function
percent <- function(x, digits = 2, format = "f", ...) {
  paste0(formatC(x, format = format, digits = digits, ...), "%")
}

topics_df <- read.csv("weekly topics list.csv", stringsAsFactors = F)
report.df <- data.frame(character(), character(), character(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric(), numeric(), stringsAsFactors = F)


#part 1: gather numbers
base_url <- "https://api.datarank.com/topics/"

for (i in 1:nrow(topics_df))
{
  slug <- topics_df[i,1]
  start <- topics_df[i,2]
  end <- Sys.Date() #"2016-09-21" #topics_df[i,3]
  
  print(paste("processing :", slug))
  
  print("begining twitter")
  Datasource <- "T"
  param_url <- paste("/reach/weekly?datasource=",Datasource,"&start_date=",start,"&end_date=",end, sep = "")
  callback_url <- paste(base_url,slug,param_url, sep = "")
  r <- GET(callback_url, accept("application/vnd.datarank.v1+json"), add_headers(authorization = "08fde929d0b62c4f2c58cf53801f42d4ab9a49d11dd3d95c6252db1b31a24e56"))
  jsontext <- content(r, "text", encoding = "UTF-8")
  parsedDataframe <- fromJSON(jsontext)
  data <- parsedDataframe$reach$data
  T_total <- parsedDataframe$last90
  no_of_weeks <- length(parsedDataframe$reach$data$data)
  if(no_of_weeks == 0)
  {
    T_last_week <- T_last_week_per <- 0
  }else
  {
    T_last_week <- data[no_of_weeks, 2]

    if(T_last_week != T_total)
    {
      T_last_week_per <- percent(T_last_week/T_total)  
    }else
    {
      T_last_week_per <- percent(100)
    }
    
  }
  
  print("begining INSTAGRAM")
  Datasource <- "INSTAGRAM"
  param_url <- paste("/reach/weekly?datasource=",Datasource,"&start_date=",start,"&end_date=",end, sep = "")
  callback_url <- paste(base_url,slug,param_url, sep = "")
  r <- GET(callback_url, accept("application/vnd.datarank.v1+json"), add_headers(authorization = "08fde929d0b62c4f2c58cf53801f42d4ab9a49d11dd3d95c6252db1b31a24e56"))
  jsontext <- content(r, "text", encoding = "UTF-8")
  parsedDataframe <- fromJSON(jsontext)
  data <- parsedDataframe$reach$data
  I_total <- parsedDataframe$last90
  no_of_weeks <- length(parsedDataframe$reach$data$data)
  if(no_of_weeks == 0)
  {
    I_last_week <- I_last_week_per <- 0
  }else
  {
    I_last_week <- data[no_of_weeks, 2]

    if(I_last_week != I_total)
    {
      I_last_week_per <- percent(I_last_week/I_total)  
    }else
    {
      I_last_week_per <- percent(100)
    }
  }
  
  total_reach <- T_total + I_total
  total_reach_last_week <- T_last_week + I_last_week
  
  row <- data.frame(slug, start, end, T_total, T_last_week, T_last_week_per, I_total, I_last_week, I_last_week_per, total_reach, total_reach_last_week)
  report.df <- rbind( report.df, row)
}

filename <- paste(end, "-weekly-reach-export.csv", sep = "")
write.csv(report.df, file = filename, row.names = F)

print(report.df)
print(paste("exported to", filename))
View(report.df)

# part 2: email report

sendMail <- function(filename)
{
  #https://github.com/rpremraj/mailR
  toEmail <- c("kduke@acorninfluence.com", "hhairston@acorninfluence.com", "kvaldez@acorninfluence.com",
               "sfree@acorninfluence.com", "mhumble@acorninfluence.com")
  
  send.mail(from = "report@acorninfluence.com",
            to = toEmail,
            cc = c("aghosh@acorninfluence.com"),
            subject = paste("Campaign reach for the week of", Sys.Date()),
            body = "Weekly Report is attached. This is an automated email, please do not reply. Contact aghosh@acorninfluence.com for further assistance.",
            smtp = list(host.name = "aspmx.l.google.com", port = 25),
            authenticate = FALSE,
            send = TRUE,
            debug = TRUE,
            attach.files = filename)
}

readOption <- function(){
  n <- readline()
  switch(n,
    'y' = {sendMail(filename)},
    'n' = {print("email not sent!")},
    {
      print("use y or n")
      readOption()
    }
          )
}

print("send email now? y/n")
readOption()
