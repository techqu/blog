#!/usr/bin/env bash


if [  -d "./public" ];then
rm -rf ./public/
else
echo "public文件夹重新创建"
fi


git clone https://github.com/techqu/techqu.github.io.git public

echo "quguang.wang" > ./public/CNAME
hugo
cd public
git add .
git pull  origin master
git commit -m "add article"
git push origin master
rm -rf ./public/