from pypdf import PdfReader
from pathlib import Path
import json


def generate_pdf_data(pdf_dir):
    page_counts = [len(PdfReader(pdf).pages) for pdf in Path(pdf_dir).glob("*.pdf")]
    return {
            "page_count": sum(page_counts),
            "average_page_count": round(sum(page_counts) / len(page_counts), 1),
            "num_files": len(page_counts),
        }


if __name__ == "__main__":
    generated_data = {
        "papers": generate_pdf_data("static/papers"),
        "notes": generate_pdf_data("static/notes"),
    }
    Path("data/pdf_data.json").write_text(json.dumps(generated_data))
