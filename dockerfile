# ==========================================
# STAGE 1: Builder (Compilation phase)
# ==========================================

# Using a slim version of Python 3.11 to keep the image lightweight
FROM python:3.11-slim AS builder

# Prevent Python from writing .pyc files and enable unbuffered logging for Docker
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /build

# Install compilation dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    libmariadb-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies needed for compilation (Cython, etc.)
COPY requirements.txt .
RUN pip install --no-cache-dir Cython setuptools
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code and compilation script
COPY . .

# Run Cython compilation (generates .so files)
RUN python compile_project.py build_ext --inplace

# ==========================================
# STAGE 2: Final Production Image
# ==========================================

# Using a slim version of Python 3.11 to keep the image lightweight
FROM python:3.11-slim

# Re-declare environment variables for the final stage
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Define app data path as an environment variable
ENV APP_DATA_PATH=/app/data

# Install runtime dependencies (Selenium, FFmpeg, MariaDB)
RUN apt-get update && apt-get install -y \
    firefox-esr \
    ffmpeg \
    libmariadb-dev \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Geckodriver (Multi-arch support)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then GECKODRIVER_ARCH="linux64"; else GECKODRIVER_ARCH="linux-aarch64"; fi && \
    wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-$GECKODRIVER_ARCH.tar.gz && \
    tar -xvzf geckodriver-v0.33.0-$GECKODRIVER_ARCH.tar.gz -C /usr/local/bin/ && \
    rm geckodriver-v0.33.0-$GECKODRIVER_ARCH.tar.gz

WORKDIR /app

# Ccopy the pre-installed and compiled site-packages from the builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# --- 🔐 SECURITY STEP: COPY COMPILED FILES & GHOST FILES ---

# 1. Copy only the entry point (must remain .py for Streamlit/Python execution)
COPY --from=builder /build/podcastUtilities.py .

# 2. Copy the compiled modules (.so files) from the builder
# This brings the logic from my_*.py without bringing the source code
COPY --from=builder /build/*.so .

# 3. Copy the compiled pages from the builder (keeping directory structure)
RUN mkdir -p pages
COPY --from=builder /build/pages/*.so ./pages/

# --- TIPS FOR STREAMLIT GHOST FILES ---
RUN find ./pages -name "*.so" -exec sh -c 'touch "${1%.*}.py"' _ {} \;

# Create necessary directories for persistence
RUN mkdir -p ${APP_DATA_PATH}/Downloads \
             ${APP_DATA_PATH}/firefox_profile_selenium \
             ${APP_DATA_PATH}/logs \
             /app/configuration

# Set permissions
RUN chmod -R 777 ${APP_DATA_PATH} /app/configuration

# Expose Streamlit default port
EXPOSE 8501

# 6. Start the application
CMD ["streamlit", "run", "podcastUtilities.py", "--server.port=8501", "--server.address=0.0.0.0"]