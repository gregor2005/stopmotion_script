#!/bin/bash
# author: gregor binder <gregor.binder@catrix.at>
# license: GPLv3
# description: this script generates a stop motion movie from given files, see usage message
# date: 25.12.2013
# last change 27.12.2013

movie_player=/usr/bin/vlc

function cleanUp {
        echo cleanup
}

function checkExitStatus {
        if [ $1 -ne 0 ]; then
                echo "!!! command failure !!! $2"
                cleanUp
                exit 1
        fi
}

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ] || [ -z $4 ] || [ -z $5 ]
then
        echo "usage: $0 <animation-name> <width> <height> <framerate> <outputfolder>"
        exit 1
else
        name=$1
	width=$2
	height=$3
	framerate=$4
	dimension=$width"x"$height"!"
	dimension_check=$width"x"$height
	folder=$5
fi

mkdir $folder

count=0
for i in *.jpg
do 
	((count++))
done

for i in *.jpg
do
        echo "Resizing $i to $dimension"
	if [ -e $folder/$i ]; then
		i_dimension=`identify $folder/$i | cut -d " " -f 3`
		if [ $i_dimension == $dimension_check ]; then
			echo "no change needed"
		else
			echo "convert image $i"
		        convert -resize $dimension $i $folder/$i
		fi
	else
		echo "convert image $i"
	        convert -resize $dimension $i $folder/$i
	fi
done

ls $folder/*.jpg | jpeg2yuv -f $framerate -b 1 -n $count -I p | yuvfps -r 25:1 | yuv2lav -o $name.avi
checkExitStatus $? "create stopmotion"

echo "Movie create $name.avi"

$movie_player $name.avi
