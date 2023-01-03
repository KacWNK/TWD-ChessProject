import pandas as pd
import time
from tqdm import tqdm 
import numpy as np
from dataclasses import dataclass
import json
import datetime
from chess_com_extractor.tcn import decode_tcn
import chess
import chess.pgn
from chess import Move
from typing import Iterable
import re

from pandas._libs import index


def generate_pgn(tcnMoves: Iterable[Move]) -> str:
    game = chess.pgn.Game()
    moves = decode_tcn(tcnMoves)
    game.add_line(moves)
    raw_pgn = game.__str__().split("\n\n")[-1]
    return re.sub("(\d+\.) ", "\\1", raw_pgn)
    

with open("./output.json", "rb") as json_file:
    json_reader = json.load(json_file)


def white_clock(timestamps):
    return " ".join([str(x) for i, x in enumerate(timestamps) if not i % 2])

def black_clock(timestamps):
    return " ".join([str(x) for i, x in enumerate(timestamps) if i % 2])

column_names = [
    "id",
    "timeControl",
    "result",
    "yourElo",
    "playingWhite",
    "enemyElo",
    "enemyName",
    "date",
    "endHour",
    "moves",
    "yourClock",
    "enemyClock"
]

df = pd.DataFrame()

for json_game in tqdm(json_reader[:-1]):
    tcnMoves = json_game["tcnMoves"]
    board = chess.Board()
    game = chess.pgn.Game()
    pgn = generate_pgn(tcnMoves)
    # Player 1 plays always white
    # 1 to wygrana
    # 4-4 to remis
    move_times = json_game["moveTimestamps"].split(",")
    is_playing_white = json_game["player1Name"] == "Chessmaster2799"
    if is_playing_white:
        your_name = json_game["player1Name"]
        enemy_name = json_game["player2Name"]
        your_elo = json_game["whiteRating"]
        enemy_elo = json_game["blackRating"]
        res_id = json_game["player1ResultID"]
        your_clock = white_clock(move_times)
        enemy_clock = black_clock(move_times)
        if res_id == 1:
            game_res = "win"
        elif res_id == 4:
            game_res = "draw"
        else:
            game_res = "lose"
    else:
        enemy_name = json_game["player1Name"]
        your_name = json_game["player2Name"]
        enemy_elo = json_game["whiteRating"]
        your_elo = json_game["blackRating"]
        res_id = json_game["player2ResultID"]
        enemy_clock = white_clock(move_times)
        your_clock = black_clock(move_times)
        if res_id == 4:
            game_res = "draw"
        elif res_id != 1:
            game_res = "lose"
        else:
            game_res = "win"

    date = str(datetime.date.fromtimestamp(json_game["startDate"])).replace("-", ".")
    game_id = json_game["gameId"]
    end_time = json_game["endTime"]
    time_control = json_game["timeControl"]

    row = {
        "id": game_id,
        "timeControl": time_control,
        "result": game_res,
        "yourElo": your_elo,
        "playingWhite": is_playing_white,
        "enemyElo": enemy_elo,
        "enemyName": enemy_name,
        "date": date,
        "endHour": end_time,
        "moves": pgn,
        "yourClock": your_clock,
        "enemyClock": enemy_clock
    }

    df_row = pd.DataFrame(row, columns=column_names, index=[0])
    df = pd.concat([df, df_row], axis = 0, ignore_index=True)

print(df)
df.set_index("id")
df = df[column_names]
file_name = f"{your_name}.csv"

df.to_csv(file_name)
print(f"Saved parsed csv to {file_name}")
