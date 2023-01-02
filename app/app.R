library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)

df <- read.csv("df.csv", sep = ";")
dfMoveQuality <- read.csv("MoveQuality.csv", sep = ";")
dfWorldStats <- read.csv("WorldStats.csv", sep = ";")
dfWinRate <- read.csv("WinRate.csv")


df %>% mutate(Data = as.Date(gsub("\\.","-",Data))) -> df


ui1 <- fluidPage(
  
  sidebarLayout(position = "left",
                
    sidebarPanel(
      
      sliderInput("timeLagElo",
                  "Wybierz przedział czasowy",
                  value = c(min(df$Data), max(df$Data)),
                  min = min(df$Data),
                  max = max(df$Data),
                  step = 1),
      radioButtons("playerElo",
                   "Wybierz gracza",
                   selected = c("Kacper", "Krzysiek")[1],
                   choices = c("Kacper", "Krzysiek")),
      
      radioButtons("typeElo",
                   "Wybierz typ partii",
                   selected = c("rapid", "bullet", "blitz")[1],
                  choices = c("rapid", "bullet", "blitz"))
      ),
    
    mainPanel(
    plotOutput("eloPlot")
    )
  ),

  sidebarLayout(
    sidebarPanel(
      radioButtons("colorMoveQuality",
                   "Wybierz kolor bierek",
                   selected = unique(dfMoveQuality$Color)[1],
                   choiceNames = c("Białe", "Czarne", "Białe i Czarne"),
                   choiceValues = unique(dfMoveQuality$Color)
                  ),
      
      radioButtons("playerMoveQuality",
                   "Wybierz gracza",
                   selected = unique(dfMoveQuality$Player)[1],
                   choices = unique(dfMoveQuality$Player)
                   ),
      
      radioButtons("typeMoveQuality",
                   "Wybierz typ partii",
                   selected = unique(dfMoveQuality$Type)[1],
                   choiceNames = c("Bullet", "Blitz", "Rapid"), 
                   choiceValues = unique(dfMoveQuality$Type)
                   )
                ),
    mainPanel(
      plotlyOutput("moveQualityPlot")
      )
    ),
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("typeWinRate", 
                   "Wybierz typ partii",
                   selected = unique(dfWinRate$Type)[1],
                   choiceNames = c("Bullet", "Blitz", "Rapid"), 
                   choiceValues = unique(dfWinRate$Type)
      ),
      
      radioButtons("playerWinRate",
                   "Wybierz gracza",
                   selected = unique(dfWinRate$Player)[1],
                   choices = unique(dfWinRate$Player)
      ),
    ),
    mainPanel(
      plotOutput("winRateplot")
    )
  )
)



server <- function(input, output) {

  output$eloPlot <- renderPlot({
    
    df %>% filter(Data >= input$timeLagElo[1],
                  Data <= input$timeLagElo[2]) -> df2
    
    ggplot(data = df2, aes(x = Data, y = MyElo))+
      geom_point()+
      geom_line()
    
  })
  
  output$moveQualityPlot <- renderPlotly({
    
    dfMoveQuality %>%
      filter(Type %in% input$typeMoveQuality,
             Color %in% input$colorMoveQuality,
             Player %in% input$playerMoveQuality) ->dfMoveQualityPlot
    
    ggplot(data = dfMoveQualityPlot, aes(x = Procent, y = Move))+ 
      geom_col()
  })
  
  output$winRateplot <- renderPlot({
    
    dfWinRate %>% 
      filter(Type %in% input$typeWinRate,
             Player %in% input$playerWinRate)-> dfWinRatePlot
    
    ggplot(dfWinRatePlot, aes(x = "", y = Matches, fill = Result)) +
      geom_col(width = 0.5) +
      geom_text(aes(label = paste(Percentages, "%")), position = position_stack(vjust = 0.5)) +
      scale_fill_manual(values = dfWinRatePlot$Colors) +
      labs(title = "Match Results", x = "", y = "Number of Matches") +
      theme(plot.title = element_text(hjust = 0.5),
            plot.background = element_rect(fill = "transparent")) +
      coord_flip()
  })
}


shinyApp(ui = ui1, server = server)


