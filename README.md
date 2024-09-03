[![Docker Pulls](https://badgen.net/docker/pulls/d3fk/helm?icon=docker&label=pulls)](https://hub.docker.com/r/d3fk/helm/tags) [![Docker Image Size](https://badgen.net/docker/size/d3fk/helm/latest?icon=docker&label=image%20size)](https://hub.docker.com/r/d3fk/helm/tags) [![Docker Stars](https://badgen.net/docker/stars/d3fk/helm?icon=docker&label=stars&color=green)](https://hub.docker.com/r/d3fk/helm) [![Github Stars](https://img.shields.io/github/stars/Angatar/helm?label=stars&logo=github&color=green&style=flat)](https://github.com/Angatar/helm) [![Github forks](https://img.shields.io/github/forks/Angatar/helm?logo=github&style=flat)](https://github.com/Angatar/helm/fork) [![Github open issues](https://img.shields.io/github/issues-raw/Angatar/helm?logo=github&color=yellow)](https://github.com/Angatar/helm/issues) [![Github closed issues](https://img.shields.io/github/issues-closed-raw/Angatar/helm?logo=github&color=green)](https://github.com/Angatar/helm/issues?q=is%3Aissue+is%3Aclosed) [![GitHub license](https://img.shields.io/github/license/Angatar/helm)](https://github.com/Angatar/helm/blob/master/LICENSE)

# Lightweight Helm 3 Container from Scratch (Angatar > d3fk/helm)
A super lightweight container with Helm official binary only, built from scratch (~52MB -> [![Docker Image Size](https://badgen.net/docker/size/d3fk/helm/latest?icon=docker&label=compressed)](https://hub.docker.com/r/d3fk/helm/tags)). This container uses the [latest Helm binary](https://get.helm.sh/helm-latest-version), fetched from the official Helm releases and built into a scratch image. It supports multiple architectures and is updated monthly to ensure you're using the latest stable version of Helm. The `d3fk/helm` container is ideal for managing and deploying Helm charts in your kubernetes cluster, and running Helm commands within CI/CD pipelines or other minimal environments.

This container is also especially convenient with tiny/immutable linux distro such as [Flatcar Container Linux](https://github.com/flatcar/Flatcar), taking advantage of the immutability of Docker images without requiring the use of a package manager.


## Get this image (d3fk/helm)
The best way to get the `d3fk/helm` image is to pull the prebuilt image from the Docker Hub Registry.

The image is prebuilt as a multi-arch image with "automated build" enabled on [its code repository](https://github.com/Angatar/helm).

Image name: **d3fk/helm**
```sh
$ docker pull d3fk/helm:latest
```
Docker Hub repository: https://hub.docker.com/r/d3fk/helm/

[![DockerHub Badge](https://dockeri.co/image/d3fk/helm)](https://hub.docker.com/r/d3fk/helm)

## Helm version of d3fk/helm is the latest stable version

The **d3fk/helm:latest** multi-arch image is updated daily to ensure you have the latest **stable** version of Helm. This ensures that within 24 hours of a new release, you can run the latest Helm commands.

Supported architectures:
- linux/amd64
- linux/386
- linux/arm/v7
- linux/arm64
- linux/ppc64le
- linux/s390x

You can use this container to manage Helm charts and Kubernetes clusters from different platforms.

## Basic usage
```sh
$ docker run --rm d3fk/helm
```
This command will display the Helm help menu, listing available commands and main configuration paths.

## Configuration
To use your Helm configuration or connect to a Kubernetes cluster, mount your local Helm configuration and Kubernetes credentials into the container.

```sh
$ docker run --rm -v $HOME/.kube:/.kube -v $HOME/.config/helm:/.config/helm d3fk/helm
```

### Example: Installing a Helm Chart
To install a Helm chart, you can use the following command:
```sh
$ docker run --rm -v $HOME/.kube:/.kube -v $HOME/.config/helm:/.config/helm d3fk/helm install my-release stable/my-chart
```

### Example: Listing Helm releases of charts
To list all Helm releases of charts in your cluster:
```sh
$ docker run --rm -v $HOME/.kube:/.kube -v $HOME/.config/helm:/.config/helm d3fk/helm list
```

## Working with Files
If you need to use files with Helm (e.g., custom values.yaml), the container's working directory is set to `/files`. You can mount files into this directory and reference them in your Helm commands.

### Example: packaging a chart directory into a chart archive
```sh
$ docker run --rm -v $(pwd):/files -v $HOME/.kube:/.kube -v $HOME/.config/helm:/.config/helm d3fk/helm package my-local-chart-directory
```
Assuming `my-local-chart-directory` is the directory of the chart you need to package in your local folder

## Using Helm Interactively
If you need to use Helm interactively, such as inspecting charts or debugging, you can run the container with the `-ti` option.

### Example: Debugging a Helm Chart
```sh
$ docker run -ti --rm -v $HOME/.kube:/.kube -v $HOME/.config/helm:/.config/helm d3fk/helm template my-chart --debug
```

## Tips: Alias for Easier Access
To simplify the usage of Helm via Docker, you can create an alias in your shell.

```sh
alias helm='docker run --rm -ti -v $HOME/.kube:/.kube -v $HOME/.config/helm:/.config/helm d3fk/helm'
```
You can then run Helm commands as usual Helm commands e.g:
```sh
$ helm install my-release stable/my-chart
```

[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/Angatar/helm/blob/master/LICENSE)
