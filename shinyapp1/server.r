library(shiny)
library(ggplot2)
library(ggthemes)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  # Expression that generates a histogram. The expression is
  # wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically
  #     re-executed when inputs change
  #  2) Its output type is a plot

  export.result <- read.csv("export-fb2.csv", stringsAsFactors=FALSE)
  data <- export.result[export.result$process_success!="ERR",]
  data[,2] <-as.character.Date(data[,2])
  data[,2] <-as.Date(data[,2])
  data["engagement"] <- data$fb_reaction_total+ data$fb_comment+ data$fb_shares


  x <- aggregate(data$page_fan_count, by=list(data$fb_created_time), sum)
  colnames(x)<- c("date", "impressions")

  z <- aggregate(data$engagement, by=list(data$fb_created_time), sum)
  colnames(z)<- c("date", "eng")

  a <- aggregate(data$fb_comment, by=list(data$fb_created_time), sum)
  colnames(a)<- c("date", "comments")

  output$distPlot <- renderPlot({  
    p <- ggplot(x, aes(x=date, y=impressions)) + geom_area(color="darkblue", fill="lightblue") + theme_hc()+ scale_colour_hc() +scale_x_date(date_breaks = "7 day",  date_labels = "%b/%d")
    p + geom_point(shape = 16,size=2, color= "black")
  })

  output$cumPlot <- renderPlot({  
    p <- ggplot(x, aes(x=date, y=cumsum(impressions)))+ geom_area(color="red", fill="orange") + theme_hc()+ scale_colour_hc() +scale_x_date(date_breaks = "7 day",  date_labels = "%b/%d")
    p + geom_point(shape = 16,size=2, color= "black")
  })

  output$engPlot <- renderPlot({
    ggplot(z, aes(x=date, y=eng)) + geom_line(size = 1, color="darkblue") + geom_point(shape = 16,size=2, color= "black")+ theme_hc()+ scale_colour_hc()
    #p <- p+ ggplot(a, aes(x=date, y=likes)) + geom_line(size = 2, color="darkblue")
  })

  output$likePlot <- renderPlot({
    ggplot(a, aes(x=date, y=comments)) + geom_area(size = 1, color="green") + geom_point(shape = 16,size=2, color= "black")+ theme_hc()+ scale_colour_hc()
  })
})
