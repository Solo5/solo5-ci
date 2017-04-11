## Surf and solo5 on FreeBSD11

At the moment, surf does _not_ build out of the box on FreeBSD (due to an old
nodegit which does not compile, see
https://github.com/surf-build/surf/issues/63).  Steps to get it running are as
follows:

Install the following system packages:
- devel/git
- devel/gmake
- ftp/curl
- www/node6
- www/npm3

```
# git clone https://github.com/surf-build/surf
# cd surf && mv package.json package.json.tmp && cat package.json.tmp | sed -e 's/0.16/0.18/g' > package.json
# npm install --unsafe-perm babel-cli babel-plugin-transform-async-to-generator babel-preset-es2016-node5
# setenv CFLAGS "-I/usr/local/include"
# setenv LDFLAGS "-L/usr/local/lib"
# cd surf && npm install -g --unsafe-perm
# setenv LD_PRELOAD "/usr/local/lib/libcurl.so"
# setenv GITHUB_TOKEN "<my-token>"
# surf-run -r https://github.com/Solo5/solo5 -- surf-build -n amd64-FreeBSD11p8-clang38
```
