#!/usr/bin/env bash

git clone  https://github.com/techqu/techqu.github.io.git ./public
git config --local https.proxy socks5://127.0.0.1:1080
git config --local http.proxy socks5://127.0.0.1:1080
hugo
git add .
git pull --rebase origin master
git commit -m "add article"
git push origin master
rm -rf ./public/