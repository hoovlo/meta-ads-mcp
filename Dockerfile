FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install uv
RUN pip install --upgrade pip && \
    pip install uv

# Copy requirements file
COPY requirements.txt .

# Install dependencies using uv with --system flag
RUN uv pip install --system -r requirements.txt

# Copy the rest of the application
COPY . .

# Install the package
RUN pip install -e .

# Fix potential Windows line endings (CRLF -> LF) and make executable
RUN sed -i 's/\r$//' start.sh && chmod +x start.sh

# Expose port (Railway uses PORT env var)
EXPOSE 8080

# Default environment variables
ENV PORT=8080
ENV HOST=0.0.0.0

# Run directly with Python - the server.py now handles $PORT expansion
# This is more robust than relying on shell variable expansion
CMD ["python", "-m", "meta_ads_mcp", "--transport", "streamable-http", "--host", "0.0.0.0", "--port", "$PORT"] 