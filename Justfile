image_name := env("BUILD_IMAGE_NAME", "ghcr.io/projectbluefin/dakota")
image_tag := env("BUILD_IMAGE_TAG", "latest")
base_dir := env("BUILD_BASE_DIR", ".")
filesystem := env("BUILD_FILESYSTEM", "btrfs")

build-containerfile $image_name=image_name:
    sudo podman build --format oci --security-opt label=disable --squash-all -t "${image_name}:latest" .

bootc *ARGS:
    sudo podman run \
        --rm --privileged --pid=host \
        -it \
        -v /var/lib/containers:/var/lib/containers \
        -v /dev:/dev \
        -v "{{base_dir}}:/data" \
        --security-opt label=type:unconfined_t \
        -e RUST_LOG=debug \
        "{{image_name}}:{{image_tag}}" bootc {{ARGS}}

generate-bootable-image $base_dir=base_dir $filesystem=filesystem:
    #!/usr/bin/env bash

    if [ ! -e "${base_dir}/bootable.img" ] ; then
        fallocate -l 50G "${base_dir}/bootable.img"
    fi

    just bootc install to-disk --composefs-backend \
        --via-loopback /data/bootable.img \
        --filesystem "${filesystem}" \
        --wipe \
        --bootloader systemd \
        --karg systemd.firstboot=no \
        --karg splash \
        --karg quiet \
        --karg console=tty0 \
        --karg systemd.debug_shell=ttyS1

rootful $image=image_name:
    #!/usr/bin/env bash
    podman image scp $USER@localhost::$image root@localhost::$image

run-vm $base_dir=base_dir:
    #!/usr/bin/env bash
    set -e
    if command -v qemu-system-x86_64 >/dev/null 2>&1; then
        QEMU="qemu-system-x86_64"
        OVMF="/usr/share/edk2/ovmf/OVMF_CODE_4M.qcow2"
        OVMF_FMT="qcow2"
    else
        QEMU="flatpak run --command=/app/lib/extensions/Qemu/bin/qemu-system-x86_64 org.virt_manager.virt-manager"
        OVMF="/app/lib/extensions/Qemu/share/qemu/edk2-x86_64-code.fd"
        OVMF_FMT="raw"
    fi
    exec $QEMU \
        -machine pc-q35-10.1 \
        -m 8G \
        -smp 4 \
        -cpu host \
        -enable-kvm \
        -device virtio-vga \
        -drive if=pflash,format=$OVMF_FMT,readonly=on,file=$OVMF \
        -drive file={{base_dir}}/bootable.img,format=raw,if=virtio


init-submodules:
    git submodule update --init --recursive

show-me-the-future: check-deps init-submodules build-containerfile generate-bootable-image run-vm

clean:
    rm -f bootable.img

check-deps:
    @command -v podman >/dev/null 2>&1 || (echo "podman is not installed" && exit 1)
    @command -v just >/dev/null 2>&1 || (echo "just is not installed" && exit 1)
    @if command -v qemu-system-x86_64 >/dev/null 2>&1; then \
        echo "qemu-system-x86_64 found in system PATH"; \
    elif flatpak run --command="qemu-system-x86_64" org.virt_manager.virt-manager --version >/dev/null 2>&1; then \
        echo "qemu-system-x86_64 found via flatpak"; \
    else \
        echo "Error: qemu-system-x86_64 not found (neither system or flatpak)"; \
        exit 1; \
    fi
    @echo "Required dependencies are installed."
