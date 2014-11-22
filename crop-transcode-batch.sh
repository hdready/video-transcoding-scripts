#!/bin/bash

readonly work="$(cd "$(dirname "$0")" && pwd)"
readonly queue="$work/crop-queue.txt"
readonly trans_queue="$work/transcode-queue.txt"
readonly trans_crops="$work/crops"

while :

do

cd transcode
pwd

ls > ../crop-queue.txt
ls > ../transcode-queue.txt

input="$(sed -n 1p "$queue")"

while [ "$input" ]; do
title_name="$(basename "$input" | sed 's/\.[^.]*$//')"

sed -i '' 1d "$queue" || exit 1

../detect-crop.sh "$input"

input="$(sed -n 1p "$queue")"
done

cd ../done
pwd

input="$(sed -n 1p "$trans_queue")"

while [ "$input" ]; do
title_name="$(basename "$input" | sed 's/\.[^.]*$//')"
crop_file="$trans_crops/${title_name}.txt"

if [ -f "$crop_file" ]; then
crop_option="--crop $(cat "$crop_file")"
else
crop_option=''
fi

sed -i '' 1d "$trans_queue" || exit 1

../transcode-video.sh --mkv --big --slow --add-audio 2 --add-audio 3 --add-audio 4 --move-to-directory "/Volumes/Simple Storage Service/Filme/" $crop_option "../transcode/$input"

input="$(sed -n 1p "$trans_queue")"
done



echo "Waiting 10 minutes for restart..."
sleep 60
echo "Waiting  9 minutes for restart..."
sleep 60
echo "Waiting  8 minutes for restart..."
sleep 60
echo "Waiting  7 minutes for restart..."
sleep 60
echo "Waiting  6 minutes for restart..."
sleep 60
echo "Waiting  5 minutes for restart..."
sleep 60
echo "Waiting  4 minutes for restart..."
sleep 60
echo "Waiting  3 minutes for restart..."
sleep 60
echo "Waiting  2 minutes for restart..."
sleep 60
echo "Waiting 60 seconds for restart..."
sleep 30
echo "Waiting 30 seconds for restart..."
sleep 25
echo "Waiting  5 seconds for restart..."
sleep 1
echo "Waiting  4 seconds for restart..."
sleep 1
echo "Waiting  3 seconds for restart..."
sleep 1
echo "wait for it..."
sleep 1
echo "Here we go again!"
sleep 1

cd ..
pwd

done