import browser_cookie3
import json
import time
from tqdm import tqdm
import requests
import re
from lxml import html

KRIST_URL = "https://www.chess.com/games/archive/krist0f23?gameOwner=other_game&gameType=live&timeSort=desc&gameTypes%5B0%5D=chess960&gameTypes%5B1%5D=daily&page="
BASE_URL = "https://www.chess.com/games/archive?gameOwner=my_game&gameTypes%5B0%5D=chess&gameTypes%5B1%5D=chess960&gameType=live&page="

id_regex = re.compile('data\-game\-id="(\d+)"')
cookie_jar = browser_cookie3.firefox(domain_name=".chess.com")
game_ids = []
json_obj = json.loads("[]")
for i in tqdm(range(1, 62)):
    r = requests.get(KRIST_URL + str(i), cookies=cookie_jar)
    print(r)
    new_ids = [match.group(1) 
               for match in id_regex.finditer(r.text)]
    game_ids.extend(new_ids)
    time.sleep(0.5)
    payload = {
        "ids": ",".join([str(id) for id in new_ids]),
        "types": ",".join(["game_live" for _ in range(len(new_ids))])
    }
    res = requests.post(
        "https://www.chess.com/callback/game/pgn-info",
        data = payload
    )
    print(res)
    json_obj.extend(json.loads(res.text))
    
with open("output.json", "w+") as f:
    json.dump(json_obj, f)

print(len(game_ids))
print(len(set(game_ids)))
