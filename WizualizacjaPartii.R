library(shiny)
library(animation)

# create the Shiny app
ui3 <- fluidPage(
  # create a dropdown menu for selecting a gif
  selectInput("gif", "Select a gif:", 
              choices = c("Immortal game- Kacper(white)" = "C:/Users/Kacper/Documents/KW_immortalGame.gif",
                          "First game- Kacper(white)" = "C:/Users/Kacper/Documents/KacperPierwszaPartia.gif",
                          "Immortal game- Krzysiek"="C:/Users/Kacper/Documents/gigachad-chad.gif",
                          "First game- Krzysiek(white)"="C:/Users/Kacper/Documents/Krzysiu_pierwszaPartia.gif")),
  # display the selected gif
  imageOutput("selected_gif")
)

server <- function(input, output, session) {
  # output the selected gif to the app
  output$selected_gif <- renderImage({
    list(src = input$gif)
  }, deleteFile = FALSE)
}

# run the Shiny app
shinyApp(ui3, server)
