import json
import sys
from pathlib import Path
from subprocess import Popen
from shlex import join


def status_echo(cmd_list):
    print(join(cmd_list))
    return cmd_list


def load_papers(tname, dry_run=False):
    commands = [
        status_echo(
            [
                "gh",
                "release",
                "download",
                "--repo",
                f"rutar-academic/{Path(publ['links']['pdf']).stem}",
                "--pattern",
                "*.pdf",
                "--dir",
                f"static/{tname}/",
                "--clobber",
            ]
        )
        for publ in json.loads(Path(f"data/{tname}.json").read_text())
    ]
    if not dry_run:
        processes = [Popen(cmd) for cmd in commands]
        outputs = [p.wait(timeout=120) for p in processes]
        if not all(out == 0 for out in outputs):
            print(f"Error downloading files for '{tname}'")
            sys.exit(1)


def run_build():
    for tname in ("papers", "notes"):
        load_papers(tname, dry_run=False)


def run_dry():
    for tname in ("papers", "notes"):
        load_papers(tname, dry_run=True)


if __name__ == "__main__":
    dispatch = {"build": run_build, "dry": run_dry}
    try:
        dispatch[sys.argv[1]]()
    except KeyError:
        print("Error: invalid build command!")
        sys.exit(1)
