# --- Final Production Image ---
# Using a slim version of Python 3.11 to keep the image lightweight
FROM python:3.11-slim

# Prevent Python from writing .pyc files and enable unbuffered logging for Docker
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies for Selenium, MariaDB, and FFmpeg
# Includes Firefox-ESR and Geckodriver for automated browser tasks
RUN apt-get update && apt-get install -y \
    firefox-esr \
    ffmpeg \
    libmariadb-dev \
    gcc \
    wget \
    && wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz \
    && tar -xvzf geckodriver-v0.33.0-linux64.tar.gz -C /usr/local/bin/ \
    && rm geckodriver-v0.33.0-linux64.tar.gz \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1. Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 2. Inject protected code
# We ONLY copy the content of the 'dist' folder generated locally via PyArmor
# This ensures that no readable .py source files are ever included in the image
COPY dist/ .

# 3. Create necessary directories for mapped Docker volumes
# These match the volume paths defined in your docker-compose.yml
RUN mkdir -p downloads logs profiles configuration

# Expose Streamlit default port
EXPOSE 8501

# Start the application
# podcastUtilities.py is now the obfuscated version from the dist folder
CMD ["streamlit", "run", "podcastUtilities.py", "--server.port=8501", "--server.address=0.0.0.0"]