
# Paperless-ngx Deployment on Synology NAS

This repository provides a Docker Compose configuration for deploying [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx), a document management system, on a Synology NAS, along with AI-powered document processing.

## Overview

Paperless-ngx transforms your physical documents into a searchable online archive, reducing paper clutter. This setup includes support for:

- **Office Files Support**: Convert and manage `.docx`, `.pdf`, and other document formats.
- **AI-Powered Categorization**: Automatically categorize and extract metadata from documents using `Paperless-ngx AI`.
- **OCR Processing**: Optical Character Recognition (OCR) ensures scanned documents are searchable.

## Features

- **Document Digitization**: Convert physical documents into structured, searchable digital formats.
- **Full-Text Search**: Quickly locate scanned documents with OCR text extraction.
- **Office File Compatibility**: Convert `.docx`, `.pptx`, `.xlsx` using Gotenberg and Apache Tika.
- **AI-Powered Processing**: Automate metadata extraction and document categorization with `Paperless-ngx AI`.
- **Web Interface**: Access and manage your document archive from any browser.

## Prerequisites

- **Synology NAS**: Ensure your NAS supports Docker.
- **Docker & Portainer**: Install Docker and Portainer on your Synology NAS.
- **Wildcard Certificate**: Obtain a `synology.me` wildcard certificate for HTTPS support.
- **Environment Variables**: Configure `.env` with the necessary variables.

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/scottgigawatt/paperless-ngx.git
```

### 2. Navigate to the Project Directory

```bash
cd paperless-ngx
```

### 3. Configure the Environment Variables

Rename `.env.example` to `.env` and modify the values to match your environment:

```bash
cp .env.example .env
vim .env  # Edit environment variables
```

### 4. Create Necessary Directories

Ensure the following directories exist on your NAS under the Docker folder:

```bash
mkdir -p /volume1/docker/paperlessngx/{consume,data,db,export,media,redis,trash,ai}
```

### 5. Deploy the Stack via Docker Compose

Run the following command to deploy the services:

```bash
docker compose up -d
```

### 6. Access Paperless-ngx

Once deployed, access the application at:

- **Paperless-ngx Web Interface**: `https://paperlessngx.yourname.synology.me`
- **Paperless-ngx AI Web Interface**: `http://localhost:3000`

## Services Overview

The following services are deployed via Docker:

- **Redis**: Provides in-memory caching and message queuing.
- **PostgreSQL**: Stores document metadata and user information.
- **Gotenberg**: Handles Office file conversion.
- **Apache Tika**: Extracts metadata and text from uploaded files.
- **Paperless-ngx**: The document management system, handling OCR and user interface.
- **Paperless-ngx AI**: AI-based document categorization and automation.

## Credits

This project is based on guides by **Marius Bogdan Lixandru**:

- **Paperless-ngx Setup**: [Guide](https://mariushosting.com/synology-install-paperless-ngx-with-office-files-support/)
- **Paperless-ngx AI Setup**: [Guide](https://mariushosting.com/how-to-install-paperless-ai-on-your-synology-nas/)

## License

This project is licensed under the Apache 2 License. See the [LICENSE](LICENSE) file for details.

---

For more information on Paperless-ngx, visit the [official GitHub repository](https://github.com/paperless-ngx/paperless-ngx).
