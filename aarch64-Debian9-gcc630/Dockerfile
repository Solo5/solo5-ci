FROM arm64v8/debian:stretch
#
# Install dependencies.
# file, libssl-dev, gyp and libcurl4-gnutls-dev are needed to build the
# monstrosity that is nodegit.
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
        gyp \
        libcurl4-gnutls-dev \
    && apt-get clean

#
# Install dumb-init for correct operation as container PID 1
#
RUN curl -L --silent https://github.com/Yelp/dumb-init/archive/v1.2.0.tar.gz -o /tmp/dumb-init.tar.gz \
    && tar -C /tmp -xzf /tmp/dumb-init.tar.gz \
    && make -C /tmp/dumb-init-1.2.0 \
    && cp /tmp/dumb-init-1.2.0/dumb-init /usr/bin \
    && rm -r /tmp/dumb-init-1.2.0 /tmp/dumb-init.tar.gz
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

#
# Add NodeSource repository key and install Node.js.
#
RUN curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
    | apt-key add - && \
    echo "deb https://deb.nodesource.com/node_6.x stretch main" \
    | tee /etc/apt/sources.list.d/nodesource.list
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qq -y \
        --no-install-recommends \
        nodejs \
    && apt-get clean

#
# Install surf-build. 
#
# This builds the nodegit monstrosity from source. BUILD_ONLY=1 is there
# to force a source build. --unsafe-perm is required to make -g work, we
# are running in a container anyway so this is not a (huge) security risk.
#
RUN BUILD_ONLY=1 npm install --quiet --unsafe-perm -g surf-build

#
# Create a non-root user for builds.
#
RUN useradd -u 1000 -g users -d /home/build -m -s /bin/bash build
USER build
WORKDIR /home/build

#
# Run the builder.
#
# NOTE: The user-visible "builder name" is set here (via the argument to -n).
#
CMD ["surf-run", "-r", "https://github.com/Solo5/solo5", "--", \
     "surf-build", "-n", "aarch64-Debian9-gcc630"]
