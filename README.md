# Solo5 CI

This repository contains the build recipes / instructions for the
[surf-build](https://github.com/surf-build/surf) CI used for Solo5.

| Builder name              | Recipe | Contact |
| ------------              | ------ | ------- |
| aarch64-Debian9-gcc630    | [Dockerfile](aarch64-Debian9-gcc630/Dockerfile) | @mato |
| amd64-FreeBSD11p8-clang38 | [custom](amd64-FreeBSD11p8-clang38/README.md) | @hannesm |
| amd64-FreeBSD12-clang40   | custom | @hannesm |
| x86\_64-Debian8-gcc492    | [Dockerfile](x86_64-Debian8-gcc492/Dockerfile) | @mato |
| x86\_64-Debian9-gcc630    | [Dockerfile](x86_64-Debian9-gcc630/Dockerfile) | @mato |

## Docker-based builders

To build and push the image, from the directory with the Dockerfile:

    $ docker build -t mato/solo5-builder:<name> .
    $ docker push mato/solo5-builder:<name>

To run a builder interactively:

    $ docker run --rm -ti \
        -e GITHUB_TOKEN=<REDACTED> \
        mato/solo5-builder:<name>

After a while you should see a message from `surf-run` indicating it 
is watching the Solo5/solo5 repository.

To run a builder non-interactively:

    $ docker run --restart=always --name solo5-builder-<name> \
        -d -e GITHUB_TOKEN=<REDACTED> \
        mato/solo5-builder:<name>

Note that the `GITHUB_TOKEN` value will be exposed in eg. `docker inspect`
of the running container.

## Adding more builders

Open a PR on this repository, adding your build recipe and entry to the
above table. Contact @mato for a suitable `GITHUB_TOKEN`.
