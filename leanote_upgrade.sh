#! /bin/bash

#############################
#--------------------------
#Обновление Leanote
#--------------------------
#############################

service mongodb stop
service leanote stop


cd /home/lea
tar -zcvf leanote_bk.tar.gz leanote
mkdir leanote_bk
mv leanote_bk.tar.gz leanote_bk/
mv leanote/app/ leanote_bk/
mv leanote/bin/ leanote_bk/
mv leanote/messages/ leanote_bk/
mv leanote/public/ leanote_bk/


cd /tmp
wget "https://netix.dl.sourceforge.net/project/leanote-bin/2.6.1/leanote-linux-amd64-v2.6.1.bin.tar.gz"
tar -xzvf leanote*
cp -r leanote/app/ /home/lea/leanote/
cp -r leanote/bin/ /home/lea/leanote/
cp -r leanote/messages/ /home/lea/leanote/
cp -r leanote/public/ /home/lea/leanote/
rm -r leanote/

cd /home/lea
chown -R lea:lea leanote

service mongodb start
service leanote start
