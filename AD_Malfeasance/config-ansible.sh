#!/bin/bash

# Add a check for pip here !!!!!!!


# use pip to install ansible for the current user
python3 -m pip install --user ansible

# export the ansible installation path to work with current user
export PATH="/home/$USER/.local/bin:$PATH"
