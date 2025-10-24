#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = "==3.14"
# ///

import json
from datetime import datetime
from pathlib import Path

if __name__ == "__main__":
    travel_dict = json.loads(Path("data/where.json").read_text())["travel"]
    past_travel = [
        tr
        for tr in travel_dict
        if datetime.strptime(tr["date_end"], "%Y-%m-%d") <= datetime.today()
    ]
    Path("data/generated/past_travel.json").write_text(json.dumps(past_travel))
