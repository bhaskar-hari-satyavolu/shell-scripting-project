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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $logfile

validate $? "downloading erlang script.."

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $logfile

validate $? "downloading rabbitmq script.."

dnf install rabbitmq-server -y &>> $logfile

validate $? "installing rabbitmq server.."

systemctl enable rabbitmq-server &>> $logfile

validate $? "enabling rabbitmq server.."

systemctl start rabbitmq-server &>> $logfile

validate $? "starting rabbitmq server.."

rabbitmqctl add_user roboshop roboshop123 &>> $logfile

validate $? "creating user.."

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $logfile

validate $? "setting permissions.."
