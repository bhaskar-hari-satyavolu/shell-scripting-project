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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $logfile

validate $? "downloading catlogue application"

cd /app 

unzip -o /tmp/catalogue.zip &>> $logfile

validate $? "unzipping the catlogue application"

npm install &>> $logfile

validate $? "installing dependencies"

cp /home/centos/shell-scripting-project/catalogue.service /etc/systemd/system/catalogue.service &>> $logfile

validate $? "copying the catlogue service"

systemctl daemon-reload &>> $logfile

validate $? "daemon -reload"

systemctl enable catalogue &>> $logfile

validate $? "enabling the catlogue service"

systemctl start catalogue &>> $logfile

validate $? "starting the catlogue service"

cp /home/centos/shell-scripting-project/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile

validate $? "copying the mongodb"

dnf install mongodb-org-shell -y &>> $logfile

validate $? "installing the mongo client"

mongo --host $mongodb_host </app/schema/catalogue.js &>> $logfile

validate $? "Loading catlogue data into mongodb"


