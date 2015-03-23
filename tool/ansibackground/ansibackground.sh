#!/bin/bash
# Print array of ANSI colors.
# Foreground text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white

for attr in 0 1 4 5 7 ; do
echo "----------------------------------------------------------------"
printf "ESC[%s;Foreground;Background - \n" $attr
for fore in 30 31 32 33 34 35 36 37; do
for back in 40 41 42 43 44 45 46 47; do
printf '\033[%s;%s;%sm %02s;%02s ' $attr $fore $back $fore $back
done
printf '\n'
done
printf '\033[0m'
done
#
# example
# 
# export PS1="\e[4;34;42m[\!]\u@\h>\e[m"

