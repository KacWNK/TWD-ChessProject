library(shiny)
library(shiny.semantic)
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

dfMoveQuality <- read.csv("./resources/MoveQuality.csv")
mapdata <- read.csv("./resources/WorldStats.csv")
dfWinRate <- read.csv("./resources/WinRate.csv")
dfGamesData <- read.csv("./resources/GamesData.csv")

dfGamesData %>% 
  mutate(date = as.Date(date)) %>%  
  mutate(endHour = substring(endHour,1, nchar(endHour)-3)) %>% 
  mutate(endHour = as.numeric(gsub(":", "\\.", endHour))) -> dfGamesData


shinyServer(function(input, output) {
  # Change creator 
  output$creator <- renderText(CREATORS[index])
  update_creator = function(index, interval = 2) {
    index <- index %% 3 + 1 
    output$creator <- renderText(CREATORS[index])
    later::later(function () update_creator(index), interval)
  }
  update_creator(1)
  
  ## MAP FOR KACPER
  output$mapKacper <- renderPlot({
    mapdata[mapdata$Player == "Kacper", ] %>%
    ggplot(aes_string(x = "long", y = "lat", group = "group", fill = input$fill_var)) +
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
            plot.background = element_rect(fill='transparent', color=NA)) +
      labs(title = paste("Player Kacper vs World"))
  }, bg="transparent")
  
  ## MAP FOR KACPER
  output$mapKrzysiek <- renderPlot({
    mapdata[mapdata$Player == "Krzysiek", ] %>%
    ggplot(aes_string(x = "long", y = "lat", group = "group", fill = input$fill_var)) +
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
            plot.background = element_rect(fill='transparent', color=NA)) +
      labs(title = "Player Krzysiek vs World")
  }, bg="transparent")

  
  output$eloPlot <- renderPlot({
    dfGamesData %>% filter(date >= input$date_from,
                           date <= input$date_to,
                           timeControl %in% input$typeElo,
                           player %in% input$playerElo) -> df2
    
    ggplot(data = df2, aes(x = date, y = yourElo))+
      geom_point()+
      geom_line()+
      labs(x = "Date", y = "Rating points")+
      theme(
        panel.background = element_rect(fill='transparent'), 
        plot.background = element_rect(fill='transparent', color=NA), 
      )
  }, bg="transparent")
  
  output$moveQualityPlot <- renderPlotly({
    dfMoveQuality %>%
      filter(Type %in% input$typeMoveQuality,
             Color %in% input$colorMoveQuality,
             Player %in% input$playerMoveQuality) %>% 
      mutate(Move = fct_reorder(Move, Procent, .desc = FALSE))->dfMoveQualityPlot
    
    ggplot(data = dfMoveQualityPlot, aes(x = Procent, y = Move, fill = MoveColor))+
      geom_col()+
      labs(x = "Percent", y = "Move type")+
      scale_fill_manual(values = unique(dfMoveQualityPlot$MoveColor))+ 
      scale_x_continuous(expand = c(0,0))+
      theme(legend.position="none")+
      theme(
        panel.background = element_rect(fill='transparent'), 
        plot.background = element_rect(fill='transparent', color=NA)
      )
    
  })
  
  output$winRatePlot <- renderPlot({
    
    dfWinRate %>% 
      filter(Type %in% input$typeWinRate,
             Player %in% input$playerWinRate)-> dfWinRatePlot
    
    ggplot(dfWinRatePlot, aes(x = "", y = Matches, fill = Result)) +
      geom_col(width = 0.5) +
      geom_text(aes(label = paste(Percentages, "%")), position = position_stack(vjust = 0.5)) +
      scale_fill_manual(values = dfWinRatePlot$Colors) +
      labs(x = "", y = "Number of Matches") +
      theme_void()+
      theme(legend.position="bottom")+
      coord_flip()+
      theme(
        panel.background = element_rect(fill='transparent'), 
        plot.background = element_rect(fill='transparent', color=NA)
      )
  }, bg="transparent")
  
  
  output$timeLagElo <- renderUI({
    dfGamesData %>% filter(player %in% input$playerElo, timeControl %in% input$typeElo) -> df3
    tagList(
      tags$div(
        tags$div(HTML("From")),
        date_input(
          "date_from", 
          value = min(df3$date), 
          min = min(df3$date),
          max = max(df3$date))
      ),
      br(),
      tags$div(
        tags$div(HTML("To")),
        date_input(
          "date_to", 
          value = max(df3$date), 
          min = min(df3$date),
          max = max(df3$date))
      )
    )
  })
  
  output$densPlot <- renderPlot({
    
    ggplot(data = dfGamesData %>% filter(player == "Kacper"), aes(x = endHour))+
      geom_density(fill = "#96bc4b")+
      labs(x = "Time", y = "Density", title = "Kacper")+
      scale_x_continuous(expand = c(0,0))+
      scale_y_continuous(expand = c(0,0))+
      theme(
        panel.background = element_rect(fill='transparent'), 
        plot.background = element_rect(fill='transparent', color=NA), 
      )-> p1
    ggplot(data = dfGamesData %>% filter(player == "Krzysiek"), aes(x = endHour))+
      geom_density(fill = "#1bada6")+
      labs(x = "Time", y = "Density", title = "Krzysiek")+
      scale_x_continuous(expand = c(0,0))+
      scale_y_continuous(expand = c(0,0))+
      theme(
        panel.background = element_rect(fill='transparent'), 
        plot.background = element_rect(fill='transparent', color=NA), 
      )->p2
    grid.arrange(p1,p2, ncol =2)
    
  }, bg="transparent")
  
  
  output$selected_gif <- renderImage({
    list(src = input$gif)
  }, deleteFile = FALSE)
  
})
