library(shiny)
library(shiny.semantic)
library(shiny.router)

# TODO adjust to new version of shiny.router

# Hint: semanticui
#
# Div classes in the UI of this applications are created for semanticui package.
# Thanks to that we get nice looking interface in our application.
# Read more: https://github.com/Appsilon/semanticui

menu <- (
      div(class = "ui horizontal menu",
          a(class = "item", href = route_link("index"), icon("home"), "Page"),
          a(class = "item", href = route_link("other"), icon("clock"), "Other")
      )
)

page <- function(title, content) {
  div(class = "ui container",
      style = "margin-top: 1em",
      div(class = "ui grid",
          div(class = "two wide row",
              menu
          ),
          div(class = "three wide row",
              div(class = "ui segment",
                  h1(title),
                  p(content)
              )
          ),
        div(class = "tree wide row",
            actionButton(
              "button",
              "click",
              class = "ui labeled icon button",
              icon = icon("calendar"),
            )
        )
      )
  )
}

root_page <- page("Home page", "Welcome on sample routing page!")
other_page <- page("Some other page", "Lorem ipsum dolor sit amet.")

router <- make_router(
  route("index", root_page),
  route("other", other_page)
)

ui <- semanticPage(
  title = "Router demo",
  router$ui
)

server <- function(input, output, session) {
  
  router$server(input, output, session)
  
}

shinyApp(ui, server)