#!/bin/bash
heute=`date +"%F"`
gestern=`date --date="1 days ago" +"%F"`
heute=`date +"%F"`
gestern=`date --date="1 days ago" +"%F"`

monat=`date +"%m"`
gmonat=`date --date="1 days ago" +"%m"`
tag=`date +"%d"`
gtag=`date --date="1 days ago" +"%d"`

find /var/cache/zoneminder/events/11/17/${gmonat}/${gtag}/2[0-3] -name "Event*.avi" -exec printf "file '%s'\n" {} > /tmp/mylist.txt \;
find /var/cache/zoneminder/events/11/17/${monat}/${tag}/0[0-7] -name "Event*.avi" -exec printf "file '%s'\n" {} >> /tmp/mylist.txt \;

sort -t "/" -k 13 </tmp/mylist.txt >/tmp/mylist_sorted.txt

/usr/bin/ffmpeg -f concat -safe 0 -i /tmp/mylist_sorted.txt -y -c copy /mnt/500/cam/nachts_auf_dem_dach/Nacht_zum_${heute}.avi

