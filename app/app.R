library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(forcats)
library(gridExtra)
library(maps)

dfMoveQuality <- read.csv("MoveQuality.csv")
mapdata <- read.csv("WorldStats.csv")
dfWinRate <- read.csv("WinRate.csv")
dfGamesData <- read.csv("GamesData.csv")

dfGamesData %>% 
  mutate(date = as.Date(date)) %>%  
  mutate(endHour = substring(endHour,1, nchar(endHour)-3)) %>% 
  mutate(endHour = as.numeric(gsub(":", "\\.", endHour))) -> dfGamesData


ui1 <- fluidPage(
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("typeWinRate",
                   "Choose time control",
                   selected = unique(dfWinRate$Type)[1],
                   choiceNames = c("Bullet", "Blitz", "Rapid"),
                   choiceValues = unique(dfWinRate$Type)
      ),

      radioButtons("playerWinRate",
                   "Select a player",
                   selected = unique(dfWinRate$Player)[1],
                   choices = unique(dfWinRate$Player)
      ),
    ),
    mainPanel(
      plotOutput("winRatePlot")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      radioButtons("colorMoveQuality",
                   "Choose color of pieces",
                   selected = unique(dfMoveQuality$Color)[1],
                   choiceNames = c("White", "Black", "White and black"),
                   choiceValues = unique(dfMoveQuality$Color)
                  ),

      radioButtons("playerMoveQuality",
                   "Select a player",
                   selected = unique(dfMoveQuality$Player)[1],
                   choices = unique(dfMoveQuality$Player)
                   ),

      radioButtons("typeMoveQuality",
                   "Choose time control",
                   selected = unique(dfMoveQuality$Type)[1],
                   choiceNames = c("Bullet", "Blitz", "Rapid"),
                   choiceValues = unique(dfMoveQuality$Type)
                   )
                ),
    mainPanel(
      plotlyOutput("moveQualityPlot")
      )
    ),

  sidebarLayout(position = "left",

                sidebarPanel(

                  radioButtons("playerElo",
                               "Select a player",
                               selected = unique(dfGamesData$player)[1],
                               choices = unique(dfGamesData$player)
                  ),
                  radioButtons("typeElo",
                               "Choose time control",
                               selected = unique(dfGamesData$timeControl)[1],
                               choices = unique(dfGamesData$timeControl)
                  ),
                  uiOutput("timeLagElo")
                ),

                mainPanel(
                  plotOutput("eloPlot")
                )
  ),
  plotOutput("densPlot")
)

ui2 <- fluidPage(
  selectInput(inputId = "player", label = "Choose player: ", 
              choices = c("Kacper", "Krzysiek"), selected = "Kacper"),
  radioButtons(inputId = "fill_var", label = "Choose variable to fill: ",
               choices = c("Win Ratio"="WinP","Average Accuracy"= "Accuracy"), selected = "WinP"),
  plotOutput(outputId = "map"),
  
  selectInput("gif", "Select a gif:", 
              choices = c("Immortal game- Kacper(white)" = "C:/Users/Krzysztof Sawicki/Documents/KW_immortalGame.gif",
                          "First game- Kacper(white)" = "C:/Users/Krzysztof Sawicki/Documents/KacperPierwszaPartia.gif",
                          "Immortal game- Krzysiek"="C:/Users/Krzysztof Sawicki/Documents/gigachad-chad.gif",
                          "First game- Krzysiek(white)"="C:/Users/Krzysztof Sawicki/Documents/Krzysiu_pierwszaPartia.gif")),
  
  imageOutput("selected_gif")
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
  }, bg="transparent")

  output$eloPlot <- renderPlot({
    
    dfGamesData %>% filter(date >= input$timeLagElo[1],
                           date <= input$timeLagElo[2],
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
    
    sliderInput("timeLagElo",
                "Select a time period",
                value = c(min(df3$date), max(df3$date)),
                min = min(df3$date),
                max = max(df3$date),
                step = 1
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
}

app_ui <- navbarPage(
  title = "Szachy",
  tabPanel("Elo", ui1),
  tabPanel("Mapa", ui2),
  theme = bslib::bs_theme( bg = "#FFDFF8", fg = "black", primary = "#FFB5EE",
                           bootswatch = "minty")
)


shinyApp(ui = app_ui, server = server)






