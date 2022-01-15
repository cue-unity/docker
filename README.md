### `docker`

The `docker` repo contains the Dockerfile specification of the default image used by
[`unity`](https://github.com/cue-unity/unity).

### Requirements

The
[script](https://github.com/cue-unity/docker/blob/main/_scripts/buildDockerImage.sh)
used to build Docker images for [`unity`](https://github.com/cue-unity/unity)
builds images for multiple platforms. This uses the
[`buildx`](https://github.com/docker/buildx) plugin and so requires [QEMU](https://www.qemu.org/).

Install QEMU:

```
# Ubuntu example
sudo apt-get install -y qemu-user-static

```

(taken from [an article on using `buildx`
for multi architecture images](https://medium.com/@artur.klauser/building-multi-architecture-docker-images-with-buildx-27d80f7e2408)).

Install cross-platform emulators for at least the target platforms:

```
docker run --privileged --rm tonistiigi/binfmt --install all
```

(taken from the [`buildx` documentation](https://docs.docker.com/buildx/working-with-buildx/).)

Create and use a builder (which will by default use the `docker-container`
driver):

```
docker buildx create --name mybuilder
docker buildx use mybuilder
```

Verify the builder is using the `docker-container` driver and the target
platforms supported:

```
docker buildx inspect --bootstrap
```

The output should be something like:

```
[+] Building 0.5s (1/1) FINISHED
 => [internal] booting buildkit                                                                                                                                                                                                                                                                                  0.5s
 => => starting container buildx_buildkit_mybuilder0                                                                                                                                                                                                                                                             0.5s
Name:   mybuilder
Driver: docker-container

Nodes:
Name:      mybuilder0
Endpoint:  unix:///var/run/docker.sock
Status:    running
Platforms: linux/arm64, linux/amd64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/mips64le, linux/mips64
```

Run the script to build Docker images for `unity`:

```
./_scripts/buildDockerImage.sh -b
```

Omit the `-b` flag to also push the resulting multi-arch images to Docker Hub.
