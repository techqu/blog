#!/usr/bin/env bash
hugo
cd ./public
git init
git remote add origin  https://github.com/techqu/techqu.github.io.git
git config --local https.proxy socks5://127.0.0.1:1080
git config --local http.proxy socks5://127.0.0.1:1080
git add .
git pull --rebase origin master
git commit -m "add article"
git push origin master
rm -rf ./public/