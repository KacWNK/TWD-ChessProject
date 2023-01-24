library(shiny)
library(shiny.semantic)
library(shiny.dashboard)

ui <- semanticPage(
  title = "My first page",
  h1("My page"),
  sidebar_layout(
    sidebar_panel(
      p("Select variable for plots:"),
      dropdown_input("mtcars_dropdown", c("mpg", "cyl", "disp", "hp"), value = "mpg")
    ),
    main_panel(
      segment(
        cards(
          class = "two",
          card(class = "green",
               div(class = "content",
                   div(class = "header", "Main title card 1"),
                   div(class = "meta", "Sub title card 1"),
                   div(class = "description", "More detail description card 1")
               )
          ),
          card(class = "red",
               div(class = "content",
                   div(class = "header", "Main title card 2"),
                   div(class = "meta", "Sub title card 2"),
                   div(class = "description", "More detail description card 2")
               )
          )
        )
      ),
      div(class = "ui container",
        plotOutput("histogram"),
      ),
    )
  )
)

server <- function(input, output, session) {
  output$dropdown <- renderText(input$mtcars_dropdown)
  output$histogram <- renderPlot(hist(mtcars[[input$mtcars_dropdown]]))
  output$plot <- renderPlot(plot(mtcars[[input$mtcars_dropdown]]))
}

shinyApp(ui, server)