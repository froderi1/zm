#!/bin/bash
# Ugly script to generate MPEG files for archival purposes from zoneminder events
# Change the following two variables to accomodate your install and where you want the videos exported
# NOTE: Also manually change part of line 29 to what your events_dir is... I couldn't figure out how to get that to work with awk directly
# as well as changing lines 55 and 71 if your FFMPEG binary isn't where mine is..
events_dir=/var/cache/zoneminder/events/   
archive_dir=/mnt/320/nas/cam

# Initialize variables and set first pass
DATETOENCODE="nothing"
EVENTPATH="nothing"
PREVDAY="nothing"
VIDEOFN="nothing"
FIRSTPASS="yes"

# Lets make a TO DO list for all the events that includes the first captured image
# This makes sure there is actually something there to encode

cd $events_dir
# If you don't want the ENTIRE server's events and just want the latest week's worth
# then just add something like -mtime -7 before the "-print" part.  That's what I did later so I could have a weekly cron job.
find ./ -name "00001-capture.jpg" -mtime -1 -print > /tmp/unsortedallevents.txt
sort -n /tmp/unsortedallevents.txt > /tmp/allevents.txt

# Begin reading from the file containing all the sorted events directories line by line
while read EVENTDIRS
  do
    DATETOENCODE="$(echo $EVENTDIRS |awk -F/ '{print "./"$2"/"$3"/"$4"/"$5}')"
    EVENTPATH="$(echo $EVENTDIRS |awk -F/ '{print "/var/cache/zoneminder/events/"$2"/"$3"/"$4"/"$5"/"$6"/"$7"/"$8"/"}')"
    FULLEVENTPATH=$EVENTPATH
    FULLEVENTPATH+="%05d-capture.jpg"

    echo -n $DATETOENCODE; echo " DATETOENCODE"
    echo -n $PREVDAY; echo " PREVDAY read in"
    #Determine if this is the first pass and skip this comparison if it is or if mult events on same day
    if [ "$FIRSTPASS" == "yes" ] || [ "$DATETOENCODE" == "$PREVDAY" ]
    then
     PREVDAY=$DATETOENCODE
     FIRSTPASS="no"
     # Add it to the list of directories to process
     echo "file '"$FULLEVENTPATH"'" >> /tmp/dirs_to_process
     echo "file '"$FULLEVENTPATH"'"
     # Time to grab another record from the all_events.txt file
    else
     echo " " >> /tmp/dirs_to_process
     # Sleep a few seconds before encoding new file
     sleep 5
     # Ok, so you might notice in the next line, this is assuming Y2k and later for the footage and should work until y3k 
     VIDEOFN="$(echo $PREVDAY |awk -F/ '{print "20"$3"-"$4"-"$5"_cam_"$2".avi"}')"
     echo "------ this is what is in the dir_to_process_file ---------"
     cat /tmp/dirs_to_process
     echo "------ this is the directory and filename to save to ------"
     echo $archive_dir $VIDEOFN
     # This is where RHEL put my FFMPEG binary, if yours is in a different spot update the location
     /usr/bin/ffmpeg -nostdin -f -safe 0 concat -i /tmp/dirs_to_process -r 18 -qscale:v 10 -codec mpeg4 /$archive_dir/$VIDEOFN
	 #/usr/bin/ffmpeg -y -r 5 -i /var/cache/zmtmp/frame-%08d.jpg -b 2000k /mnt/nas/cam/today_tmp.mp4
     sleep 5
     rm /tmp/dirs_to_process
     PREVDAY=$DATETOENCODE
     FIRSTPASS="yes"
    fi
  done < /tmp/allevents.txt

# And now process the very last one as there are no more entries in the file to encode
     sleep 7
     VIDEOFN="$(echo $PREVDAY |awk -F/ '{print "20"$3"-"$4"-"$5"_cam_"$2".avi"}')"
     echo "------------------what is in the dir_to_process_file----------"
     cat /tmp/dirs_to_process
     echo "------------------this is the filename and directory to save to --------"
     echo $archive_dir $VIDEOFN
     # This is where RHEL put my FFMPEG binary, if yours is in a different spot update the location
     /usr/bin/ffmpeg -nostdin -f -safe 0 concat -i /tmp/dirs_to_process -r 18 -qscale:v 10 -codec mpeg4 /$archive_dir/$VIDEOFN
	 #/usr/bin/ffmpeg -y -r 5 -i /var/cache/zmtmp/frame-%08d.jpg -b 2000k /mnt/nas/cam/today_tmp.mp4

sleep 10
rm /tmp/allevents.txt
rm /tmp/unsortedallevents.txt
rm /tmp/dirs_to_process
exit
