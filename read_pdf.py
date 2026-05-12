import sys
from pypdf import PdfReader

try:
    reader = PdfReader('Requirements Specification For RKCNL(1)(1).pdf')
    text = ""
    for page in reader.pages:
        text += page.extract_text() + "\n"
    
    with open('parsed_requirements.txt', 'w', encoding='utf-8') as f:
        f.write(text)
    print("Success")
except Exception as e:
    print(f"Error: {e}")
