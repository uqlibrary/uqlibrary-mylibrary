#!/bin/bash

if [ -z $CI_BRANCH ]; then
  branch=$(git rev-parse --abbrev-ref HEAD)
else
  branch=$CI_BRANCH
fi

case "$PIPE_NUM" in
  "1")
    echo "local unit testing"
    gulp test

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        echo "remote unit testing"
        gulp test:remote
    fi
  ;;
  "2")
    echo "local integration testing"
    echo "install selenium"
    curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s
    cd bin/local

    echo "Installed selenium. Running Nightwatch"
    echo "test firefox (default)"
    ./nightwatch.js

    echo "test chrome"
    ./nightwatch.js --env chrome
  ;;
  "3")
    echo "saucelabs testing only performed on production branch"

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        cd bin/saucelabs

        echo "test chrome on windows (default)"
        ./nightwatch.js

        echo "test edge"
        ./nightwatch.js --env edge

        echo "test firefox on windows"
        ./nightwatch.js --env firefox-on-windows

        echo "test chrome on mac"
        ./nightwatch.js --env chrome-on-mac

        echo "test firefox on mac"
        ./nightwatch.js --env firefox-on-mac

        echo "test safari on mac"
        ./nightwatch.js --env safari-on-mac
    fi
  ;;
esac
