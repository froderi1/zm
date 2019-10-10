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

find /var/cache/zoneminder/events/11/${year}/${monat}/${tag}/${vstd} -name "*capture.jpg" -exec printf "%s\n" {} > /tmp/d_list.txt \;

sort </tmp/d_list.txt >/tmp/d_list_s.txt

rm -rf /tmp/ffmpeg_files_d
mkdir /tmp/ffmpeg_files_d
cd /tmp

x=0; for i in `cat /tmp/d_list_s.txt`; do counter=$(printf %05d $x); ln -s "$i" /tmp/ffmpeg_files_d/img"$counter".jpg; x=$(($x+1)); done

/usr/bin/ffmpeg -y -r 10 -f image2 -i /tmp/ffmpeg_files_d/img%05d.jpg -c:v libx264 -preset veryfast -an -crf 27 dach_last_hour.avi

if [ ! -f /mnt/500/cam/nachts_auf_dem_dach/dach.avi ]; then
	mv dach_last_hour.avi /mnt/500/cam/nachts_auf_dem_dach/dach.avi
else
	ffmpeg -i "concat:/mnt/500/cam/nachts_auf_dem_dach/dach.avi|dach_last_hour.avi" -c copy dach.avi
	mv -f dach.avi /mnt/500/cam/nachts_auf_dem_dach/dach.avi
fi

rm -rf /tmp/ffmpeg_files_d

