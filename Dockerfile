FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps for popular PDF parsers (optional but helpful)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    poppler-utils \
    && rm -rf /var/lib/apt/lists/*

# Copy only what we need first to leverage Docker layer caching
COPY main.py /app/main.py

# If you have a requirements.txt, uncomment the following two lines and ensure the file exists
# COPY requirements.txt /app/requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt || true

# Minimal installs based on typical libs used by sentence-transformers and chromadb
RUN pip install --no-cache-dir \
    chromadb \
    sentence-transformers \
    pypdf \
    pdfminer.six

CMD ["python", "main.py", "--help"]

