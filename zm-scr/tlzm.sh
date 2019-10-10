#!/bin/bash

datum=`date +%Y-%m-%d`

cd ~/tlp

# echo "`date +%Y-%m-%d_%H-%M-%S` Timelapse start" >> ~/tlp/$datum/tl_log
# raspistill -w 1440 -h 1080 -q 75 --annotate 12 -o ~/tlp/$datum/tl_%07d.jpg -t $(( $dura * 60000 )) -tl $(( $inte * 1000 ))
# echo "`date +%Y-%m-%d_%H-%M-%S` Timelapse end" >> ~/tlp/$datum/tl_log

avconv -r 5 -i /mnt/500/$datum/*.jpg -r 10 -vcodec libx264 -crf 20 -g 15 ${datum}_tl.mp4

