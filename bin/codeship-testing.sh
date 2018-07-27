#!/bin/bash

set -e

if [ -z $CI_BRANCH ]; then
  branch=$(git rev-parse --abbrev-ref HEAD)
else
  branch=$CI_BRANCH
fi

case "$PIPE_NUM" in
  "1")
    # 'unit tests' pipeline

    # because codeship can be a little flakey, we arent wasting part of our canary test on general tests that arent relevent
    if [ ${CI_BRANCH} != "canarytest" ]; then
        printf "\n local unit testing is not run as it never returns, eg https://app.codeship.com/projects/141087/builds/31294140?pipeline=92371843-3cbf-469a-87f7-a8120fba009a \n\n"
    #    gulp test

        # because we cant run local test at all, we must run saucelabs test on every push :(
        printf "\n remote unit testing on saucelabs \n\n"
        gulp test:remote
    fi
  ;;
  "2")
    # 'Nightwatch' pipeline
    # local integration testing

    if [ ${CI_BRANCH} != "canarytest" ]; then
        echo "install selenium"
        curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s
        cd bin/local

        echo "Installed selenium. Running Nightwatch locally"

        printf "\n --- TEST FIREFOX ON WINDOWS (default) ---\n\n"
        ./nightwatch.js

        printf "\n --- TEST CHROME ON WINDOWS --- \n\n"
        ./nightwatch.js --env chrome
    fi
  ;;
  "3")
    # 'Test commands' pipeline
    # integration testing at saucelabs

    cd bin/saucelabs

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        echo "saucelabs testing only performed on master and production branch"
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

    if [ ${CI_BRANCH} == "canarytest" ]; then
        printf "Running standard tests against canary versions of the browsers for early diagnosis of polymer failure\n"
        printf "If you get a fail, try it manually in that browser\n\n"

        printf "\n --- TEST CHROME Dev on WINDOWS (canary test) ---\n\n"
        ./nightwatch.js --env chrome-on-windows-dev

        printf "\n --- TEST FIREFOX Dev on WINDOWS (canary test) ---\n\n"
        ./nightwatch.js --env firefox-on-windows-dev

        printf "\n --- TEST CHROME Dev on MAC (canary test) ---\n\n"
        ./nightwatch.js --env chrome-on-mac-dev

        printf "\n --- TEST CHROME Beta on WINDOWS (canary test) ---\n\n"
        ./nightwatch.js --env chrome-on-windows-beta

        printf "\n --- TEST FIREFOX Beta on WINDOWS (canary test) ---\n\n"
        ./nightwatch.js --env firefox-on-windows-beta

        printf "\n --- TEST CHROME Beta on MAC (canary test) ---\n\n"
        ./nightwatch.js --env chrome-on-mac-beta
    fi
  ;;
esac
