#! /bin/bash

if [[ `pwd` =~ "saturn/bin" ]]; then
  cd ..
fi

nodejs ./build/src/node/main.js
