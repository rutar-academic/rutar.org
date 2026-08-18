#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = "==3.14"
# dependencies = [
#   "jinja2==3.1.6",
# ]
# ///

import json
import subprocess
from datetime import datetime
from pathlib import Path

from jinja2 import Environment, FileSystemLoader, select_autoescape
from link_data import get_link


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
            if "article_no" in entry["ref"]:
                pages = f"Paper No.\\ {entry['ref']['article_no']}, {entry['ref']['page_count']} pp."
            else:
                pages = f"{entry['ref']['page_start']}--{entry['ref']['page_end']}"

            return make_journal_ref(
                pages,
                journal_data[entry["ref"]["journal"]]["name"],
                entry["ref"]["vol"],
                entry["ref"]["year"],
            )
        case "submitted":
            try:
                return f"arXiv Preprint, {entry['page_count']} pp."
            except KeyError:
                return "Preprint."

        case "accepted":
            return f"To appear in: {journal_data[entry['ref']['journal']]['name']}"

        case "expository":
            return f"Permanent Preprint. \\url{{https://rutar.org/{get_link(entry, 'pdf')}}}"


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

    source_data = {
        k: json.loads(Path(f"data/{k}.json").read_text())
        for k in ("generated/papers_extended", "people", "journals", "talks")
    }

    # get publication data
    publ = [
        normalize_publ_data(entry, source_data["people"], source_data["journals"])
        for entry in source_data["generated/papers_extended"]
        if entry["type"] == "research"
    ]

    # get expository data
    expository = [
        normalize_publ_data(entry, source_data["people"], source_data["journals"])
        for entry in source_data["generated/papers_extended"]
        if entry["type"] == "expository"
    ]

    # get talk data
    from collections import Counter

    talk_types = Counter(talk["type"] for talk in source_data["talks"])

    talks = {"types": talk_types, "total": sum(talk_types.values())}

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

    # get date of the most recent commit that modifies a relevant data file
    completed_proc = subprocess.run(
        ["git", "log", "-1", "--format=%ci", "--"]
        + [f"data/{k}.json" for k in source_data],
        capture_output=True,
        check=True,
    )
    git_commit_date = datetime.strptime(
        completed_proc.stdout.decode("ascii"), "%Y-%m-%d %H:%M:%S %z\n"
    ).strftime("%B %-d, %Y")

    # write main tex file
    template = env.get_template("alex_rutar_cv.tex")
    Path("build").mkdir(exist_ok=True)
    Path("build/alex_rutar_cv.tex").write_text(
        template.render(
            publications=publ,
            expository=expository,
            talks=talks,
            today=git_commit_date,
            awards=awards,
            funding=funding,
            personal=cv_data["personal"],
            skills=cv_data["skills"],
            education=cv_data["education"],
            work=cv_data["work"],
        )
    )

    # copy in macro file
    Path("build/mathcv.cls").write_text(Path("cv/mathcv.cls").read_text())


def get_priority_val(entry):
    for key in ["zbl", "doi", "arxiv"]:
        val = get_link(entry, key)
        if val is not None:
            return f"{key}:{val}"


if __name__ == "__main__":
    run()
