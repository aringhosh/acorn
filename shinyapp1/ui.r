library(shiny)
library(shinythemes)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("spacelab"),

  # Application title
  titlePanel("Facebook Reach - #ItsBakingSeason"),

  # Sidebar with a slider input for the number of bins

    mainPanel("Impressions and Engagements",
                          fluidRow(
                            plotOutput("distPlot"), plotOutput("cumPlot"), plotOutput("engPlot"), plotOutput("likePlot")
                            #splitLayout(cellWidths = c("50%", "50%"), plotOutput("distPlot"), plotOutput("cumPlot"))
                          )
                )
  
))