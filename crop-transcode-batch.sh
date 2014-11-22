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

../transcode-video.sh --mkv --big --slow --add-audio 2 --add-audio 3 --add-audio 4 $crop_option "../transcode/$input"

input="$(sed -n 1p "$trans_queue")"
done


echo "Waiting 60 seconds for restart..."
sleep 30
echo "Waiting 30 seconds for restart..."
sleep 25
echo "Waiting 5 seconds for restart..."
sleep 5

cd ..
pwd

done