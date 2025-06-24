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

dnf install python36 gcc python3-devel -y

validate $? "installing python.."

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $logfile

cd /app 

unzip -o /tmp/payment.zip &>> $logfile

validate $? "unzipping payment application.."

pip3.6 install -r requirements.txt &>> $logfile

validate $? "installing requirements..."

cp /home/centos/shell-scripting-project/payment.service /etc/systemd/system/payment.service &>> $logfile

systemctl daemon-reload &>> $logfile

validate $? "daemon-reload...."

systemctl enable payment &>> $logfile

validate $? "enabling payment..."

systemctl start payment &>> $logfile

validate $? "starting payment...."