#!/bin/bash

# start debugging/tracing commands, -e - exit if command returns error (non-zero status)
set -e

# Check Java version
version=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
echo "Java version is $version"
if [[ "$version" != "8" ]]; then
  echo "Java 8 is required"
  exit 1
fi

# This gets rid of an error
npm rebuild node-sass

# Update paths in bower_components
echo 'gulp clean_bower'
gulp clean_bower

# cleanup in case of multiple runs
rm -rf ./app/bower_components/uqlibrary-computers/node_modules/
rm -rf ./app/bower_components/uqlibrary-hours/node_modules/
rm -rf ./app/bower_components/uqlibrary-papercut/node_modules/
rm -rf ./app/bower_components/uqlibrary-research/node_modules/

# replace node_modules location
mkdir -p ./app/bower_components/uqlibrary-computers/node_modules/lodash/
cp ./node_modules/lodash/lodash.min.js ./app/bower_components/uqlibrary-computers/node_modules/lodash/lodash.min.js

mkdir -p ./app/bower_components/uqlibrary-hours/node_modules/lodash/
cp ./node_modules/lodash/lodash.min.js  ./app/bower_components/uqlibrary-hours/node_modules/lodash/lodash.min.js
mkdir -p ./app/bower_components/uqlibrary-hours/node_modules/moment/
cp ./node_modules/moment/moment.js  ./app/bower_components/uqlibrary-hours/node_modules/moment/moment.js

mkdir -p ./app/bower_components/uqlibrary-papercut/node_modules/moment/
cp ./node_modules/moment/moment.js  ./app/bower_components/uqlibrary-papercut/node_modules/moment/moment.js

mkdir -p ./app/bower_components/uqlibrary-research/node_modules/moment/
cp ./node_modules/moment/moment.js  ./app/bower_components/uqlibrary-research/node_modules/moment/moment.js


cp -R app/bower_components app/test
components=$(ls -d app/test/bower_components/uqlibrary-*/test/*test* | grep -v index)
COUNTER=0
list=""

# Collect all components for testing
echo 'Collect all components for testing'
for component in ${components[@]}; do
  list="$list '$component',"
done

dir="app/test/"

cp "app/test/template.index.html" "app/test/index.html"

sed -i -e "s#\[\]#[ ${list} ]#g" "app/test/index.html"
sed -i -e "s#${dir}##g" "app/test/index.html"

#echo "Check file syntax"
##gulp syntax

# Allow running locally to just do the steps above so the tests
# can be run.  If not local do full build below
if [[ $1 != "local" ]]
then
    echo "Build distribution"
    gulp

    #replace Saucelabs keys in nightwatch.js
    nightwatchScriptTemp="bin/saucelabs/template.nightwatch.js"
    nightwatchScript="bin/saucelabs/nightwatch.js"

    cp $nightwatchScriptTemp $nightwatchScript

    sed -i -e "s#<SAUCE_USERNAME>#${SAUCE_USERNAME}#g" ${nightwatchScript}
    sed -i -e "s#<SAUCE_ACCESS_KEY>#${SAUCE_ACCESS_KEY}#g" ${nightwatchScript}
fi
