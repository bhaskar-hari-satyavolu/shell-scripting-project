#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mongodb_host=mongodb.devopsupgrade.online
DATE=$(date +%F-%H-%M-%S)
logfile="/tmp/$0-$DATE.log"

exec &>$logfile #logs will run in backgroud if we want to check open another terminal and tail -f /tmp/..log

echo "script started executing at $DATE"

validate(){

    if [ $1 -ne 0 ]
    then 
        echo "ERROR:: $2 Failed"
        exit 1
    else
        echo -e "$2... $G success $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR::$N run the script with root user"
    exit 1
else
    echo "You are a root user"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y

validate $? "installing remi-release..."

dnf module enable redis:remi-6.2 -y

validate $? "enabling module..."

dnf install redis -y

validate $? "installing redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf

validate $? "updated the listen address.."

systemctl enable redis

validate $? "enabling redis"

systemctl start redis

validate $? "starting redis"