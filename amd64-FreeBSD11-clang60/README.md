## Surf and solo5 on FreeBSD11

As of 2019-03-21, surf-build 2.0.0 actually works "almost" out of the box on FreeBSD.

Install the following system packages:
- git-lite
- gmake
- curl
- bash
- coreutils
- python2
- node10
- npm-node10

If you get an error about the user `git_daemon` "dissapearing during update", run:

```
pwd_mkdb -p /etc/master.passwd
```

and re-run the `pkg install` command(s).  Don't forget to clear the pkg cache with `pkg clean -a` when done.

As **a normal user**, run:

```
npm install surf-build
```

`dugite` will complain the the platform is not supported, you can ignore this. Otherwise the install should succeed.

Place the following `surf-build` script into your `$PATH`:

```
#!/bin/sh
LOCAL_GIT_DIRECTORY=/usr/local
GIT_EXEC_PATH=/usr/local/libexec/git-core
export LOCAL_GIT_DIRECTORY
export GIT_EXEC_PATH
exec /home/build/node_modules/.bin/surf-build "$@"

```

You should now be able to run `surf-build` normally, verify with e.g.

```
SURF_RUN_TESTS=1 surf-build -r https://github.com/Solo5/solo5 -s SOME_FULL_COMMIT_SHA
```
