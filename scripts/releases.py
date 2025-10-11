import json
import sys
from pathlib import Path
from subprocess import Popen
from shlex import join


def status_echo(cmd_list):
    print(join(cmd_list))
    return cmd_list


def dbg(e):
    print(e)
    return e


def get_file_list(block_size=8):
    all_publ = [
        Path(publ["links"]["pdf"])
        for tname in ["papers", "notes"]
        for publ in json.loads(Path(f"data/{tname}.json").read_text())
        if not (Path("static") / publ["links"]["pdf"]).exists()
    ]
    return [all_publ[i : i + block_size] for i in range(0, len(all_publ), block_size)]


def load_papers(block, dry_run=False):
    commands = [
        status_echo(
            [
                "gh",
                "release",
                "download",
                "--repo",
                f"rutar-academic/{publ.stem}",
                "--pattern",
                "*.pdf",
                "--dir",
                f"static/{publ.parent}",
                "--clobber",
            ]
        )
        for publ in block
    ]
    if not dry_run:
        processes = [Popen(cmd) for cmd in commands]
        outputs = [p.wait(timeout=120) for p in processes]
        if not all(out == 0 for out in outputs):
            print("Error downloading files!")
            sys.exit(1)


if __name__ == "__main__":
    for block in get_file_list():
        load_papers(block)
