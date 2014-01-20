#! /bin/bash

# This script may be called after a git pull.
# It will install and update node package
# and compile Saturn.

echo "Install new NodeJS package..."
npm install
echo "Update NodeJS packages..."
npm update
echo "Compile project with Grunt..."
grunt casper
