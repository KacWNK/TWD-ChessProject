library(shiny)
library(shiny.semantic)
library(semantic.dashboard)

# options(semantic.themes = TRUE)
# options(shiny.custom.semantic = "www/")


header <- dashboardHeader(
  includeCSS("./www/header.css"),
  class = "dsHeader",
  logo_path = "logo.png",
  logo_align = "center",
  title = "Chess ExploRer",
  right = textOutput("creator"),
)

sidebar <- dashboardSidebar(size = "thin", color = "brown",
  sidebarMenu(
    includeCSS("./www/sidebar.css"),
    menuItem(text = "Home", tabName = "home", icon = icon("home")),
    menuItem(text = "Competition", tabName = "comp", icon = icon("trophy")),
    menuItem(text = "Map", tabName = "map", icon = icon("map")),
    menuItem(text = "Games", tabName = "games", icon = icon("chess board", lib = "font-awesome")),
    menuItem(text = "Reporitory", href = "https://github.com/KacWNK/TWD-ChessProject", icon = icon("github"))
  )
)

body <- dashboardBody(class = "dsBody", tabItems(
  includeCSS("./www/body.css"),
  tabItem(tabName = "home", p("home")),
  tabItem(tabName = "comp", p("comp")),
  tabItem(tabName = "map", p("map")),
  tabItem(tabName = "games", p("games"))
))

shinyUI(dashboardPage(
  title = 'ChessExploRer',
  header, sidebar, body,
  theme = "slate",
  class = "dsBodyOuter",
  sidebar_and_body_container_class = "dsPage"
))

