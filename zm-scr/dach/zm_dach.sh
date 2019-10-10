#!/bin/bash

trap '' HUP

heute=`date +"%F"`
gestern=`date --date="1 days ago" +"%F"`
Year=`date +"%Y"`
year=`date +"%y"`
gYear=`date --date="1 days ago" +"%Y"`
gyear=`date --date="1 days ago" +"%y"`
monat=`date +"%m"`
gmonat=`date --date="1 days ago" +"%m"`
tag=`date +"%d"`
gtag=`date --date="1 days ago" +"%d"`
std=`date +"%H"`
vstd=`date --date="1 hour ago" +"%H"`

sudo systemctl stop zoneminder.service

echo "`date +%Y-%m-%d_%H-%M-%S` start find and sort" >> /home/frank/dach_test.log

find /var/cache/zoneminder/events/11/${gyear}/${gmonat}/${gtag}/2[0-3] -name "*capture.jpg" -exec printf "%s\n" {} > /tmp/h_list.txt \;
find /var/cache/zoneminder/events/11/${year}/${monat}/${tag}/0[0-8] -name "*capture.jpg" -exec printf "%s\n" {} >> /tmp/h_list.txt \;

sort -k9 -t'/' </tmp/h_list.txt >/tmp/h_list_s.txt

rm -rf /tmp/ffmpeg_files_d
mkdir /tmp/ffmpeg_files_d

echo "`date +%Y-%m-%d_%H-%M-%S` start loop" >> /home/frank/dach_test.log

x=0; for i in `cat /tmp/h_list_s.txt`; do counter=$(printf %06d $x); ln -s "$i" /tmp/ffmpeg_files_d/img"$counter".jpg; x=$(($x+1)); done

echo "`date +%Y-%m-%d_%H-%M-%S` start veryfast ffmpeg" >> /home/frank/dach_test.log

#/usr/bin/ffmpeg -y -r 10 -f image2 -i /tmp/ffmpeg_files_d/img%06d.jpg -c:v libx264 -preset veryfast -an -crf 27 /tmp/last_night_v.avi

#mv /tmp/last_night_v.avi /mnt/500/cam/nachts_auf_dem_dach/Nacht_zum_${heute}_veryfast.avi

echo "`date +%Y-%m-%d_%H-%M-%S` veryfast end" >> /home/frank/dach_test.log

echo "`date +%Y-%m-%d_%H-%M-%S` start ultrafast ffmpeg" >> /home/frank/dach_test.log

/usr/bin/ffmpeg -y -r 10 -f image2 -i /tmp/ffmpeg_files_d/img%06d.jpg -c:v libx264 -preset ultrafast -an -crf 27 /tmp/last_night_u.avi

mv /tmp/last_night_u.avi /mnt/500/cam/nachts_auf_dem_dach/Nacht_zum_${heute}_ultrafast.avi

echo "`date +%Y-%m-%d_%H-%M-%S` ultrafast end" >> /home/frank/dach_test.log

sudo systemctl start zoneminder.service

rm /tmp/*.avi /tmp/*.txt
rm -rf /tmp/ffmpeg_files_d
