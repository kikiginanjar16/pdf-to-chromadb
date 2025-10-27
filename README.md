pdf-to-chromadb

Ingest PDF files into a local ChromaDB and expose a simple RAG API to query them using Sentence-Transformers embeddings. This app provides HTTP endpoints via FastAPI and can be run locally or in Docker.

What It Does
- Extracts text from PDFs with `pdfplumber` and chunks it.
- Embeds chunks using `sentence-transformers` (default MiniLM model).
- Stores vectors in a persistent on-disk Chroma collection.
- Serves two endpoints: `/ingest` and `/query`.

Requirements
- Python 3.10+
- See `requirements.txt` for Python packages.

Setup
- Install dependencies:
  pip install -r requirements.txt

- Run the API:
  python main.py

API Endpoints
- POST `/ingest`
  - Form fields:
    - `db` (str, default `./chroma_db`): path to Chroma dir
    - `embed_model` (str, default `sentence-transformers/all-MiniLM-L6-v2`)
    - `files` (one or more PDFs, multipart form)
  - Response: `{ status, pdfs, db }`

- POST `/query`
  - Form fields:
    - `q` (str): your question/query
    - `db` (str, default `./chroma_db`)
    - `top_k` (int, default 5)
    - `embed_model` (str, default `sentence-transformers/all-MiniLM-L6-v2`)
  - Response: `{ contexts: [{ text, source, distance }, ...] }`

Local Examples
- Ingest PDFs via curl (adjust paths on Windows PowerShell):
  curl -X POST http://localhost:8000/ingest ^
    -F db=./chroma_db ^
    -F embed_model=sentence-transformers/all-MiniLM-L6-v2 ^
    -F files=@"path/to/file1.pdf" ^
    -F files=@"path/to/file2.pdf"

- Query:
  curl -X POST http://localhost:8000/query ^
    -F q="What does the document say about X?" ^
    -F db=./chroma_db ^
    -F top_k=5

Docker
- Build:
  docker build -t pdf-to-chromadb .

- Run server:
  docker run --rm -p 8000:8000 -v %cd%/chroma_db:/app/chroma_db pdf-to-chromadb

- Ingest (mount PDFs):
  docker run --rm -p 8000:8000 -v %cd%/chroma_db:/app/chroma_db -v %cd%/pdfs:/app/pdfs pdf-to-chromadb \
    python main.py && curl -X POST http://localhost:8000/ingest ^
    -F db=/app/chroma_db ^
    -F files=@"/app/pdfs/your.pdf"

Notes
- First run downloads the embedding model (internet required).
- For Windows PowerShell, use `^` for line continuation. On bash, use `\`.
