
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
# save cpu_input for errors
cpu_input_old="$cpu_input"

# user has 30 seconds to input other value than the default percentage or correct the last input
if [ $default_percentage == $cpu_input ]; then
echo "Please enter the maximum percentage of CPU HandBrake may use"
echo "or wait 30 seconds to use the default value: $cpu_input%"
else
echo "Please enter the maximum percentage of CPU HandBrake may use"
echo "or wait 30 seconds to use your last input: $cpu_input%"
fi


read -t 30 cpu_input
echo

# remove %-character from cpu_input
cpu_input=${cpu_input//[%]/}
# empty cpu_input returns default value
re='^[0-9]+$'
if ! [[ $cpu_input =~ $re ]]; then
    echo "$cpu_input is invalid, using default value."
    cpu_input=$cpu_input_old
elif [ $cpu_limit >= 101 ]; then
    echo "More than 100% is not possible, using default value."
    cpu_input=$cpu_input_old

fi

# calculate cpulimit
cpu_max=$(($number_cpus * $cpu_input))

if [ $default_percentage == $cpu_input ]; then
    echo "Limiting CPU usage to $cpu_max% (default value)."
    else
    echo "Limiting CPU usage to $cpu_max%."
fi

echo "This is $cpu_input% on each of your $number_cpus CPUs."
echo

# check for HandBrakeCLI process ID
HandBrakePID="$(ps -A | grep -m1 HandBrakeCLI | awk '{print $1}')"

#set cpulimit
cpulimit --pid $HandBrakePID --limit $cpu_max
echo "Press CTRL-C to set a different CPU limit..."

echo
echo "HandBrake is done, checking for new HandBrake process"

done
