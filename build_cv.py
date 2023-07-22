from jinja2 import FileSystemLoader, Environment, select_autoescape
from pathlib import Path
import json
from datetime import datetime

def run():
    env = Environment(
        loader=FileSystemLoader("cv"),
        autoescape=select_autoescape(),
        block_start_string = r'\BLOCK{',
        block_end_string = '}',
        variable_start_string = r'\VAR{',
        variable_end_string = '}',
        comment_start_string = r'\#{',
        comment_end_string = '}',
        line_statement_prefix = '%%',
        line_comment_prefix = '%#',
        trim_blocks = True,
    )
    # get publication keys and save to 'nocites'
    publ_data = json.loads(Path('data/papers.json').read_text())
    cites_or_none = [get_priority_val(entry) for entry in publ_data]
    nocites = [ct for ct in cites_or_none if ct is not None]

    # get talk data
    talk_data = json.loads(Path('data/talks.json').read_text())
    talks = [
            {'date': datetime.strptime(talk['date'],'%Y-%m-%d').strftime('%Y.%m'),
             'title': talk['title_latex'] if 'title_latex' in talk.keys() else talk['title'],
             'venue': talk['venue']
             } for talk in talk_data]
    talks.sort(reverse=True, key=lambda talk: talk['date'])

    # create latex build directory

    # write main tex file
    template = env.get_template("main.tex")
    Path('cv_build').mkdir(exist_ok=True)
    Path('cv_build/alex_rutar_cv.tex').write_text(template.render(nocites=nocites, talks=talks))

    # copy in macro file
    Path('cv_build/mathcv.cls').write_text(Path('cv/mathcv.cls').read_text())


def get_priority_val(entry):
    for key in ['zbl', 'doi', 'arxiv']:
        val = entry["links"].get(key)
        if val is not None:
            return f"{key}:{val}"

if __name__ == '__main__':
    run()
