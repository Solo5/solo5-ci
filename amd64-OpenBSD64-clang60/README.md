## Surf and solo5 on OpenBSD

install an OpenBSD 6.4 Release  
login as root  
run 

```
ftp https://raw.githubusercontent.com/adamsteen/solo5-ci/master/amd64-OpenBSD64-clang60/setup.sh
chmod 744 setup.sh
```

inspect setup.sh, make sure you are happy then run it
`setup.sh`

logout out of root and login as surf (don't forget to set surf's password, as suggested by the script)  

setup your git credentials   

update the GITHUB_TOKEN in .profile and run  
  
`surf-run -r https://github.com/Solo5/solo5 -- surf-build -n amd64-OpenBSD64-clang60`
