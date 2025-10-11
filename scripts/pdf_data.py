from pypdf import PdfReader
from pathlib import Path
from collections import Counter
import json


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
        path = Path("static") / paper["links"]["pdf"]
        print(path)
        paper["page_count"] = len(
            PdfReader(Path("static") / paper["links"]["pdf"]).pages
        )

    Path("data/generated/papers_extended.json").write_text(json.dumps(paper_data))

    generated_data = {
        "papers": generate_pdf_data(paper_data),
        "talks": generate_talk_types("data/talks.json"),
    }
    Path("data/generated/pdf_data.json").write_text(json.dumps(generated_data))
