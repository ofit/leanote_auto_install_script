#! /bin/bash

#############################
#--------------------------
#Установка Leanote
#--------------------------
#############################


###########
#Переменные Leanote
###########

#Пользователь под которым будет запускаться deluge server
newuser=lea

#Домашняя папка нового пользователя
homedir=/home/$newuser


#Проверка существет ли пользователь указаный выше
if [ $(getent passwd $newuser) ] ; then
       echo "User exist"
   else
   #Создает пользователя и группу без логина и без пароля с домашней папкой
   adduser --system --gecos "Leanote" --disabled-password --disabled-login --group --home $homedir $newuser
fi


###Unpack leanote
cd $homedir
wget "https://sourceforge.net/projects/leanote-bin/files/2.5/leanote-linux-amd64-v2.5.bin.tar.gz"
tar -xzvf leanote*
chown -R $newuser:$newuser $homedir/leanote*


###Install the database -- Mongodb
wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.1.tgz
tar -xzvf mongodb*
chown -R $newuser:$newuser $homedir/mongodb*


###Test Mongodb installation
mkdir $homedir/data
chown -R $newuser:$newuser $homedir/data



### Setup mongod Demon
echo "[Unit]
Description=An object/document-oriented database
Documentation=man:mongod(1)

[Service]
User=$newuser
ExecStart=$homedir/mongodb-linux-x86_64-3.0.1/bin/mongod --dbpath $homedir/data --port 27111

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/multi-user.target.wants/mongodb.service

systemctl daemon-reload
service mongodb start

sleep 7

#Import initial Leanote data
$homedir/mongodb-linux-x86_64-3.0.1/bin/mongorestore -h localhost -d leanote --dir $homedir/leanote/mongodb_backup/leanote_install_data/ --port 27111

# $homedir/mongodb-linux-x86_64-3.0.1/bin/mongo --eval "use leanote; db.createUser({
#     user: 'wolflea',
#     pwd: 'qaz123',
#     roles: [{role: 'dbOwner', db: 'leanote'}]
# });"


$homedir/mongodb-linux-x86_64-3.0.1/bin/mongo --port 27111 <<EOF
use leanote
db.createUser({
    user: 'Bausesmla',
    pwd: 'NTQzNjJjYjctZTFkNDlk',
    roles: [{role: 'dbOwner', db: 'leanote'}]
});
EOF

cd $homedir/leanote/conf/

find . -type f -name 'app.conf' -exec sed -i -r 's/db.username=/db.username=Bausesmla/g' {} \;
find . -type f -name 'app.conf' -exec sed -i -r 's/db.password=/db.password=NTQzNjJjYjctZTFkNDlk/g' {} \;
find . -type f -name 'app.conf' -exec sed -i -r 's/db.port=27017/db.port=27111/g' {} \;
find . -type f -name 'app.conf' -exec sed -i -r 's/V85ZzBeTnzpsHyjQX4zukbQ8qqtju9y2aDM55VWxAH9Qop19poekx3xkcDVvrD0y/V33ZzBeTnzpsHyjQX4zukbQ8qqtju9y2aDM55VWxAH9Qop19poekx3xkcDVvrD0y/g' {} \;


service mongodb stop
sleep 5
### Setup mongod Demon
echo "[Unit]
Description=An object/document-oriented database
Documentation=man:mongod(1)

[Service]
User=$newuser
ExecStart=$homedir/mongodb-linux-x86_64-3.0.1/bin/mongod --dbpath $homedir/data --auth --port 27111

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/multi-user.target.wants/mongodb.service

systemctl daemon-reload
service mongodb start


### Setup Leanote Demon
echo "[Unit]
Description=Leanote, Not Just A Notepad!

[Service]
User=$newuser
ExecStart=/bin/bash $homedir/leanote/bin/run.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/multi-user.target.wants/leanote.service

systemctl daemon-reload
service leanote start
