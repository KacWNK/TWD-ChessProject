library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(forcats)
library(gridExtra)

dfMoveQuality <- read.csv("MoveQuality.csv", sep = ";")
dfWorldStats <- read.csv("WorldStats.csv", sep = ";")
dfWinRate <- read.csv("WinRate.csv")
dfGamesData <- read.csv("GamesData.csv")

dfGamesData %>% 
  mutate(date = as.Date(date)) %>%  
  mutate(endHour = substring(endHour,1, nchar(endHour)-3)) %>% 
  mutate(endHour = as.numeric(gsub(":", "\\.", endHour))) -> dfGamesData

dfMoveQuality %>% filter(Move == "Good")


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
                   "Choose color of pawns",
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
                  uiOutput("typeElo"),
                  uiOutput("timeLagElo")      
                ),
                
                mainPanel(
                  plotOutput("eloPlot")
                )
  ),
  plotOutput("densPlot")
)



server <- function(input, output) {

  output$eloPlot <- renderPlot({
    
    dfGamesData %>% filter(date >= input$timeLagElo[1],
                           date <= input$timeLagElo[2],
                           timeControl %in% input$typeElo) -> df2
    
    ggplot(data = df2, aes(x = date, y = yourElo))+
      geom_point()+
      geom_line()+
      labs(x = "Date", y = "Rating points")
    
  })
  
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
      theme(legend.position="none")
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
      theme(plot.title = element_text(hjust = 0.5),
            plot.background = element_rect(fill = "transparent")) +
      coord_flip() +
      theme_void()
  })
  
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
  
  output$typeElo <- renderUI({
    
    dfGamesData %>% filter(player %in% input$playerElo) -> df4
    if (input$playerElo == "Kacper"){
      namesVector = c("Bullet 2 min + 1 sec increment", "Blitz 5 min", "Bullet 1 min", "Rapid 10 min")
    }
    
    radioButtons("typeElo",
                 "Choose time control",
                 choiceNames = namesVector,
                 choiceValues = unique(df4$timeControl)
    ) 
  })
  
  output$densPlot <- renderPlot({
    
    ggplot(data = dfGamesData %>% filter(player == "Kacper"), aes(x = endHour))+
      geom_density()+
      labs(x = "Time")+
      labs(x = "Time", y = "Density")-> p1
    ggplot(data = dfGamesData %>% filter(player == "Krzysiek"), aes(x = endHour))+
      geom_density()+
      labs(x = "Time", y = "Density")->p2
    grid.arrange(p1,p2, ncol =2)
  })
}


shinyApp(ui = ui1, server = server)


