#!/bin/bash

# start debugging/tracing commands, -e - exit if command returns error (non-zero status)
set -e

echo "Check Java version is set to Java8"
# can't run jdk_switcher in script
# jdk_switcher use oraclejdk8

version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
echo version "$version"
if [[ "$version" < "1.8" ]]; then
  echo "Java version is too old, min Java8 is required"
  return 1
fi

printf "\n\n $ npm -v"
npm -v

printf "\n\n$ node -v"
node -v

printf "\n\n --- Install dependencies"

printf "\n\n $ npm install -g gulp-cli bower nightwatch web-component-tester\n"
npm install -g gulp-cli bower nightwatch web-component-tester

printf "\n $ npm install\n"
npm install

printf "\n\n $ bower install\n"
bower install
