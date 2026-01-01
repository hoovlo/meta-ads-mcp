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

# Make start script executable
RUN chmod +x start.sh

# Expose port (Railway uses PORT env var)
EXPOSE 8080

# Default environment variables
ENV PORT=8080
ENV HOST=0.0.0.0

# Use startup script for proper variable expansion
CMD ["./start.sh"] 