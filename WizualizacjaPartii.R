library(shiny)
library(animation)

# create the Shiny app
ui3 <- fluidPage(
  # create a dropdown menu for selecting a gif
  selectInput("gif", "Select a gif:", 
              choices = c("Legendarna Partia gracz-Kacper(białe)" = "C:/Users/Kacper/Documents/KW_immortalGame.gif",
                          "Pierwsza Partia gracz-Kacper(białe)" = "C:/Users/Kacper/Documents/KacperPierwszaPartia.gif",
                          "Legendarna Partia gracz-Krzysiek"="C:/Users/Kacper/Documents/gigachad-chad.gif",
                          "Pierwsza Partia gracz-Krzysiek(białe)"="C:/Users/Kacper/Documents/Krzysiu_pierwszaPartia.gif")),
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
