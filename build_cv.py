from jinja2 import FileSystemLoader, Environment, select_autoescape
import subprocess
from pathlib import Path
import json
from datetime import datetime


def make_auth_string(auth_list):
    match len(auth_list):
        case 0:
            return ""
        case 1:
            return f"(with {auth_list[0]}) "
        case 2:
            return f"(with {auth_list[0]} and {auth_list[1]}) "
        case _:
            return f"(with {', '.join(auth_list[:-1])}, and {auth_list[-1]}) "


def make_journal_ref(pages, journal, vol, year):
    return f"{journal} \\textbf{{{vol}}} ({year}), {pages}"


def make_ref(entry, journal_data):
    match entry["status"]:
        case "published":
            return make_journal_ref(
                f"{entry['ref']['page_start']}--{entry['ref']['page_end']}",
                journal_data[entry["ref"]["journal"]]["name"],
                entry["ref"]["vol"],
                entry["ref"]["year"],
            )
        case "submitted":
            return f"Preprint. \\href{{https://arxiv.org/abs/{entry['links']['arxiv']}}}{{\\texttt{{arxiv:{entry['links']['arxiv']}}}}}"

        case "accepted":
            return f"To appear in: \\textit{{{journal_data[entry['ref']['journal']]['name']}}}"


def normalize_publ_data(entry, auth_data, journal_data):
    return {
        "title": entry["title"],
        "with": make_auth_string(
            [auth_data[auth]["short_name"] for auth in entry.get("with", [])]
        ),
        "ref": make_ref(entry, journal_data),
    }


def format_currency(value, currency):
    currency_symbol = {"CAD": "\\$", "EUR": "€", "GBP": "£"}
    return f"{currency_symbol[currency]}{value:,}"


def run():
    env = Environment(
        loader=FileSystemLoader("cv"),
        autoescape=select_autoescape(),
        block_start_string=r"\BLOCK{",
        block_end_string="}",
        variable_start_string=r"\VAR{",
        variable_end_string="}",
        comment_start_string=r"\#{",
        comment_end_string="}",
        line_statement_prefix="%%",
        line_comment_prefix="%#",
        trim_blocks=True,
    )

    # get publication data
    publ_data = json.loads(Path("data/papers.json").read_text())
    auth_data = json.loads(Path("data/people.json").read_text())
    journal_data = json.loads(Path("data/journals.json").read_text())
    publ = [normalize_publ_data(entry, auth_data, journal_data) for entry in publ_data]

    # get talk data
    talk_data = json.loads(Path("data/talks.json").read_text())
    talks = [
        {
            "date": datetime.strptime(talk["date"], "%Y-%m-%d").strftime("%Y.%m"),
            "title": talk["title_latex"]
            if "title_latex" in talk.keys()
            else talk["title"],
            "venue": talk["venue"],
        }
        for talk in talk_data
    ]
    talks.sort(reverse=True, key=lambda talk: talk["date"])

    cv_data = json.loads(Path("data/cv.json").read_text())
    # get award data
    award_data = cv_data["awards"]
    awards = [
        {
            "year": award["year"],
            "name": award["name"],
            "source": award["source"],
            "value": format_currency(award["value"], award["currency"]),
        }
        for award in award_data
    ]

    # get funding data
    fund_data = cv_data["funding"]
    funding = [
        {
            "year": fund["year"],
            "name": fund["name"],
            "value": format_currency(fund["value"], fund["currency"]),
        }
        for fund in fund_data
    ]

    # get date of current commit
    completed_proc = subprocess.run(
        ["git", "log", "-1", "--format=%ci"], capture_output=True
    )
    git_commit_date = datetime.strptime(
        completed_proc.stdout.decode("ascii").split(" ")[0], "%Y-%m-%d"
    ).strftime("%B %-d, %Y")

    # write main tex file
    template = env.get_template("alex_rutar_cv.tex")
    Path("build").mkdir(exist_ok=True)
    Path("build/alex_rutar_cv.tex").write_text(
        template.render(
            publications=publ,
            talks=talks,
            today=git_commit_date,
            awards=awards,
            funding=funding,
            personal=cv_data["personal"],
            skills=cv_data["skills"],
            education=cv_data["education"],
        )
    )

    # copy in macro file
    Path("build/mathcv.cls").write_text(Path("cv/mathcv.cls").read_text())


def get_priority_val(entry):
    for key in ["zbl", "doi", "arxiv"]:
        val = entry["links"].get(key)
        if val is not None:
            return f"{key}:{val}"


if __name__ == "__main__":
    run()
