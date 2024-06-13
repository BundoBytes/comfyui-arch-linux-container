# comfyui-arch-linux-container
A simple OCI script to launch a container that runs ComfyUI.

The script uses podman, but you should be able to replace it with 'docker' to work with Docker instead.

Run comfyui_create_container.sh to build the container and run it. IMPORTANT: Rerunning this will delete the old container and rebuild it.

Run comfyui_launch.sh to start an existing container.
