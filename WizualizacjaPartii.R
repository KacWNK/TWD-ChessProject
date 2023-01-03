library(shiny)
library(animation)


ui3 <- fluidPage(
  
  selectInput("gif", "Select a gif:", 
              choices = c("Immortal game- Kacper(white)" = "C:/Users/Kacper/Documents/KW_immortalGame.gif",
                          "First game- Kacper(white)" = "C:/Users/Kacper/Documents/KacperPierwszaPartia.gif",
                          "Immortal game- Krzysiek"="C:/Users/Kacper/Documents/gigachad-chad.gif",
                          "First game- Krzysiek(white)"="C:/Users/Kacper/Documents/Krzysiu_pierwszaPartia.gif")),
  
  imageOutput("selected_gif")
)

server <- function(input, output, session) {
  
  output$selected_gif <- renderImage({
    list(src = input$gif)
  }, deleteFile = FALSE)
}


shinyApp(ui3, server)
