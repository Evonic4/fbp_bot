#!/bin/bash

#perl -pi -e "s/\r\n/\n/" ./*.txt
perl -pi -e "s/\r\n/\n/" ./*.sh
chmod +rx ./*.sh

