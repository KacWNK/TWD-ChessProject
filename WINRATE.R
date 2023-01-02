library(shiny)

library(ggplot2)
#bullet
bullet_matches <- c(927, 40, 919)
bullet_result <- c("Won", "Draw", "Lost")
bullet_colors <- c("grey", "darkred", "darkgreen")
bullet_percentages <- bullet_matches / sum(bullet_matches) * 100
bullet_percentages <- round(bullet_percentages, 2)
bullet_df <- data.frame(bullet_matches, bullet_result, bullet_colors, bullet_percentages)

# blitz
blitz_matches <- c(90, 5, 62)
blitz_result <- c("Won", "Draw", "Lost")
blitz_colors <- c("grey", "darkred", "darkgreen")
blitz_percentages <- blitz_matches / sum(blitz_matches) * 100
blitz_percentages <- round(blitz_percentages, 2)
blitz_df <- data.frame(blitz_matches, blitz_result, blitz_colors, blitz_percentages)

#quick
quick_matches<-c(33,4,15)
quick_result <- c("Won", "Draw", "Lost")
quick_colors <- c("grey", "darkred", "darkgreen")
quick_percentages <- quick_matches / sum(quick_matches) * 100
quick_percentages <- round(quick_percentages, 2)
quick_df <- data.frame(quick_matches, quick_result, quick_colors, quick_percentages)
ui <- fluidPage(
  titlePanel("Match Results"),
  sidebarLayout(
    sidebarPanel(
      radioButtons("game_type", "Game Type:",
                   choices = c("Bullet" = "bullet", "Blitz" = "blitz","Quick"="quick"))
    ),
    mainPanel(
      plotOutput("results_plot")
    )
  )
)

server <- function(input, output) {
  
  output$results_plot <- renderPlot({
    if (input$game_type == "bullet") {
      ggplot(bullet_df, aes(x = "", y = bullet_matches, fill = bullet_result)) +
        geom_col(width = 0.5) +
        geom_text(aes(label = paste(bullet_percentages, "%")), position = position_stack(vjust = 0.5)) +
        scale_fill_manual(values = bullet_colors) +
        labs(title = "Match Results", x = "", y = "Number of Matches") +
        theme(plot.title = element_text(hjust = 0.5),
              plot.background = element_rect(fill = "transparent")) +
        coord_flip()
    } else if (input$game_type == "blitz") {
      ggplot(blitz_df, aes(x = "", y = blitz_matches, fill = blitz_result)) +
        geom_col(width = 0.5) +
        geom_text(aes(label = paste(blitz_percentages, "%")), position = position_stack(vjust = 0.5)) +
        scale_fill_manual(values = blitz_colors) +
        labs(title = "Match Results", x = "", y = "Number of Matches") +
        theme(plot.title = element_text(hjust = 0.5),
              plot.background = element_rect(fill = "transparent")) +
        coord_flip()
    } else if(input$game_type=="quick"){
      ggplot(quick_df, aes(x = "", y = quick_matches, fill = quick_result)) +
        geom_col(width = 0.5) +
        geom_text(aes(label = paste(quick_percentages, "%")), position = position_stack(vjust = 0.5)) +
        scale_fill_manual(values = quick_colors) +
        labs(title = "Match Results", x = "", y = "Number of Matches") +
        theme(plot.title = element_text(hjust = 0.5),
              plot.background = element_rect(fill = "transparent")) +
        coord_flip()
    }
  })
}

shinyApp(ui, server)
