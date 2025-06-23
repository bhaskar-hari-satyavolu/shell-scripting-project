#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $logfile

validate $? "copied MongoDB repo" 

dnf install mongodb-org -y &>> $logfile

validate $? "Installing mongodb"

systemctl enable mongod &>> $logfile

validate $? "enabling mongodb"

systemctl start mongod &>> $logfile

validate $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $logfile

validate $? "Updated address"

systemctl restart mongod &>> $logfile

validate $? "restarting mongod" 