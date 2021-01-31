# scrarch
An [Arch Linux](https://archlinux.org/) Docker image built using nothing but a Dockerfile.

## Why?
I wanted to learn how to build a Docker image using a `FROM scratch` statement. Arch Linux provides an [official Docker image](https://hub.docker.com/_/archlinux) and you should probably use that one instead.

To be able to build it with a single `docker build .` statement, an Alpine image is used to download the Arch bootstrap tarball.

## Building
`docker build .`

