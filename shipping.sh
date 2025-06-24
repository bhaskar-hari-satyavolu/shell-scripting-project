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

dnf install maven -y &>> $logfile

validate $? "installing maven.."

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

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $logfile

validate $? "downloading shipping application"

cd /app

unzip -o /tmp/shipping.zip

validate $? "unzipping shipping application"

mvn clean package &>> $logfile

mv target/shipping-1.0.jar shipping.jar 

cp /home/centos/shell-scripting-project/shipping.service /etc/systemd/system/shipping.service &>> $logfile

validate $? "copying shipping configurations"

systemctl daemon-reload &>> $logfile

validate $? "deamon-reload...."

systemctl enable shipping &>> $logfile

validate $? "enabling shipping application..."

systemctl start shipping &>> $logfile

validate $? "starting shipping application"

dnf install mysql -y &>> $logfile

validate $? "installing mysql"

mysql -h mysql.devopsupgrade.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$logfile

validate $? "loading shipping data"

systemctl restart shipping &>> $logfile

validate $? "restarting shipping application..."