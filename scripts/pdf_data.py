#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = "==3.14"
# dependencies = [
#   "pypdf==6.1.3",
# ]
# ///

import json
from collections import Counter
from pathlib import Path

from link_data import get_link
from pypdf import PdfReader


def generate_pdf_data(paper_data):
    page_counts = [paper["page_count"] for paper in paper_data]
    return {
        "page_count": sum(page_counts),
        "average_page_count": round(sum(page_counts) / len(page_counts), 1),
        "num_files": len(page_counts),
    }


def generate_talk_types(talk_file):
    talk_data = json.loads(Path(talk_file).read_text())
    return Counter(item["type"] for item in talk_data)


if __name__ == "__main__":
    paper_data = json.loads(Path("data/papers.json").read_text())

    for paper in paper_data:
        path = Path("static") / get_link(paper, "pdf")
        paper["page_count"] = len(PdfReader(path).pages)

    Path("data/generated/papers_extended.json").write_text(json.dumps(paper_data))

    generated_data = {
        "papers": generate_pdf_data(paper_data),
        "talks": generate_talk_types("data/talks.json"),
    }
    Path("data/generated/pdf_data.json").write_text(json.dumps(generated_data))
