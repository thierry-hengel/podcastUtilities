# 🎙️ Podcast Utilities

A robust Python-based toolkit designed to automate podcast management, including audio-to-video conversion for YouTube, statistics tracking, and multi-platform social media promotion.

---

## ⚖️ License (Non-Commercial Use Only)

This project is licensed under the **Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License (CC BY-NC-SA 4.0)**.

**Key Restrictions:**
* **Commercial Use is Strictly Forbidden**: You may not use this material for commercial advantage or monetary compensation.
* **Attribution (BY)**: You must give appropriate credit to the original author.
* **ShareAlike (SA)**: If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

See the `LICENSE` file for the full legal text.

---

## 🌟 Key Features

### 1. Centralized Web Interface
A modern web dashboard to manage your daily tasks:
* **Social Networks Manager**: Generate and publish posts on **Discord, Facebook, and X (Twitter)** using YAML templates.
* **Statistics Monitor**: Trigger and follow engagement data synchronization.

### 2. Automated Statistics Tracker
Automatically retrieves data from podcast hosts and YouTube views. Data is securely stored in **MariaDB** or **SQLite**.

### 3. YouTube Automation
Convert audio episodes into high-quality videos (incorporating logos and dynamic overlays) and automates the upload process to YouTube.

---

## 🚀 Deployment (Docker Only)

This project is delivered as a protected distribution. The source code is obfuscated to ensure security and integrity while remaining "plug-and-play".

### Prerequisites
* Docker and Docker Compose installed.
* Storage: Ensure at least 5GB of free disk space
* A `.env` file for credentials.

### 2. Configuration Setup
Before launching the application, you must set up your environment variables:

1.  **Create your secret file**: Copy the provided template to the project root.
    ```bash
    cp configuration/.env.example .env
    ```
2.  **Edit the file**: Open the new `.env` file and fill in your actual credentials (database passwords, API tokens for YouTube, Facebook, X, etc.).

### 3. Launching the Application
Navigate to the project's root folder and run:

1.  **Start all services**:
    ```bash
    docker compose up -d
    ```
2.  **Access the Web UI**: Open your browser at `http://localhost:8501` or `http://your_local_server_ip:8501`

---

## 📁 Persistent Data
The following folders are mapped to your host machine to ensure data persistence:
* `/config`: Your `.ini` configuration files.
* `/profiles`: Your Firefox browser sessions (keeps you logged in).
* `/downloads`: Statistics files retrieved by the bot.
* `/logs`: Application execution logs.

---

## 📜 Changelog

All notable changes to this project are documented in the [CHANGELOG.md](./CHANGELOG.md) file.