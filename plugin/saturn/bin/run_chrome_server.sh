#!/bin/bash

if [[ `pwd` =~ "saturn/bin" ]]; then
  cd ..
fi

if [ "$1" = "" ]; then
  dir="extension"
else
  dir="$1/extension"
fi

google-chrome --disable-extensions-http-throttling --load-extension=$dir; google-chrome --uninstall-extension=$dir
