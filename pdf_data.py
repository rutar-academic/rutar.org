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


paper_page_counts = [
    len(PdfReader(pdf).pages) for pdf in Path("static/papers").glob("*.pdf")
]
note_page_counts = [
    len(PdfReader(pdf).pages) for pdf in Path("static/notes").glob("*.pdf")
]

if __name__ == "__main__":
    generated_data = {
        "papers": generate_pdf_data("static/papers"),
        "notes": generate_pdf_data("static/notes"),
    }
    print(generated_data)
    Path("data/pdf_data.json").write_text(json.dumps(generated_data))
