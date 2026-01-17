# Bluefin
*Dakotaraptor steini*

[Bluefin's](https://projectbluefin.io) final form. 

> How dare you.
>
> -- John Bazzite

`projectbluefin/dakota` is built on [GNOME OS](https://os.gnome.org/). This is a prototype and not ready and may bite.

![Dakorator](https://github.com/user-attachments/assets/ee92291d-a617-496e-abb6-9045a4c665ce)

## Status

- Consume GNOME nightly bootc image (done)
- Final assembly in this repo (done)

## Future Layout

- Consume GNOME buildstream definitions and apply Bluefin changes:
  - Bluefin buildstream definitions [@projectbluefin/egg](https://github.com/projectbluefin/egg)
- Final assembly in this repo

## Goals

- No dx image, everything in homebrew or sysexts

## Missing things

- Installation
- Ensuring upgrades and rollbacks work

## Get started
    git clone https://github.com/projectbluefin/dakota.git
    cd dakota
    just show-me-the-future

Will build and run Bluefin in a VM. This image is based on GNOME50 so most of the desktop Bluefin changes don't work. The automation is in place though, just check back often to see progress.

## Installation on Bare Metal

To install Bluefin, you first must build the image locally using `just build-containerfile`. Downloaded images won't work right now with `bootc install`, see [this issue](https://github.com/bootc-dev/bootc/issues/1703) for more details.

Before you can install Bluefin to your disk, you must first create a partition layout. The layout should be as follows:

- `/` (formatted as whatever you want, BTRFS subvolumes are supported)
- `/boot` (FAT32 formatted, ideally 2GiB or greater for kernel storage)

You can add a separate `/home` partition (or BTRFS subvolume) if you desire.

Mount your partitions to a directory (e.g. /mnt) like so:

```bash
sudo mount ROOT_PART /mnt
sudo mount --mkdir BOOT_PART /mnt/boot
```

And then run the following command to install Bluefin to `/mnt`:
```
sudo podman run \
    --rm --privileged --pid=host \
    -it \
    -v /etc/containers:/etc/containers:Z \
    -v /var/lib/containers:/var/lib/containers:Z \
    -v /dev:/dev \
    -e RUST_LOG=debug \
    -v "/mnt:/mnt" \
    --security-opt label=type:unconfined_t \
    "ghcr.io/projectbluefin/dakota:latest" bootc install to-filesystem /mnt/mnt --composefs-backend --bootloader systemd --karg splash --karg quiet
```

You will then have to modify the `fstab` file manually to add any additional partitions post-installation, `bootc install` does not do it for you.

## Screenshots

<img width="2376" height="1336" alt="1" src="https://github.com/user-attachments/assets/495cdfe9-4af0-4604-9a3f-8a2fc806924f" />

<img width="2376" height="1336" alt="2image" src="https://github.com/user-attachments/assets/1d1239da-5446-41f0-b0d6-5cdf4e799c64" />

<img width="2376" height="1336" alt="3" src="https://github.com/user-attachments/assets/b7581995-252e-40e7-9405-ba58233d49b2" />

## Dakotaraptor

This Bluefin is represented by the Dakotaraptor: 

<img width="2100" height="2100" alt="Chonky_Dakosaurus_BlueFinSkin" src="https://github.com/user-attachments/assets/eacad3a7-fd79-449d-9dc9-16eccb20d8e7" />
