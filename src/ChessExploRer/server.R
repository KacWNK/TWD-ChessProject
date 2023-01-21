library(shiny)
library(shiny.semantic)
library(ggplot2)
library(dplyr)
library(plotly)
library(stringr)
library(forcats)
library(gridExtra)
library(maps)
library(sysfonts)
library(countrycode)

font_add_google("Roboto")
    
CREATORS <- c(
  "Krzysztof Sawicki",
  "Jakub Grzywaczewski",
  "Kacper Wnęk"
)

dfMoveQuality <- read.csv("./resources/MoveQuality.csv")
mapdata <- read.csv("./resources/WorldStats.csv")
dfWinRate <- read.csv("./resources/WinRate.csv")
dfGamesData <- read.csv("./resources/GamesData.csv")
dfFIDEData <- read.csv("./resources/players_in_chess.csv")

dfGamesData <- dfGamesData %>%
  mutate(date = as.Date(date)) %>%
  mutate(endHour = substring(endHour, 1, nchar(endHour) - 3)) %>%
  mutate(endHour = as.numeric(gsub(":", "\\.", endHour)))

dfFIDE <- dfFIDEData %>%
  group_by(country) %>%
  summarise(
    average_rating = mean(rating, na.rm = TRUE),
    max_rating = max(rating, na.rm = TRUE),
    number_of_fide_players = n()
  ) %>%
  left_join(dfFIDEData[c("name", "country", "rating")], by = c("country" = "country", "max_rating" = "rating")) %>%
  mutate(
    full_country_name = countrycode(country, origin = 'iso3c', destination = 'country.name'),
    .keep = "all"
  )



shinyServer(function(input, output) {
  # Change creator
  output$creator <- renderText(CREATORS[index])
  update_creator <- function(index, interval = 2) {
    index <- index %% 3 + 1
    output$creator <- renderText(CREATORS[index])
    later::later(function() update_creator(index), interval)
  }
  update_creator(1)
  
  ## Home side map
  output$mapFIDE <- renderPlotly({
    fig <- plot_geo(dfFIDE) %>%
      add_trace(
        z = ~number_of_fide_players,
        color = ~number_of_fide_players,
        colors = "Oranges",
        text = paste(
          "Country:", dfFIDE$full_country_name,
          "<br>Best Player:", dfFIDE$name,
          "<br>Max FIDE Rating:", dfFIDE$max_rating,
          "<br>Average Country Rating:", round(dfFIDE$average_rating, digits = 2)
        ),
        locations = ~country
      ) %>%
      colorbar(
        title = list(
          text = "Number of FIDE players",
          font = list(color = "white")
        ),
        tickfont = list(size = 14, color = "white")
      ) %>%
      layout(
        height = 800,
        paper_bgcolor = "rgba(0,0,0,0)",
        title = list(
          y = 0.99,
          text = "Number of FIDE players per country",
          font = list(
            color = "white",
            family = "Roboto",
            size = 30
          )
        ),
        legend = list(
          font = list(
            color = "white",
            family = "Roboto",
            size = 14
          )
        ),
        geo = list(
          showframe = FALSE,
          showcoastlines = TRUE,
          showland = TRUE,
          landcolor = "#312e2b",
          showocean = FALSE,
          projection = list(type = "Mercator"),
          bgcolor = "transparent"
        )
      )
    ggplotly(fig)
  })
  

  ## Map for kacper
  output$mapKacper <- renderPlot({
    mapdata[mapdata$Player == "Kacper", ] %>%
      ggplot(aes_string(x = "long", y = "lat", group = "group", fill = input$fill_var)) +
      geom_polygon(color = "black") +
      scale_fill_gradient(
        name = ifelse(input$fill_var == "WinP", "Win Ratio (%)", "Average Accuracy"),
        low = ifelse(input$fill_var == "WinP", "#6c9d41", "orange"),
        high = ifelse(input$fill_var == "WinP", "#4e7838", "red"),
        na.value = ifelse(input$fill_var == "WinP", "#94bb48", "yellow"),
        trans = "log10"
      ) +
      theme(
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        plot.title = element_text(size = 14, colour = "white"),
        legend.title = element_text(size = 12, colour = "white"),
        legend.text = element_text(size = 10, colour = "white"),
        rect = element_blank(),
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "transparent", color = NA)
      ) +
      labs(title = paste("Player Kacper vs World"))
  }, bg = "transparent")


  ## Map for krzysiek
  output$mapKrzysiek <- renderPlot({
    mapdata[mapdata$Player == "Krzysiek", ] %>%
      ggplot(aes_string(x = "long", y = "lat", group = "group", fill = input$fill_var)) +
      geom_polygon(color = "black") +
      scale_fill_gradient(
        name = ifelse(input$fill_var == "WinP", "Win Ratio (%)", "Average Accuracy"),
        low = ifelse(input$fill_var == "WinP", "#6c9d41", "orange"),
        high = ifelse(input$fill_var == "WinP", "#4e7838", "red"),
        na.value = ifelse(input$fill_var == "WinP", "#94bb48", "yellow"),
        trans = "log10"
      ) +
      theme(
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.y = element_blank(),
        axis.title.x = element_blank(),
        plot.title = element_text(size = 14, colour = "white"),
        legend.title = element_text(size = 12, colour = "white"),
        legend.text = element_text(size = 10, colour = "white"),
        rect = element_blank(),
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "transparent", color = NA)) +
      labs(title = "Player Krzysiek vs World")
  }, bg = "transparent")


  # ELo change plot
  output$eloPlot <- renderPlot({
    df2 <- dfGamesData %>% filter(
      date >= input$date_from,
      timeControl %in% str_to_title(input$timeControlComp),
      date <= input$date_to,
      player %in% input$playerComp
    )
    ggplot(data = df2, aes(x = date, y = yourElo)) +
      geom_line(
        stat = "smooth",
        color = "#f0a95e",
        method = "loess",
        se = TRUE,
        alpha = 0.3,
        linewidth = 10
      ) +
      geom_line(
        color = "#1bada6",
        size = 1.2
      ) +
      labs(
        x = "Date",
        y = "Rating points"
      ) +
      theme(
        axis.title.x = element_text(size = 14, colour = "white"),
        axis.title.y = element_text(size = 14, colour = "white"),
        axis.text.x = element_text(size = 8, colour = "#dfdede"),
        axis.text.y = element_text(size = 8, colour = "#dfdede"),
        panel.background = element_rect(fill = "transparent"),
        plot.background = element_rect(fill = "transparent", color = NA)
      )
  }, bg = "transparent")


  # Move quality bar plot
  output$moveQualityPlot <- renderPlotly({
    dfMoveQuality %>%
      filter(
        Type %in% input$timeControlComp,
        Color %in% input$colorMoveQuality,
        Player %in% input$playerComp
      ) %>%
      mutate(
        Move = fct_reorder(Move, Procent, .desc = FALSE)
      ) -> dfMoveQualityPlot

    ggplot(data = dfMoveQualityPlot, aes(x = Procent, y = Move, fill = MoveColor)) +
      geom_col() +
      labs(x = "Percent", y = "Move type") +
      scale_fill_manual(values = unique(dfMoveQualityPlot$MoveColor)) +
      scale_x_continuous(expand = c(0, 0)) +
      theme(legend.position = "none") +
      theme(
        axis.title.x = element_text(size = 14, colour = "white"),
        axis.title.y = element_text(size = 14, colour = "white"),
        axis.text.x = element_text(size = 10, colour = "#dfdede"),
        axis.text.y = element_text(size = 10, colour = "#dfdede"),
        panel.background = element_rect(fill = "transparent"),
        plot.background = element_rect(fill = "transparent", color = NA)
      )
  })


  # Win rate plot
  # output$winRatePlot <- renderPlot({
  #   dfWinRate %>%
  #     filter(
  #       Type %in% input$timeControlComp,
  #       Player %in% input$playerComp
  #     ) -> dfWinRatePlot

  #   ggplot(dfWinRatePlot,
  #     aes(x = "", y = Matches, fill = Result)) +
  #     geom_col(width = 0.5) +
  #     geom_text(
  #       aes(label = paste(Percentages, "%")),
  #       position = position_stack(vjust = 0.5)
  #     ) +
  #     scale_fill_manual(values = dfWinRatePlot$Colors) +
  #     labs(x = "", y = "End Result") +
  #     theme_void() +
  #     theme(legend.position = "bottom") +
  #     theme(
  #       axis.title.x = element_text(size = 14, colour = "white"),
  #       axis.title.y = element_text(size = 14, colour = "white"),
  #       axis.text.x = element_text(size = 10, colour = "#dfdede"),
  #       axis.text.y = element_text(size = 10, colour = "#dfdede"),
  #       panel.background = element_rect(fill = "transparent"),
  #       plot.background = element_rect(fill = "transparent", color = NA)
  #     )

  # }, background = "transparent")
  output$winRatePlot <- renderPlotly({
    dfWinRate %>%
      filter(
        Type %in% input$timeControlComp,
        Player %in% input$playerComp
      ) -> dfWinRatePlot

    fig <- plot_ly(
      dfWinRatePlot,
      x = ~Player,
      y = ~Matches,
      color = ~Result
    ) %>%
    layout(
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)",
      title = list(
        y = 1,
        text = "Win rate plot",
        font = list(
          color = "white",
          size = 20
        )
      ),
      legend = list(
        font = list(
          color = "white",
          size = 12
        )
      ),
      font = list(color = "white"),
      yaxis = list(
        title = paste(
          "# of games played in",
          str_to_title(input$timeControlComp)
        )
      ),
      xaxis = list(title = paste("Player")),
      fill = ~Result,
      barmode = "stack"
    )
    ggplotly(fig)
  })
  
  
  output$timeLagElo <- renderUI({
    dfGamesData %>% filter(
      player %in% input$playerComp,
      timeControl %in% str_to_title(input$timeControlComp)
    ) -> df3
    tagList(
      tags$div(
        tags$div(HTML("From")),
        date_input(
          "date_from",
          value = min(df3$date, na.rm = TRUE),
          min = min(df3$date, na.rm = TRUE),
          max = max(df3$date, na.rm = TRUE)
        )
      ),
      br(),
      tags$div(
        tags$div(HTML("To")),
        date_input(
          "date_to",
          value = max(df3$date, na.rm = TRUE),
          min = min(df3$date, na.rm = TRUE),
          max = max(df3$date, na.rm = TRUE))
      )
    )
  })
  
  output$densPlot <- renderPlot({
    ggplot(data = dfGamesData %>% filter(player == "Kacper"), aes(x = endHour)) +
      geom_density(fill = "#96bc4b") +
      labs(x = "Hours of a day", y = "Density", title = "Kacper") +
      scale_x_continuous(limits = c(0, 24)) +
      scale_y_continuous(limits = c(0, 0.1)) +
      theme(
        axis.title.x = element_text(size = 14, colour = "white"),
        axis.title.y = element_text(size = 14, colour = "white"),
        axis.text.x = element_text(size = 10, colour = "white"),
        axis.text.y = element_text(size = 10, colour = "white"),
        legend.title = element_text(size = 14, colour = "white"),
        plot.title = element_text(size = 14, colour = "white"),
        panel.background = element_rect(fill = "transparent"),
        plot.background = element_rect(fill = "transparent", color = NA)
      ) -> p1
    ggplot(data = dfGamesData %>% filter(player == "Krzysiek"), aes(x = endHour)) +
      geom_density(fill = "#96af8b") +
      labs(x = "Hours of a day", y = "Density", title = "Krzysiek") +
      scale_x_continuous(limits = c(0, 24)) +
      scale_y_continuous(limits = c(0, 0.1)) +
      theme(
        axis.title.x = element_text(size = 14, colour = "white"),
        axis.title.y = element_text(size = 14, colour = "white"),
        axis.text.x = element_text(size = 10, colour = "white"),
        axis.text.y = element_text(size = 10, colour = "white"),
        plot.title = element_text(size = 14, colour = "white"),
        panel.background = element_rect(fill = "transparent"),
        plot.background = element_rect(fill = "transparent", color = NA)
      ) -> p2
    grid.arrange(p1, p2, ncol = 2)
  }, background = "transparent")

  # Generating gifs
  output$selected_gif <- renderImage({
      list(src = input$gif)
    },
    deleteFile = FALSE
  )
})
