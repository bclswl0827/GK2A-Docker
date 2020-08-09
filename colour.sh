#!/bin/bash

# System environment
export DOTNET_ROOT=/usr/local/bin/dotnet
export PATH=$PATH:/usr/local/bin/dotnet

# ENV date
DATE=$(date +%Y%m%d)

# Convert
/usr/local/bin/sanchez/Sanchez -t "#0070ba" \
  -s "/xrit-rx/src/received/LRIT/${DATE}/FD/*.jpg" \
  -m "/usr/local/bin/sanchez/Resources/Mask.jpg" \
  -u "/usr/local/bin/sanchez/Resources/GK-2A/Underlay.jpg" \
  -o "/xrit-rx/src/received/LRIT/COLOURED/${DATE}"
