# Solo5 CI

This repository contains the build recipes / instructions for the
[surf-build](https://github.com/surf-build/surf) CI used for Solo5.

Our CI system has somewhat atypical requirements, since in order to run the
end-to-end [tests](https://github.com/Solo5/solo5/tree/master/tests) we need
access to hardware virtualization extensions. This is achieved by running on
bare metal and using nested KVM (for x86\_64) or a suitably privileged Docker
container (for aarch64).

The "master" driver script can be found at
[solo5-vm-build.sh](scripts/solo5-vm-build.sh), this relies on
[surf-build](https://github.com/surf-build/surf) to watch the Solo5 repository
for new or updated PRs and push build status to Github, with build logs
uploaded as a Gist (click on the "Details" link beside each builder's status).
The system further depends on [vm](https://github.com/roburio/vm) for the KVM
management infrastructure.

The following builders are currently running:

| Builder name                  | Type/Notes | Contact |
| ------------                  | ---- | ------- |
| aarch64-Debian9-gcc630        | Docker [Dockerfile](any-Debian9-gcc630/Dockerfile) | @mato |
| vm-amd64-FreeBSD11\_1-clang40 | Nested KVM | @mato |
| vm-x86\_64-Debian9-gcc630     | Nested KVM | @mato |

