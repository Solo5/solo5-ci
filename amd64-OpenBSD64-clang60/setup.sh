#!/bin/sh -e
rcctl set ntpd flags -s
pkg_add bash coreutils git gmake node
echo "permit persist setenv { -ENV PS1=\$DOAS_PS1 SSH_AUTH_SOCK } :wheel\npermit nopass keepenv root as root" > /etc/doas.conf
useradd -m surf
usermod -G wheel surf
cd ~surf
echo '#!/bin/sh -e
mkdir $HOME/.node
echo "prefix = ~/.node" > $HOME/.npmrc
echo "export PATH=\$HOME/.node/bin:$PATH\\nexport NODE_PATH=\$HOME/.node/lib/node_modules:\$NODE_PATH\\nexport GITHUB_TOKEN=\"<my-token>\"\\nexport GIT_EXEC_PATH=/usr/local/libexec/git\\nexport LOCAL_GIT_DIRECTORY=/usr/local" >> $HOME/.profile
. $HOME/.profile
git clone --depth=1 https://github.com/surf-build/surf
cd surf 
git checkout v2.0.0-beta.4 
npm install --no-optional 
npm pack
npm install -g --unsafe-perm --no-optional surf-build-2.0.0-beta.4.tgz
cd $HOME' > ./surf-setup.sh
chown surf:surf ./surf-setup.sh
chmod 777 ./surf-setup.sh
su surf -c ./surf-setup.sh
rm ./surf-setup.sh
rm ~/setup.sh
echo "Please run 'passwd surf' to set surf's password"
