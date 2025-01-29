# Paperless-ngx 🗃️🤖

Paperless-ngx transforms your mountains of paper clutter into a sleek, searchable, digital archive. Deploy it on your Synology NAS and enjoy the magic of AI-powered document management. No more hunting for receipts like a pirate searching for treasure! 🏴‍☠️📄

---

## Overview 📝

This project is based on the great guides provided by [**Lixandru Marius Bogdan**](https://github.com/mariushosting). If you find his work helpful, consider supporting him!

- 📖 **[Paperless-ngx Setup](https://mariushosting.com/synology-install-paperless-ngx-with-office-files-support/)**
- 🤖 **[Paperless-ngx AI Setup](https://mariushosting.com/how-to-install-paperless-ai-on-your-synology-nas/)**
- 🧠 **[Ollama Setup](https://mariushosting.com/how-to-install-ollama-on-your-synology-nas/)**

This repository provides a Docker Compose configuration for deploying [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx), a powerful document management system, on a Synology NAS. This setup supports:

- **OCR-Powered Search** 🔍 – Scan, search, and retrieve documents with ease.
- **AI-Powered Categorization** 🤖 – Let Paperless-ngx AI auto-sort and tag your documents.
- **Local AI Model Serving** 🧠 – Run AI models locally with Ollama.
- **Office File Support** 📑 – Convert and manage `.docx`, `.pdf`, and other formats.
- **Synology NAS Friendly** 🏠 – Deploy with DSM Container Manager or Portainer.

---

## Configuring IPAM and Network Firewall 🌍

This project uses **Docker IPAM (IP Address Management)** to control container networking. You may need to configure your **firewall** to allow access based on the defined subnet.

### **IPAM Configuration**

You can configure the following settings in your [`.env`](example.env) file:

```bash
# Define the subnet range for the network
COMPOSE_NETWORK_SUBNET="${COMPOSE_NETWORK_SUBNET:-172.24.0.0/16}"

# Define the IP range for containers
COMPOSE_NETWORK_IP_RANGE="${COMPOSE_NETWORK_IP_RANGE:-172.24.5.0/24}"

# Define the network gateway
COMPOSE_NETWORK_GATEWAY="${COMPOSE_NETWORK_GATEWAY:-172.24.5.254}"
```

For more details, check the **[Docker Compose IPAM documentation](https://docs.docker.com/compose/compose-file/06-networks/#ipam)**.

---

## Deployment 🚀

This guide walks you through deploying Paperless-ngx using **DSM Container Manager** (recommended for Synology NAS). You can also use **Portainer** if you prefer a different UI.

### **1. Folders Are Pre-Created** 📂

No need to manually create folders—this project automatically sets them up in the `config` directory:

```console
config/
├── ollama/
│   ├── data/
│   ├── entrypoint/
│   ├── webui/
├── paperless-ai/
├── paperless-ngx/
│   ├── consume/
│   ├── data/
│   ├── db/
│   ├── export/
│   ├── media/
│   ├── redis/
│   ├── trash/
```

### **2. Copy and Edit the Environment File** 📜

A sample environment file is already included! Simply copy it and update the values as needed:

```sh
cp example.env .env
vim .env  # Edit with your settings
```

### **3. Deploy Using DSM Container Manager** 🏠

1. Open **DSM Container Manager**.
2. Navigate to **Projects** → Click **Create**.
3. Select **Import YAML** and browse to the `docker-compose.yml` file in the project root.
4. Click **Next** → Review settings → Click **Apply**.

### **4. Alternative Deployment with Portainer** 🖥️

If you prefer **Portainer**, follow these steps:

1. Go to **Stacks** in Portainer.
2. Click **Add Stack** → Name it `paperless`.
3. Browse to the `docker-compose.yml` file in the project root.
4. Click **Deploy the Stack**.

### **5. Access the Web Interfaces** 🌐

Once deployed, open your browser and access the services:

- **Paperless-ngx**: `https://paperlessngx.yourname.synology.me`
- **Ollama WebUI**: `https://ollama.yourname.synology.me`

Log in with your admin credentials and start managing documents and AI models! 🏆

---

## Docker Compose Configuration 🐳

The full `docker-compose.yml` file is included in the **project root**. Check it out if you want to tweak or customize your deployment.

📄 **[View docker-compose.yml](./docker-compose.yml)**

---

## Troubleshooting 🛠️

### **Paperless-ngx can't connect to Redis?** ❌

- Ensure your **firewall rules allow access** to the subnet defined in `COMPOSE_NETWORK_SUBNET`.
- Make sure your `.env` file has the correct `PAPERLESS_REDIS` value.
- Run `docker logs paperless` to check for errors.
- Try restarting the stack with `docker compose down && docker compose up -d`.

### **Ollama WebUI not connecting to Ollama?** 🤖

- Ensure the **OLLAMA_BASE_URL** in your `.env` is set correctly.
- Check if the **Ollama container is running**: `docker ps | grep ollama`
- Restart the Ollama service: `docker restart ollama`

### **Can't access the web interfaces?** 🌍

- Ensure the correct NAS IP and port are used.
- Run `docker ps` to check if all containers are running.

---

## Conclusion 🎉

Congratulations! 🎊 You've set up **Paperless-ngx and Ollama** on your Synology NAS. Now you can manage documents efficiently while running local AI models. 🚀🗃️🤖

For more advanced configurations, check out the [official Paperless-ngx documentation](https://paperless-ngx.readthedocs.io/) and [Ollama documentation](https://ollama.com/docs).
