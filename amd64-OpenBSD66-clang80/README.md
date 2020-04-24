## Surf and solo5 on OpenBSD 6.6

As of 2020-04-23, surf-build 2.0.0 actually works "almost" out of the box on OpenBSD.

Install the following system packages:
- curl
- git
- gmake
- coreutils
- bash
- node

As **a normal user**, run:

```
npm install surf-build
```

`dugite` will complain the the platform is not supported, you can ignore this. Otherwise the install should succeed.

Additional notes for OpenBSD 6.7 and/or node 12.x:
- you will need to run `npm install request`
- various other bits of the surf-build dependency tree may fail, but as long as surf-build installs and runs with the script below, you're fine

Place the following `surf-build` script into your `$PATH`:

```
#!/bin/sh
[ -z "${SURF_SUDO}" ] && SURF_SUDO=doas
export SURF_SUDO
LOCAL_GIT_DIRECTORY=/usr/local
GIT_EXEC_PATH=/usr/local/libexec/git
export LOCAL_GIT_DIRECTORY
export GIT_EXEC_PATH
exec /home/build/node_modules/.bin/surf-build "$@"

```

You should now be able to run `surf-build` normally, verify with e.g.

```
SURF_RUN_TESTS=1 surf-build -r https://github.com/Solo5/solo5 -s SOME_FULL_COMMIT_SHA
```
