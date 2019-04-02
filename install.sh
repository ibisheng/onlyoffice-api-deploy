#!/usr/bin/env bash
if [ ! -n "$1" ] ;then
    echo "必须指定一个安装目录"
    exit
fi

if [ ! -x "$1" ] ;then
     mkdir "$1"
fi

echo "copy resource data"

rm -rf $1/*
docker rm nginx minio redis rabbit mongod  editor_app convert editor -f  1 > /dev/null 2>&1
docker network create bisheng 1 > /dev/null 2>&1

export basedir=$1
export tag=free
sh pullImage.sh $tag

echo "$1 free" > .config

mkdir $1/service
mkdir $1/workspace
mkdir $1/resource
mkdir $1/nginx

cp -r service/* $1/service
cp -r workspace/* $1/workspace
cp -r resource/* $1/resource
cp -r nginx/* $1/nginx


cd $1/service

mkdir -p mongod/db mongod/log
touch  mongod/log/mongod.log
mkdir -p rabbitmq/data
mkdir -p minio/config minio/data
mkdir -p nginx/temp nginx/keys
touch  nginx/temp/error.log
touch  nginx/temp/access.log
#mkdir  nginx/config/conf.d
#sed -e 's/HOST/'$2'/g' ../workspace/config/bisheng.conf >  nginx/config/conf.d/bisheng.conf




docker-compose up -d

cd -



#cp config.sample.yml config.yml

#sed -e 's/HOST/'$2'/g' workspace/config/config.sample.yml > $1/workspace/config/config.yml

sleep 60


bash init.sh 7 free $1


bash initAdminPass.sh bisheng

cd $1/workspace
mkdir temp
mkdir logs

docker-compose up -d

sleep 30

cd -






cd $1/nginx
docker-compose up -d



echo "在你的浏览器中打开 http://IP 即可访问毕升文档，请参看安装文档激活毕升文档"
