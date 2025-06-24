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

dnf module disable mysql -y &>> $logfile

validate $? "disabling existing mysql"

cp /home/centos/shell-scripting-project/mysql.repo /etc/yum.repos.d/mysql.repo &>> $logfile

validate $? "copying the mysql.."

dnf install mysql-community-server -y &>> $logfile

validate $? "installing mysql server..."

systemctl enable mysqld &>> $logfile

validate $? "enabling the mysql"

systemctl start mysqld $>> $logfile

validate $? "starting the mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $logfile

validate $? "setting the username and password to connect mysql..."
