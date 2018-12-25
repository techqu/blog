#!/usr/bin/env bash


if [  -d "./public" ];then
rm -rf ./public/
else
echo "public文件夹重新创建"
fi


git clone https://github.com/techqu/techqu.github.io.git public
cd public
git config --local https.proxy socks5://127.0.0.1:1080
git config --local http.proxy socks5://127.0.0.1:1080
cd ..
hugo
cd public
git add .
git pull  origin master
git commit -m "add article"
git push origin master
rm -rf ./public/