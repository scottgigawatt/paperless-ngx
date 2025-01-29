#!/bin/bash

#
# Ollama Container Entrypoint Script
#
# This script serves as the entrypoint for the Ollama container.
# It ensures that the Ollama server starts correctly, waits until it is ready,
# and then pulls the required models specified in the environment variables.
#
# Functionality:
# 1. Start the Ollama server.
# 2. Wait until the Ollama server is ready to accept connections.
# 3. Pull and update required models from the MODELS environment variable.
# 4. Keep the container running by waiting on the Ollama process.
#

# Enable strict error handling
set -euo pipefail

# Start Ollama server in the background
/bin/ollama serve &
pid=$!

# Wait for Ollama to be ready using TCP connection check on port 11434
while ! timeout 1 bash -c "echo > /dev/tcp/localhost/11434" 2>/dev/null; do
    echo "Waiting for Ollama to start..."
    sleep 1
done

echo "Ollama started successfully."

# Retrieve and install/update models from the MODELS environment variable
IFS=',' read -ra model_array <<< "${MODELS:-}"  # Split MODELS variable into an array

for model in "${model_array[@]}"; do
    if [[ -n "$model" ]]; then  # Ensure the model name is not empty
        echo "Installing/Updating model: $model..."
        ollama pull "$model"  # Fetch the latest version of the model
    fi
done

echo "All models installed/updated."

# Keep the script running to prevent container from exiting
wait $pid
