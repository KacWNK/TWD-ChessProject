library(shiny)
library(shiny.semantic)
library(semantic.dashboard)

# options(semantic.themes = TRUE)
# options(shiny.custom.semantic = "www/")

source("server.R")

# HEADER
header <- dashboardHeader(
  includeCSS("./www/header.css"),
  class = "dsHeader",
  logo_path = "logo.png",
  logo_align = "center",
  title = "Chess ExploRer",
  right = div(
    id = "creator-container",
    textOutput("creator"),
  )
)

# SIDEBAR
sidebar <- dashboardSidebar(
  size = "thin",
  color = "brown",
  sidebarMenu(
    includeCSS("./www/sidebar.css"),
    menuItem(text = "Home",
      tabName = "home",
      icon = icon("home")),
    menuItem(text = "Competition",
      tabName = "comp",
      icon = icon("trophy")),
    menuItem(text = "Map",
      tabName = "map",
      icon = icon("map")),
    menuItem(text = "Games",
      tabName = "games",
      icon = icon("chess board",
        lib = "font-awesome")),
    menuItem(text = "Reporitory",
      href = "https://github.com/KacWNK/TWD-ChessProject",
      icon = icon("github"))
  )
)

###### HOME TAB ###### TODO
homeTab <- semanticPage(
  title = "My page",
  div(class = "flex center ",
      div(class = "ui button",
          icon("user"),
          "Icon button"
      )
  )
)

###### MAP TAB ######
mapTab <- semanticPage(
  title = "Map",
  div(class = "ui grid full-span",
    div(class = "row",
      multiple_radio(
        "fill_var", "Select type: ",
        choices = c("Win Ratio", "Average Accuracy"),
        choices_value = c("WinP", "Accuracy"),
        position = "inline"
      )
    ),
    div(class = "two column row",
        div(
          class = "column",
          plotOutput(outputId = "mapKacper")
        ),
        div(class = "column",
          plotOutput(outputId = "mapKrzysiek")
        )
    )
  )
)

###### GAMES TAB #######
gamesTab <- semanticPage(
  tilte = "Games",
  div(class = "ui grid",
      div(class = "row",
      selectInput(
        "gif", "Select a gif:",
        choices = c(
          "Immortal game- Kacper(white)" = "./resources/KW_immortalGame.gif",
          "First game- Kacper(white)" = "./resources/KacperPierwszaPartia.gif",
          "Immortal game- Krzysiek" = "./resources/gigachad-chad.gif",
          "First game- Krzysiek(white)" = "./resources/Krzysiu_pierwszaPartia.gif"
        )),
      ),
      div(class = "row",
          imageOutput("selected_gif")
      )
  )
)

###### COMPETITION TAB #######
panel_style <- "margin-left: 20px; border: solid 2px #dfdede; border-radius: 10px;"
### MAIN PLOT 1 - WIN RATE
compTabRow1 <- div(
  class = "row clear-bg",
  sidebar_layout(
    sidebar_panel(
      multiple_radio("typeWinRate",
                   "Choose time control",
                   selected = unique(dfWinRate$Type)[1],
                   choices = c("Bullet", "Blitz", "Rapid"),
                   choices_value = unique(dfWinRate$Type)
      ),
      br(), br(),
      multiple_radio("playerWinRate",
                   "Select a player",
                   selected = unique(dfWinRate$Player)[1],
                   choices = unique(dfWinRate$Player)
      ),
      width = 2
    ),
    main_panel(
      plotOutput("winRatePlot"),
      width = 10
    ),
    container_style = panel_style
  )
)

### MAIN PLOT 2 - MOVE QUALITY
compTabRow2 <- div(
  class = "row clear-bg",
  sidebar_layout(
    sidebar_panel(
      multiple_radio("colorMoveQuality",
                     "Choose color of pieces",
                     selected = unique(dfMoveQuality$Color)[1],
                     choices = c("White", "Black", "White and black"),
                     choices_value = unique(dfMoveQuality$Color)
      ),
      br(), br(),
      multiple_radio("playerMoveQuality",
                     "Select a player",
                     selected = unique(dfMoveQuality$Player)[1],
                     choices = unique(dfMoveQuality$Player)
      ),
      br(), br(),
      multiple_radio("typeMoveQuality",
                     "Choose time control",
                     selected = unique(dfMoveQuality$Type)[1],
                     choices = c("Bullet", "Blitz", "Rapid"),
                     choices_value = unique(dfMoveQuality$Type)
      ),
      width = 2
    ),
    main_panel(
      plotlyOutput("moveQualityPlot"),
      width = 10
    ),
    container_style = panel_style
  )
)

### MAIN PLOT 3 - ELO
compTabRow3 <- div(
  class = "row clear-bg",
  sidebar_layout(
    sidebar_panel(
      multiple_radio("playerElo",
                   "Select a player",
                   selected = unique(dfGamesData$player)[1],
                   choices = unique(dfGamesData$player)
      ),
      br(), br(),
      multiple_radio("typeElo",
                   "Choose time control",
                   selected = unique(dfGamesData$timeControl)[1],
                   choices = unique(dfGamesData$timeControl)
      ),
      br(), br(),
      uiOutput("timeLagElo"),
      width = 2
    ),
    main_panel(
      plotOutput("eloPlot"),
      width = 10
    ),
    container_style = panel_style
  )
)

### MAIN PLOTS COMBINED
compTab <- semanticPage(
  title = "Competition page",
  div(class = "ui grid",
      compTabRow1,
      compTabRow2,
      compTabRow3,
      div(
        class = "row",
        style = panel_style,
        plotOutput("densPlot")
      )
  )
)

# BODY
body <- dashboardBody(class = "dsBody", tabItems(
  includeCSS("./www/body.css"),
  tabItem(tabName = "home", homeTab),
  tabItem(tabName = "comp", compTab),
  tabItem(tabName = "map", mapTab),
  tabItem(tabName = "games", gamesTab)
))

# RUN APP
shinyUI(dashboardPage(
  title = "ChessExploRer",
  header, sidebar, body,
  theme = "slate",
  class = "dsBodyOuter",
  sidebar_and_body_container_class = "dsPage"
))
