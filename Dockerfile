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

# Expose port (Railway uses PORT env var)
EXPOSE 8080

# Default environment variables
ENV PORT=8080
ENV HOST=0.0.0.0

# Command to run the Meta Ads MCP server with HTTP transport
# Use /bin/sh -c to ensure variable expansion works
CMD ["/bin/sh", "-c", "python -m meta_ads_mcp --transport streamable-http --host $HOST --port $PORT"] 