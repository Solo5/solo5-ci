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

| Builder name                  | OS/Type | Compiler | Contact | Notes |
| ------------                  | ------- | -------- | ------- | ----- |
| 00-info                       |         |          |         | (meta, used by CI system for overall progress)
| 10-basic-x86\_64-Debian10     | Debian 10.1, Nested KVM | GCC 8.3.0 | @mato | |
| 11-basic-x86\_64-FreeBSD11    | FreeBSD 11.3, Nested KVM | Clang 8.0.0 | @mato | |
| 12-basic-aarch64-Debian9      | Debian 9.8, Docker ([Dockerfile](any-Debian9-gcc630/Dockerfile)) | GCC 6.3.0 | @mato | |
| 13-basic-x86\_64-OpenBSD64    | OpenBSD 6.4, Nested KVM | Clang 6.0.0 | @mato | |
| 14-basic-x86\_64-FreeBSD12    | FreeBSD 12.1, Nested KVM | Clang 8.0.1 | @mato | |
| 20-e2e-x86\_64-Debian10       | Debian Buster/Testing, Nested KVM | GCC 8.3.0 | @mato | Runs Mirage/Solo5 E2E tests using https://github.com/mato/e2e-mirage-solo5/
