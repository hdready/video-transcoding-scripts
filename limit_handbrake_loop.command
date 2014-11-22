#!/bin/bash

echo "Make sure cpulimit is installed via Homebrew Cask (brew install cpulimit)"
# This is an endless loop meant to run on startup alongside crop-transcode-batch.sh

while :
do

echo
# readout number of CPUs
number_cpus="$(getconf _NPROCESSORS_ONLN)"
# default percentage used in case user enters no value
default_percentage="80"

# in case user has not put in any value, default or previously entered percentage will be used
cpu_input="${cpu_input:-$default_percentage}"

# user has 15 seconds to input other value than the default percentage or correct the last input
if [ $default_percentage == $cpu_input ]; then
echo "Please enter the maximum percentage of CPU HandBrake may use"
echo "wait 15 seconds to use the default value: $cpu_input%"
else
echo "Please enter the maximum percentage of CPU HandBrake may use 
echo "or wait 15 seconds to use your last input: $cpu_input%"
fi

read -t 15 cpu_input

# remove %-character from cpu_input
cpu_input=${cpu_input//[%]/}
# calculate cpulimit
cpu_max=$(($number_cpus * $cpu_input))

if [ $default_percentage == $cpu_input ]; then
    echo "Using default CPU usage: $cpu_max%"
    echo "This is $cpu_input% on each of your $number_cpus CPUs"
else
    echo "Maximum CPU usage is $cpu_max%"
    echo "This is $cpu_input% on each of your $number_cpus CPUs"
fi


# check for HandBrakeCLI process ID
HandBrakePID="$(ps -A | grep -m1 HandBrakeCLI | awk '{print $1}')"

#set cpulimit
cpulimit --pid $HandBrakePID --limit $cpu_max
echo "HandBrakeCLI with process ID $HandBrakePID will be limited to $cpu_max%"

echo
echo "HandBrake is done"
echo "Checking for new HandBrake process in 15 seconds"
sleep 15

done