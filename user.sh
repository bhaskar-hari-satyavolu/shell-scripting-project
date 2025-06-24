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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $logfile

validate $? "downloading user application"

cd /app 

unzip -o /tmp/user.zip &>> $logfile

validate $? "unzipping the user application"

npm install &>> $logfile

validate $? "installing dependencies"

cp /home/centos/shell-scripting-project/user.repo /etc/systemd/system/user.service &>> $logfile

validate $? "copying the repo"

systemctl daemon-reload &>> $logfile

validate $? "daemon-reload...."

systemctl enable user &>> $logfile

validate $? "enabling user..."

systemctl start user &>> $logfile

validate $? "starting user...."

cp /home/centos/shell-scripting-project/mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile

dnf install mongodb-org-shell -y &>> $logfile

validate $? "installing mongodb clinet..."

mongo --host mongodb.devopsonline.upgrade </app/schema/user.js &>> $logfile

validate $? "Loading user data into mongodb"

