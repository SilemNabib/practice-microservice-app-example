FROM python:3.6-slim

# Install system dependencies required for building Python packages
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip3 install --no-cache-dir -r requirements.txt

COPY main.py .

RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV REDIS_CHANNEL=log_channel
ENV ZIPKIN_URL=""

EXPOSE 8080

CMD ["python3", "main.py"]