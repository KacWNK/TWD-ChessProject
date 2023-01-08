library(shiny)
library(semantic.dashboard)
library(ggplot2)
library(dplyr)
library(plotly)
library(forcats)
library(gridExtra)
library(maps)

CREATORS <- c(
  "Krzysztof Sawicki",
  "Jakub Grzywaczewski",
  "Kacper Wnęk"
)


shinyServer(function(input, output) {
  # Change creator 
  output$creator <- renderText(CREATORS[index])
  update_creator = function(index, interval = 2) {
    index <- index %% 3 + 1 
    output$creator <- renderText(CREATORS[index])
    later::later(function () update_creator(index), interval)
  }
  update_creator(1)
  
  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    hist(x, breaks = bins, col = 'darkgray', border = 'white',
         xlab = 'Waiting time to next eruption (in mins)',
         main = 'Histogram of waiting times')
  })
})
