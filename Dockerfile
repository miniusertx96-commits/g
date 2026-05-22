FROM python:3.12-slim

LABEL maintainer="OSINT Toolkit"
LABEL description="Containerized OSINT investigation stack"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl wget unzip dnsutils whois nmap \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/osint-toolkit

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chmod +x setup.sh scripts/*.sh workflows/*.sh 2>/dev/null || true

RUN mkdir -p tools results config

EXPOSE 5001

ENTRYPOINT ["python3", "osint.py"]
CMD ["--status"]
