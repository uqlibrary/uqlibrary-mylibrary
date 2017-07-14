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
        echo "remote unit testing -  only performed on master and production branch"
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
    echo "saucelabs testing only performed on master and production branch"

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        cd bin/saucelabs

        printf "\n --- TEST CHROME ON WINDOWS (default) --- \n\n"
        ./nightwatch.js

        printf "\n --- TEST EDGE ---\n\n"
        ./nightwatch.js --env edge

        printf "\n --- TEST FIREFOX ON WINDOWS ---\n\n"
        ./nightwatch.js --env firefox-on-windows

        printf "\n --- TEST CHROME ON MAC ---\n\n"
        ./nightwatch.js --env chrome-on-mac

        printf "\n --- TEST FIREFOX ON MAC ---\n\n"
        ./nightwatch.js --env firefox-on-mac

        printf "\n --- TEST SAFARI ON MAC ---\n\n"
        ./nightwatch.js --env safari-on-mac
    fi
  ;;
esac
