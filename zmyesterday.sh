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

find /var/cache/zoneminder/events/inside/${gyear}/${gmonat}/${gtag} -name "*capture.jpg" -exec printf "%s\n" {} > /tmp/h_list.txt \;
#find /var/cache/zoneminder/events/10/${gyear}/${gmonat}/${gtag} -name "*capture.jpg" -exec printf "%s\n" {} >> /tmp/h_list.txt \;

sort -k9 -t'/' </tmp/h_list.txt >/tmp/h_list_s.txt

rm -rf /tmp/ffmpeg_files_h
mkdir /tmp/ffmpeg_files_h

x=0; for i in `cat /tmp/h_list_s.txt`; do counter=$(printf %05d $x); ln -s "$i" /tmp/ffmpeg_files_h/img"$counter".jpg; x=$(($x+1)); done

/usr/bin/ffmpeg -y -r 10 -f image2 -i /tmp/ffmpeg_files_h/img%05d.jpg -c:v libx264 -preset veryfast -an -crf 27 /tmp/tmp.avi

mv -f /tmp/tmp.avi /mnt/128/cam/${gestern}.avi

rm -rf /tmp/ffmpeg_files_h
