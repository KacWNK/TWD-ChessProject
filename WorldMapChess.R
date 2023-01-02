library(shiny)
library(ggplot2)
library(dplyr)
library(maps)

dfWorldStats <- read.csv("WorldStats.csv", sep=";")
mapdata <- map_data("world")
colnames(mapdata)[colnames(mapdata) == "region"] <- "Country"
mapdata <- left_join(mapdata, dfWorldStats, by="Country")
mapdata$WinP <- gsub("%", "", mapdata$WinP)
mapdata$WinP<-as.numeric(mapdata$WinP)
mapdata$WinP <- ifelse(is.na(mapdata$WinP), 0, mapdata$WinP)
mapdata$Player<-ifelse(is.na(mapdata$Player),"Kacper", mapdata$Player)


ui2 <- fluidPage(
  selectInput(inputId = "player", label = "Wybierz gracza:", 
              choices = c("Kacper", "Krzysiek"), selected = "Kacper"),
  plotOutput(outputId = "map")
)


server <- function(input, output) {
  
  
  filtered_mapdata <- reactive({
    mapdata[mapdata$Player == input$player,]
  })
  
  
  output$map <- renderPlot({
    ggplot(filtered_mapdata(), aes( x = long, y = lat, group=group)) +
      geom_polygon(aes(fill = WinP), color = "black") +
      scale_fill_gradient(name = "Procent wygranych", low = "#6c9d41", high =  "#4e7838", na.value = "#94bb48", trans = "log10")+
      theme(axis.text.x = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks = element_blank(),
            axis.title.y=element_blank(),
            axis.title.x=element_blank(),
            rect = element_blank(),
            panel.grid = element_blank(),
            panel.background = element_rect(fill = 'black')) +
      labs(title = paste("Gracz ", input$player, " kontra świat"))
  })
}


shinyApp(ui2, server)
