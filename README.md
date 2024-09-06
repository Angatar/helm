[![Docker Pulls](https://badgen.net/docker/pulls/d3fk/helm?icon=docker&label=pulls&cache=600)](https://hub.docker.com/r/d3fk/helm/tags) [![Docker Image Size](https://badgen.net/docker/size/d3fk/helm/latest?icon=docker&label=image%20size&cache=600)](https://hub.docker.com/r/d3fk/helm/tags) [![Docker build](https://img.shields.io/badge/automated-automated?style=flat&logo=docker&logoColor=blue&label=build&color=green&cacheSeconds=600)](https://hub.docker.com/r/d3fk/helm/tags) [![Docker Stars](https://badgen.net/docker/stars/d3fk/helm?icon=docker&label=stars&color=green&cache=600)](https://hub.docker.com/r/d3fk/helm) [![Github Stars](https://img.shields.io/github/stars/Angatar/helm?label=stars&logo=github&color=green&style=flat&cacheSeconds=600)](https://github.com/Angatar/helm) [![Github forks](https://img.shields.io/github/forks/Angatar/helm?logo=github&style=flat&cacheSeconds=600)](https://github.com/Angatar/helm/fork) [![Github open issues](https://img.shields.io/github/issues-raw/Angatar/helm?logo=github&color=yellow&cacheSeconds=600)](https://github.com/Angatar/helm/issues) [![Github closed issues](https://img.shields.io/github/issues-closed-raw/Angatar/helm?logo=github&color=green&cacheSeconds=600)](https://github.com/Angatar/helm/issues?q=is%3Aissue+is%3Aclosed) [![GitHub license](https://img.shields.io/github/license/Angatar/helm)](https://github.com/Angatar/helm/blob/master/LICENSE)

# Lightweight Helm 3 Container from Scratch (Angatar > d3fk/helm)
A super lightweight container built from scratch with Helm official binary, a default non-root user and ssl/tls validation capabilities (~52MB -> [![Docker Image Size](https://badgen.net/docker/size/d3fk/helm/latest?icon=docker&label=compressed&cache=600)](https://hub.docker.com/r/d3fk/helm/tags)). This container uses the [latest Helm binary](https://github.com/helm/helm/releases), fetched from the official Helm releases and built into a scratch image. It supports multiple architectures and is updated monthly to ensure you're using the latest stable version of Helm. The `d3fk/helm` container is ideal for managing and deploying Helm charts in your kubernetes clusters, and running Helm commands within CI/CD pipelines or other minimal environments.

This container is also especially convenient with tiny/immutable linux distro such as [Flatcar Container Linux](https://github.com/flatcar/Flatcar), taking advantage of the immutability of Docker images without requiring the use of a package manager... see-> [Tips: Super fast setup](#TipsAnchor)


## Get this image (d3fk/helm)
The best way to get the `d3fk/helm` image is to pull the prebuilt image from the Docker Hub Registry.

The image is prebuilt as a multi-arch image with "automated build" enabled on [its code repository](https://github.com/Angatar/helm).

Image name: **d3fk/helm**
```sh
$ docker pull d3fk/helm:latest
```
Docker Hub repository: https://hub.docker.com/r/d3fk/helm/

[![DockerHub Badge](https://dockeri.co/image/d3fk/helm?cache=600)](https://hub.docker.com/r/d3fk/helm)


## Helm version of d3fk/helm

The **d3fk/helm** images are multi-arch images that exist with the latest tag and versionned tags

Supported architectures:
- linux/amd64
- linux/386
- linux/arm/v7
- linux/arm64
- linux/ppc64le
- linux/s390x

You can use the **d3fk/helm** container images to manage Helm charts and deploy them on your Kubernetes clusters from different platforms.

### d3fk/helm:latest

The **d3fk/helm:latest** multi-arch image is updated monthly to ensure you have the latest **stable** version of Helm.This last stable version of Helm is currently related to the last release of Helm on its github repository which is [reported Here](https://github.com/helm/helm/releases).

### versioned d3fk/helm:v3...

In case you require a fixed version of Helm to avoid any possible alteration of its behavior in the future, the following tagged images are also made available from the Docker hub (as multi-arch images). In each of these images the version was freezed in a release of the main code repo and built from the Docker hub by automated build. These images are stable and won't be rebuilt in the future:

- for version 3.15.4: **d3fk/helm:v3.15**

## Basic usage
```sh
$ docker run --rm d3fk/helm
```
This command will display the Helm help menu, listing available commands and main configuration paths.

## Default User

The container follows best practices by running with a non-root user named `helm` with a UID of `6009`. This UID should avoid interference with existing users by default when working with your local filesystem (e.g, access to config files, mounted volumes...). However , to replicate the same behavior as if you were using Helm locally, it is advised to set the container user with your UID when running by using the `--user` option

## Working with Files
As we'll make use of files with Helm (e.g., access your config files, package your charts), it is important to know that the container's working directory is set to `/files` (e.g. for your YAML charts), the user home is set to `/` (e.g. used for confing files) and that 3 environment variables have been set respectively for cache, configuration and data:

```sh
HELM_CACHE_HOME="/.helm/.cache/helm"
HELM_CONFIG_HOME="/.helm/.config/helm"
HELM_DATA_HOME="/.helm/.local/share/helm"
```


You can mount your local files into those locations and reference them in your Helm commands.
The environment variables in the container can be overwritten in the docker run command with `--env` to addapt the helm cache (`HELM_CACHE_HOME`), configuration(`HELM_CONFIG_HOME`) and data (`HELM_DATA_HOME`) paths to your needs.

When working with files, you should either:

1. Use the `--user` option when running the Docker container, setting it to a user with appropriate access rights to the files or directories Helm needs to use, **or**
2. Ensure that your working files or directories mounted on `/` or `/files` has appropriate access rights for manipulation by a different user, specifically the container default user `helm` (6009) if no `--user` option set.

## Configuration
To use your Helm configuration and connect to a Kubernetes cluster, mount your local Helm configuration and Kubernetes credentials into the container.

```sh
$ docker run --rm --user $(id -u):$(id -g) -v $HOME/.kube:/.kube -v $HOME/.helm:/.helm d3fk/helm
```
In this example, we assume that the user running the container has appropriate access rights to the configuration files and that Helm cache ,config and data folders are all in `$HOME/.helm`

### Migrating from exisiting configuration
In case you already were using a local Helm, you can reuse your configuration by either
- overwritting the cache, config and data environment variables in the docker run command, **or**
- simply copy your `.cache/helm .config/helm .local/share/helm` into a directory that you'll be able to mount on the /.helm/ path location of the container

### Configuring from scratch

In order to provide an existing path to mount Helm cache, configuration, and data and avoid that the docker mount action creates the path with unappropriate right it is preferable to make the user create the empty directories ahead of running helm:

```sh
$ mkdir -p $HOME/.helm/.cache/helm $HOME/.helm/.config/helm $HOME/.helm/.local/share/helm

```
*Assuming here that Helm will be used from the current user account so the helm directories `.cache/helm`, `.config/helm` and `.local/share/helm` will all be located into your local `$HOME/.helm/` directory.*

You can then start configuring Helm by using the Helm command lines e.g:
```sh
$ docker run --rm --user $(id -u):$(id -g) -v $HOME/.kube:/.kube -v $HOME/.helm:/.helm d3fk/helm repo add bitnami https://charts.bitnami.com/bitnami

$ docker run --rm --user $(id -u):$(id -g) -v $HOME/.kube:/.kube -v $HOME/.helm:/.helm d3fk/helm repo update
```

## Example of commands
### Example: Installing a Helm Chart
To install a Helm chart, you can use the following command:
```sh
$ docker run --rm --user $(id -u):$(id -g) -v $HOME/.kube:/.kube -v $HOME/.helm:/.helm d3fk/helm install my-release stable/my-chart
```

### Example: Listing Helm releases of charts
To list all Helm releases of charts in your cluster:
```sh
$ docker run --rm --user $(id -u):$(id -g) -v $HOME/.kube:/.kube -v $HOME/.helm:/.helm d3fk/helm list
```

### Example: packaging a chart directory into a chart archive
```sh
$ docker run --rm --user $(id -u):$(id -g) -v $(pwd):/files -v $HOME/.kube:/.kube -v $HOME/.helm:/.helm d3fk/helm package my-local-chart-directory
```
In this example, `my-local-chart-directory` refers to the directory of the chart you need to package from your local folder.

## Using Helm Interactively
In case you need to use Helm interactively (no use case in mind but might exist), remember to run the container with the `-ti` options.

## Tips: Alias for Easier Access
<h4 id="TipsAnchor"></h4>
To simplify the usage of Helm via Docker, you can simply create an alias in your shell or `.bashrc`, `.shrc`, `.rc`...

### Super fast setup
In case you only need a rapid access to Helm, assuming your kubernetes config is present in $HOME/.kube and accessible to the current user you can simply copy paste the following lines in your prompt

```sh
mkdir -p $HOME/.helm/.cache/helm $HOME/.helm/.config/helm $HOME/.helm/.local/share/helm
alias helm='docker run --rm --user $(id -u):$(id -g) -ti -v $(pwd):/files -v $HOME/.kube:/.kube -v $HOME/.helm:/.helm d3fk/helm'

```
You can then run d3fk/helm container commands as if they were standard Helm commands, e.g:
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo mariadb
helm install mariadb bitnami/mariadb
```

The Helm configuration, cache and data will be held in your `$HOME/.helm/` for any future access.
As the alias was only added in your prompt it is only available for your current session, to make Helm available from any future session simply add the alias in your launch shell script e.g `.bashrc`

## License

The content of this [GitHub code repository](https://github.com/Angatar/helm) is provided under **MIT** licence
[![GitHub license](https://img.shields.io/github/license/Angatar/helm)](https://github.com/Angatar/helm/blob/master/LICENSE).

For **helm** license information, please see https://github.com/helm/helm .

## Kubectl

If you're using Helm, you might also be interested in the [d3fk/kubectl](https://hub.docker.com/r/d3fk/kubectl/) container. It offers a similar lightweight and minimalistic approach for managing your Kubernetes clusters using the kubectl command-line tool.

You can find more details and usage instructions for the [d3fk/kubectl](https://hub.docker.com/r/d3fk/kubectl/) container on [Docker Hub](https://hub.docker.com/r/d3fk/kubectl/) or its [GitHub repository]((https://github.com/Angatar/kubectl)).
