import json
import subprocess
from pathlib import Path
def clean_tmp_dir():
    for child in Path('tmp').iterdir():
        child.unlink()

def download_release_files():
    with open("data/publications.json") as json_file:
        data = json.load(json_file)

    for entry in data:
        clean_tmp_dir()
        db_name = entry["database"]

        # download the release files corresponding to the entry
        subprocess.run(['gh', 'release', 'download',
                    '-R', db_name,
                    '--pattern', '*.pdf',
                    '-D', 'tmp'],
                    check=True)

        # check that there is exactly one file downloaded
        downloaded_paths = list(Path('tmp').iterdir())
        if len(downloaded_paths) != 1:
            print(f"Error: could not download appropriate release file from '{db_name}]")

        else:
            # rename to the appropriate .pdf name as specified in the database
            downloaded_file = downloaded_paths[0]
            print(f"Retreived '{downloaded_file.name}' from repo '{db_name}'.")
            downloaded_file.rename('static' / Path(entry["links"]["pdf"]))



paper_dir = Path('static/papers')
if __name__ == "__main__":
    download_release_files()
