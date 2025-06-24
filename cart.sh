#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mongodb_host=mongodb.devopsupgrade.online
DATE=$(date +%F-%H-%M-%S)
logfile="/tmp/$0-$DATE.log"

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

dnf module disable nodejs -y &>> $logfile

validate $? "disabling existing node js version"

dnf module enable nodejs:18 -y &>> $logfile

validate $? "enabling node js version"

dnf install nodejs -y &>> $logfile

validate $? "installing node js version"

id roboshop

if [ $? -ne 0 ]
then
    useradd roboshop &>> $logfile
    validate $? "addind user"
else
    echo -e "$G user already existed"
fi

mkdir -p /app &>> $logfile

validate $? "creating the directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $logfile

validate $? "downloading cart application"

cd /app 

unzip -o /tmp/cart.zip &>> $logfile

validate $? "unzipping the cart application"

npm install &>> $logfile

validate $? "installing dependencies"

cp /home/centos/shell-scripting-project/cart.repo /etc/systemd/system/cart.service

validate $? "copying the cart application..."

systemctl daemon-reload &>> $logfile

validate $? "deamon-reload...."

systemctl enable cart &>> $logfile

validate $? "enabling cart application..."

systemctl start cart &>> $logfile

validate $? "starting cart application"
