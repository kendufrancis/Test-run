#!/bin/bash

# Generate SSH Key Pair
# no pass phrase less security but a passphrase after the -N flag means you have to input it all the time
ssh-keygen -t rsa -b 2048 -f ~/.ssh/lms-key -N ""

# #run this script
# chmod +x generate_key_pair.sh
# ./generate_key_pair.sh

# run this script before you initialise terraform