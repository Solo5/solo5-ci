FROM debian:stretch
ENV BUILDER_NAME=x86_64-stretch-gcc6
#
# Install dependencies.
# "file" and "libssl-dev" are needed to install surf-build.
#
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
        --no-install-recommends \
        apt-transport-https \
        build-essential \
        ca-certificates \
        curl \
        file \
        git \
        gnupg \
        libssl-dev \
        linux-libc-dev \
    && apt-get clean
#
# Add NodeSource repository key and install Node.js.
# NOTE: There is no repository for "stretch", the documentation recommends to
# install the version for "jessie".
#
RUN curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
    | apt-key add - && \
    echo "deb https://deb.nodesource.com/node_6.x jessie main" \
    | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
        --no-install-recommends \
        nodejs \
    && apt-get clean
#
# Install surf-build.
#
RUN npm install --silent -g surf-build
#
# Create a non-root user for builds.
#
RUN useradd -u 1000 -g users -d /home/build -m -s /bin/bash build
USER build
WORKDIR /home/build
#
# Run the builder.
#
CMD surf-run -r https://github.com/Solo5/solo5 -- surf-build -n ${BUILDER_NAME} 
