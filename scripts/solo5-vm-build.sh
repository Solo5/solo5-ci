#!/bin/bash
#
# Build job driver for surf-build using "vm" for ephemeral VM management.
#
# Example deployment:
#
#     $ GITHUB_USER=... GITHUB_TOKEN=... surf-run \
#         -r https://github.com/USER/REPO -- /path/to/surf-vm-build
#
# Optionally, set SURF_LOGDIR to a directory where build job outputs will
# be logged. If unset they go to stdout, which is probably not what you want.
#
# You will want to modify the list of builds and VM templates at the end
# of this script (see the calls to do_build()).

prog_NAME=$(basename $0)

log()
{
    echo "$(date -Iseconds) ${prog_NAME}[$$]:" \
        "(${SURF_BUILD_NAME:-none}) $@" 1>&2
}

err()
{
    log "ERROR: $@"
}

warn()
{
    log "WARNING: $@"
}

die()
{
    err "$@"
    exit 1
}

[ -z "${GITHUB_USER}" ]  && die "GITHUB_USER must be set"
[ -z "${GITHUB_TOKEN}" ] && die "GITHUB_TOKEN must be set"
[ -z "${SURF_REPO}" ]    && die "SURF_REPO must be set"
[ -z "${SURF_SHA1}" ]    && die "SURF_SHA1 must be set"
[ -z "${SURF_NWO}" ]     && die "SURF_NWO must be set"

gh_status()
{
    [ -z "${SURF_BUILD_NAME}" ] && die "gh_status(): SURF_BUILD_NAME not set"
    [ $# -ne 2 ] && die "gh_status(): usage: STATE DESCRIPTION"

    curl -s -f --output /dev/null --data @- \
        -u "${GITHUB_USER}:${GITHUB_TOKEN}" \
        "https://api.github.com/repos/${SURF_NWO}/statuses/${SURF_SHA1}" \
        <<EOM
        { "context":"${SURF_BUILD_NAME}", "state":"$1", "description":"$2" }
EOM
    # Failure here is deliberately ignored
}

gh_meta_status()
{
    [ $# -ne 3 ] && die "gh_meta_status(): usage: CONTEXT STATE DESCRIPTION"

    SURF_BUILD_NAME="$1" gh_status "$2" "$3"
}

gh_die()
{
    gh_status error "$@"
    die "$@"
}

cleanup()
{
    if [ -n "${vm_ID}" ]; then
        sudo vm stop -f "${vm_ID}"
        sudo vm remove "${vm_ID}"
    fi
}
trap cleanup 0 INT TERM

sepa()
{
    echo -n "----------------------------------------"
    echo "----------------------------------------"
}

do_build()
{
    [ $# -ne 3 ] && die "do_build(): usage: CONTEXT TEMPLATE BUILD_TYPE"
    SURF_BUILD_NAME="$1"
    vm_TEMPLATE="$2"
    SURF_BUILD_TYPE="$3"

    case ${SURF_BUILD_NAME} in
        *OpenBSD*)
            SURF_SUDO=doas
            ;;
        *)
            SURF_SUDO=sudo
            ;;
    esac

    #sepa
    log "New job: ${SURF_NWO}@${SURF_SHA1}"
    log "Github context: ${SURF_BUILD_NAME}, VM template: ${vm_TEMPLATE}"

    vm_ID=$(sudo vm clone "${vm_TEMPLATE}") \
        || gh_die "Clone failed ($?)"
    log "Booting VM: ${vm_ID}"
    gh_status pending "Waiting for ${vm_ID}"
    sudo vm start "${vm_ID}" \
        || gh_die "Start ${vm_ID} failed ($?)"
    vm_IP=$(timeout 30 sudo vm wait "${vm_ID}") \
        || gh_die "Wait ${vm_ID} failed ($?)"
    log "Boot complete, IP address: ${vm_IP}"

    #sepa

    # Log job output in ${SURF_LOGDIR} if set.
    if [ -n "${SURF_LOGDIR}" -a -d "${SURF_LOGDIR}" ]; then
        log_FILE="${SURF_LOGDIR}/${SURF_SHA1}.$(date +%s).$$.${SURF_BUILD_NAME}"
        log "Logging job output to: ${log_FILE}"
        exec 3>${log_FILE}
        exec 4>&3
    else
        exec 3>&1
        exec 4>&2
    fi

    gh_status pending "Building on ${vm_ID}"
    # This command can exit with the following status:
    #   0: Success
    #   2: The underlying surf-build job failed
    # 124: Timed out
    # 255: The SSH connection failed
    # (surf-build exits with 255 if the job failed, hence the status-juggling)
    # (XXX: This cannot distinguish between "the surf-build invocation failed"
    # and "the surf-build job failed)
    timeout 300 ssh -v ${vm_IP} env - \
            HOME="/home/build" \
            PATH="/home/build/bin:/home/build/node_modules/.bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/sbin" \
            TMPDIR="/home/build" \
            GITHUB_TOKEN="${GITHUB_TOKEN}" \
            SURF_REPO="${SURF_REPO}" \
            SURF_SHA1="${SURF_SHA1}" \
            SURF_RUN_TESTS="yes" \
            SURF_BUILD_TYPE="${SURF_BUILD_TYPE}" \
            SURF_SUDO="${SURF_SUDO}" \
            surf-build -n "${SURF_BUILD_NAME}" \|\| exit 2 \
            1>&3 2>&4
    job_STATUS=$?
    # We only want to publish timeouts or SSH failures
    case "${job_STATUS}" in
        124)
            gh_status error "Build timed out"
            job_TIMEOUT=1
            ;;
        255)
            gh_status error "Connection to ${vm_ID} failed"
            ;;
        *)
            ;;
    esac

    #sepa
    log "Exit status: ${job_STATUS}"

    if [ -n "${job_TIMEOUT}" ]; then
        # If the job timed out, kill the VM with prejudice.
        # XXX Note, this will leak a DHCP lease.
        log "Job timed out, killing VM: ${vm_ID}"
        sudo vm stop -f ${vm_ID}
    else
        # Otherwise, give it some time to gracefully shut down.
        log "Stopping and removing VM: ${vm_ID}"
        sudo vm stop -t 30 ${vm_ID}
    fi
    sudo vm remove ${vm_ID}
    vm_ID=
    log "Done"
}

do_docker_build()
{
    [ $# -ne 4 ] && die "do_docker_build(): usage: CONTEXT IMAGE BUILDHOST BUILD_TYPE"
    SURF_BUILD_NAME="$1"
    DOCKER_IMAGE="$2"
    BUILDHOST="$3"
    SURF_BUILD_TYPE="$4"
    SURF_SUDO=

    #sepa
    log "New job: ${SURF_NWO}@${SURF_SHA1}"
    log "Github context: ${SURF_BUILD_NAME}, for host: ${BUILDHOST}"

    #sepa

    # Log job output in ${SURF_LOGDIR} if set.
    if [ -n "${SURF_LOGDIR}" -a -d "${SURF_LOGDIR}" ]; then
        log_FILE="${SURF_LOGDIR}/${SURF_SHA1}.$(date +%s).$$.${SURF_BUILD_NAME}"
        log "Logging job output to: ${log_FILE}"
        exec 3>${log_FILE}
        exec 4>&3
    else
        exec 3>&1
        exec 4>&2
    fi

    gh_status pending "Building on ${BUILDHOST}"
    # This command can exit with the following status:
    #   0: Success
    #   2: The underlying surf-build job failed
    # 124: Timed out
    # 255: The SSH connection failed
    # (surf-build exits with 255 if the job failed, hence the status-juggling)
    # (XXX: This cannot distinguish between "the surf-build invocation failed"
    # and "the surf-build job failed)
    # XXX Check if "docker run" can interpose another status code here.
    # XXX EMAIL needed here otherwise git/dugite complain about unconfigured Git.
    timeout 300 ssh -v ${BUILDHOST} docker run --rm \
            -e GITHUB_TOKEN="${GITHUB_TOKEN}" \
            -e SURF_REPO="${SURF_REPO}" \
            -e SURF_SHA1="${SURF_SHA1}" \
            -e SURF_RUN_TESTS="yes" \
            -e SURF_BUILD_TYPE="${SURF_BUILD_TYPE}" \
            -e SURF_SUDO="${SURF_SUDO}" \
            -e EMAIL="Solo5-CI\ \<mato+solo5-ci@lucina.net\>" \
            --device /dev/net/tun \
            --device /dev/kvm \
            --cap-add NET_ADMIN \
            --tmpfs /tmp:rw,exec \
            ${DOCKER_IMAGE} \
            surf-build -n "${SURF_BUILD_NAME}" \|\| exit 2 \
            1>&3 2>&4
    job_STATUS=$?
    # We only want to publish timeouts or SSH failures
    case "${job_STATUS}" in
        124)
            gh_status error "Build timed out"
            job_TIMEOUT=1
            ;;
        255)
            gh_status error "Connection to ${BUILDHOST} failed"
            ;;
        *)
            ;;
    esac

    #sepa
    log "Exit status: ${job_STATUS}"

    # TODO: Needs docker create/docker logs/docker kill combo
    # if [ -n "${job_TIMEOUT}" ]; then
    #     # If the job timed out, kill the VM with prejudice.
    #     # XXX Note, this will leak a DHCP lease.
    #     log "Job timed out, killing VM: ${vm_ID}"
    #     sudo vm stop -f ${vm_ID}
    # else
    #     # Otherwise, give it some time to gracefully shut down.
    #     log "Stopping and removing VM: ${vm_ID}"
    #     sudo vm stop -t 30 ${vm_ID}
    # fi
    # sudo vm remove ${vm_ID}
    # vm_ID=
    log "Done"
}

gh_meta_status 00-info pending "Builds in progress ($(date --utc))"

# First group that can run in parallel
GROUP=()
( do_build 10-basic-x86_64-Debian10 ci-solo5-debian10 basic ) &
GROUP+=($!)
( do_build 11-basic-x86_64-FreeBSD11 ci-solo5-freebsd11 basic ) &
GROUP+=($!)

# Don't care about this one (remote)
( do_docker_build 12-basic-aarch64-Debian10 mato/solo5-builder:aarch64-Debian10-gcc830 rpi-builder.lan1 basic ) &

wait ${GROUP[*]}

# Second group
GROUP=()
( do_build 13-basic-x86_64-OpenBSD64 ci-solo5-openbsd64 basic ) &
GROUP+=($!)

wait ${GROUP[*]}

# Third group
GROUP=()
( do_build 20-e2e-x86_64-Debian10 ci-e2e-debian10 e2e ) &
GROUP+=($!)

wait ${GROUP[*]}

# Wait for ALL builders to finish, including remote
wait

gh_meta_status 00-info success "All builders finished ($(date --utc))"

exit 0
