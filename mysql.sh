#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGFILE_DIR="/var/log/expense_shell"
mkdir -p $LOGFILE_DIR
TIMESTAMP=$(date +%m-%d-%Y-%H-%M-%S)
LOGFILE=$(echo $0 | cut -d "." -f1)
LOGFILE_NAME="$LOGFILE_DIR/$LOGFILE-$TIMESTAMP.log"
#check user has root access

USERID=$(id -u)
if [ $USERID -ne 0 ]
then
    echo "Error!!!..You need root privileges to execute the script"
    exit 1
fi

VALIDATE(){
if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R Failed $N"
        exit 1
    else
        echo -e "$2 is $G Successful $N"
    fi
}

dnf list installed mysql-server >>$LOGFILE_NAME
if [ $? -ne 0 ]
then
    dnf install mysql-server -y &>>$LOGFILE_NAME
    VALIDATE $? "MYSQL Server Installation"
else
    echo -e "MYSQL Server Installation $Y already exists $N"
fi

systemctl enable mysqld
VALIDATE $? "MYSQL Server Enabled"
systemctl start mysqld
VALIDATE $? "MYSQL Server Started"

mysql -h mysqldb.manojvaddi.online -u root -pExpenseApp@1 -e 'show databases' &>>$LOGFILE_NAME
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "MYSQL Root Password is set"
else
    echo -e "MYSQL Root Password is $Y alredy set $N"
fi

