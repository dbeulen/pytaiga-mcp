# Use the official uv image for efficient dependency management
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

# Set working directory
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy project configuration files and source code
# We need src/ and README.md because the project is installed as a package
COPY pyproject.toml uv.lock README.md ./
COPY src ./src

# Install git as it's required to fetch the pytaigaclient dependency from GitHub
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Install dependencies using uv
# --frozen ensures we use the exact versions from uv.lock
# --no-dev excludes development dependencies
RUN uv sync --frozen --no-dev

# Copy the rest of the application (tests, scripts, etc.)
COPY . .

# Set environment variable defaults
ENV TAIGA_API_URL=http://localhost:9000 \
    TAIGA_TRANSPORT=sse \
    LOG_LEVEL=INFO

# Expose the default port for SSE transport
EXPOSE 8000

# Set the command to run the MCP server with SSE transport
CMD ["uv", "run", "python", "src/server.py", "--sse", "--port", "8000"]
