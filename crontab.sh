#!/bin/bash
export DOTNET_ROOT=/usr/local/bin/dotnet
export PATH=$PATH:/usr/local/bin/dotnet
/usr/local/bin/sanchez/Sanchez -s "/xrit-rx/src/received/LRIT/**/FD/*.jpg" -m /usr/local/bin/sanchez/Resources/Mask.jpg -u /usr/local/bin/sanchez/Resources/GK-2A/Underlay.jpg -o /xrit-rx/src/received/LRIT/COLOURED -t "#0070ba"
