#!/bin/bash
# Ugly script to generate MPEG files for archival purposes from zoneminder
# events.  Based upon original work by mikeyintn on zoneminder forums
# Written by Doc Elliott, alabamatoy[at]gmail[dot]com
# (and voluntarily modified by fuckel[at]ukr[dot]net)
# compiles Zoneminder event files (from default "record" functionality
# buit into Zoneminder) into 1 hour .mp4 files which are named
# camX_20yy_mm_dd_hh.mp4 where YY is the year, mm is the month,
# dd is the day and hh is the hour (00 through 23).
# various files are stored in /tmp for gathering the data
# and organizing the output.
#
# This was written on Ubuntu 16.04 LTS with Zoneminder 1.29
#
# useage:  ./new_zm_export.sh mm dd
# example: ./new_zm_export.sh 08 13
#          would collect all the event files from Aug 13
#          and compile them into 1 hour avi videos.
#
# Discussion: https://forums.zoneminder.com/viewtopic.php?f=11&t=24686

# Set to wherever the stuff is on your installation
# NOTE: Avoid the trailing slash here!
events_dir="/var/cache/zoneminder/events"
archive_dir="/usr/share/zoneminder/www/video"
ffmpeg_dir="/usr/bin/ffmpeg"

# Make the script insensitive to $events_dir's depth
arg_shift=$(tr -cd / <<< $events_dir |wc -c)

# Check for input
if [ "$1" != "" ]
then
 dateval=$(date)
 echo ""
 echo "Starting at "$dateval
 echo "looking for month = "$1" and day = "$2
 echo " "
 DESIREDMONTH=$1
 DESIREDDAY=$2
else
 DESIREDDAY="nothing"
 DESIREDMONTH="nothing"
 echo "No dates selected!"
 exit
fi

# Initialize variables and set first pass
VIDEOFN="nothing"
FIRSTPASS="yes"
VERBOSE="yes"
PREVHOUR="nothing"
CAM="nothing"
YEAR="nothing"
MONTH="nothing"
DAY="nothing"
HOUR="nothing"
MIN="nothing"
SEC="nothing"

# Cleanup from last time
if [ "$VERBOSE" == "yes" ]
then
 echo "Cleaning up from last time..."
 echo " "
fi

rm /tmp/*events.txt
rm /tmp/*.list

# Find all files called "00001-capture.jpg" indicating the start of a new
# folder of capture files and print this found list to a file
# Symlinks are excluded
 echo "Finding..."
 echo " "

for cam_dir in $(find $events_dir/* -maxdepth 0 -type d)
 do find $cam_dir/*/$1/$2 -name "00001-capture.jpg" -print >> /tmp/unsortedallevents.txt 2>/dev/null
done

# Sort that file of found captures into ascending order
 echo "Sorting..."
 echo " "

sort -n /tmp/unsortedallevents.txt > /tmp/allevents.txt

# Begin reading from the file containing all the sorted capture files by line
echo "Looking for specific files to compile..."
echo " "

while read EVENTDIRS
  do
    CAM="$(echo $EVENTDIRS |awk -F/ '{print $'$(( $arg_shift + 2 ))'}')"
    YEAR="$(echo $EVENTDIRS |awk -F/ '{print $'$(( $arg_shift + 3 ))'}')"
    MONTH="$(echo $EVENTDIRS |awk -F/ '{print $'$(( $arg_shift + 4 ))'}')"
    DAY="$(echo $EVENTDIRS |awk -F/ '{print $'$(( $arg_shift + 5 ))'}')"
    HOUR="$(echo $EVENTDIRS |awk -F/ '{print $'$(( $arg_shift + 6 ))'}')"
    MIN="$(echo $EVENTDIRS |awk -F/ '{print $'$(( $arg_shift + 7 ))'}')"
    SEC="$(echo $EVENTDIRS |awk -F/ '{print $'$(( $arg_shift + 8 ))'}')"

if [ "$VERBOSE" == "yes" ]
then
 echo "cam= "$CAM
 echo "Year= "$YEAR
 echo "Month= "$MONTH
 echo "Day= "$DAY
 echo "Hour= "$HOUR
 echo "Min= "$MIN
 echo "Sec= "$SEC
 echo $EVENTDIRS
 echo " "
fi

if [ "$DESIREDMONTH" != "nothing" ]
then
  if [ "$DESIREDMONTH" == "$MONTH" ] && [ "$DESIREDDAY" == "$DAY" ]
  then  

# Note - this will fail at end of the century.  Party like its 2099...
    HOURNAME="/tmp/cam"$CAM"_20"$YEAR"_"$MONTH"_"$DAY"_"$HOUR".list"

    echo "file '$events_dir/"$CAM"/"$YEAR"/"$MONTH"/"$DAY"/"$HOUR"/"$MIN"/"$SEC"/%05d-capture.jpg'" >> $HOURNAME

    printf "\r%s" "Found: Camera"$CAM", "$MONTH" "$DAY", 20"$YEAR" hour: "$HOUR

# Note - can have degenerate situation where cam/year/month/day/hour and next would have same hour.
    if [ "$PREVHOUR" != "$HOUR" ]
    then 
       #new hour line
       echo $HOURNAME >> /tmp/hours.list
       PREVHOUR=$HOUR
    fi
  fi
fi

done < /tmp/allevents.txt 

echo " "

while read LISTTOPROCESS
do
   VIDEOFN="$(echo $LISTTOPROCESS |awk -F/ '{print $3}')"

   VIDEOFN="$(echo $VIDEOFN |awk -F. '{print $1".mp4"}')"

# NOTE - need to direct ffmpeg output to a file, other clobber stdout

# Process the list of files into 1 hour video
echo "Processing "$LISTTOPROCESS
echo "Output file "$archive_dir"/"$VIDEOFN
  if [ "$VERBOSE" == "yes" ]
  then
    # You should use correct '-r' value to avoid a Charlie Chaplin video :D
    $ffmpeg_dir -nostdin -safe 0 -f concat -i $LISTTOPROCESS -r 25 -codec libx264 $archive_dir/$VIDEOFN
  else
    $ffmpeg_dir -nostdin -safe 0 -f concat -i $LISTTOPROCESS -r 25 -loglevel 24 -codec libx264 $archive_dir/$VIDEOFN
  fi

done < /tmp/hours.list

#move files to where webserver can see them?

echo " "
dateval=$(date)
echo "All done at "$dateval

exit
