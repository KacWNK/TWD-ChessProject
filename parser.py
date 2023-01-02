import pandas as pd
import numpy as np
from dataclasses import dataclass
import json
from chess_com_extractor.tcn import decode_tcn
import chess
import chess.pgn
from chess import Move
from typing import Iterable
import re


def generate_pgn(tcnMoves: Iterable[Move]) -> str:
    game = chess.pgn.Game()
    moves = decode_tcn(tcnMoves)
    game.add_line(moves)
    raw_pgn = game.__str__().split("\n\n")[-1]
    return re.sub("(\d+\.) ", "\\1", raw_pgn)
    

with open("./output.json", "rb") as json_file:
    json_reader = json.load(json_file)
    for json_game in json_reader:

        tcnMoves = json_game["tcnMoves"]
        board = chess.Board()
        game = chess.pgn.Game()
        generate_pgn(tcnMoves)
        # Player 1 plays allwasy white
        print(json_game["player1Name"])



