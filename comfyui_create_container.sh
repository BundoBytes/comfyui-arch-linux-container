podman container rm comfyui_container --force && podman-compose build && podman-compose up -d && podman attach comfyui_container
