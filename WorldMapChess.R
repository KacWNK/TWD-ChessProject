library(shiny)
library(ggplot2)
library(dplyr)
library(maps)

mapdata<-read.csv("WorldStats.csv")
ui2 <- fluidPage(
  selectInput(inputId = "player", label = "Choose player: ", 
              choices = c("Kacper", "Krzysiek"), selected = "Kacper"),
  radioButtons(inputId = "fill_var", label = "Choose variable to fill: ",
               choices = c("Win Ratio"="WinP","Average Accuracy"= "Accuracy"), selected = "WinP"),
  plotOutput(outputId = "map")
)


server <- function(input, output) {
  
  
  filtered_mapdata <- reactive({
    mapdata[mapdata$Player == input$player,]
  })
  
  
  output$map <- renderPlot({
    ggplot(filtered_mapdata(), aes_string(x = "long", y = "lat", group = "group", fill = input$fill_var)) +
      geom_polygon(color = "black") +
      scale_fill_gradient(name =ifelse(input$fill_var=="WinP", "Win Ratio(%)","Average Accuracy"),
                          low = ifelse(input$fill_var == "WinP", "#6c9d41", "orange"),
                          high = ifelse(input$fill_var == "WinP", "#4e7838", "red"),
                          na.value = ifelse(input$fill_var == "WinP", "#94bb48", "yellow"),
                          trans = "log10") +
      theme(axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.title.y = element_blank(),
            axis.title.x = element_blank(),
            rect = element_blank(),
            panel.grid = element_blank(),
            panel.background = element_rect(fill = 'black')) +
      labs(title = paste("Player ", input$player, " vs World"))
  })
}


shinyApp(ui2, server)

