setwd("~/Code/chess_parser")
devtools::build("./kaRpov")
devtools::install_local("/home/zetrext/Code/chess_parser/kaRpov_0.1.0.tar.gz")

library(kaRpov)
library(stringr)
ffbrary(dplyr)

#the pgn for the immortal game
immortal_pgn <- "1.e4 e5 2.f4 exf4 3.Bc4 Qh4+ 4.Kf1 b5 5.Bxb5 Nf6 6.Nf3 Qh6 7.d3 Nh5 8.Nh4 Qg5 9.Nf5 c6 10.g4 Nf6 11.Rg1 cxb5 12.h4 Qg6 13.h5 Qg5 14.Qf3 Ng8 15.Bxf4 Qf6 16.Nc3 Bc5 17.Nd5 Qxb2 18.Bd6 Bxg1 19.e5 Qxa1+ 20.Ke2 Na6 21.Nxg7+ Kd8 22.Qf6+ Nxf6 23.Be7#"

pgn <- "1. e4  e5 2. Nf3  Nc6 3. Bc4  Nf6 4. d4  exd4 5. O-O  Nxe4 6. Re1  d5 7. Bxd5  Qxd5 8. Nc3  Qa5 9. Nxe4  Be6 10. Bd2  Qf5 11. Bg5  Bb4 12. Nxd4  Nxd4 13. Qxd4  Bf8 14. Rad1  f6 15. Qd7+  Bxd7 16. Nd6+  Kd8 17. Nf7+  Kc8 18. Re8+  Bxe8 19. Rd8#"
pgn <- pgn %>%
  str_replace_all("  ", "00") %>%
  str_replace_all("(\\d\\.) ", "\\1") %>%
  str_replace_all("00", " ")

pgn2 <- "1.e4 e5 2.Nf3 Nc6 3.Bc4 Nf6 4.d4 exd4 5.O-O Nxe4 6.Re1 d5 7.Bxd5 Qxd5 8.Nc3 Qa5 9.Nxe4 Be6 10.Bd2 Qf5 11.Bg5 Bb4 12.Nxd4 Nxd4 13.Qxd4 Bf8 14.Rad1 f6 15.Qd7+ Bxd7 16.Nd6+ Kd8 17.Nf7+ Kc8 18.Re8+ Bxe8 19.Rd8#"

immortal_pgn
pgn

filename <- "~/Code/chess_parser"

#need to fix library importing
library(tweenr)
library(animation)
library(ggplot2)
library(grid)
library(png)

#create the gif
plot_pgn(pgn2, 
          light_col = "#f5f5dc", dark_col = "#00688b", square_labels = FALSE, plot = FALSE,
          move_cutoff = NULL, frames = 100, interpolation = 0.5,
          speed = 10, pause_end = TRUE, black_shift = NULL,
          name = filename)

