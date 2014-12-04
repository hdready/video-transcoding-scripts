#!/bin/bash

cd convert
pwd

ls > ../convert-queue.txt

readonly work="$(cd "$(dirname "$0")" && pwd)"
readonly queue="$work/convert-queue.txt"

cd ../done
pwd

input="$(sed -n 1p "$queue")"

while [ "$input" ]; do

title_name="$(basename "$input" | sed 's/\.[^.]*$//')"

sed -i '' 1d "$queue" || exit 1

../convert-video.sh "../convert/$input"

input="$(sed -n 1p "$queue")"
done


