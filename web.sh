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

dnf install nginx -y &>> $logfile

validate $? "installing nginx..."

systemctl enable nginx &>> $logfile

validate $? "enabling nginx..."

systemctl start nginx &>> $logfile

validate $? "starting nginx..."

rm -rf /usr/share/nginx/html/* &>> $logfile

validate $? "removing existing html files"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $logfile

cd /usr/share/nginx/html

unzip -o /tmp/web.zip

validate $? "unzipping web application.."

cp /home/centos/shell-scripting-project/web.repo /etc/nginx/default.d/roboshop.conf &>> $logfile

validate $? "copying reverse proxy configurations"

systemctl restart nginx &>> $logfile

validate $? "restarting web application.."