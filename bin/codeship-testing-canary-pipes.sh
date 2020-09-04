#!/bin/bash

# this is run from codeship-testing.sh - it cannot be run on its own as the variables are missing

# "canarytest" is used by a job that runs weekly to test the polymer repos on the upcoming browser versions
# The intent is to get early notice of polymer 1 failing in modern browsers
# the ordering of the canary browser tests is: test beta, then test dev (beta is closer to ready for prod, per http://www.chromium.org/getting-involved/dev-channel
# win chrome, win firefox and osx chrome are tested -  other options either dont have canaries or usage is too low to justify

case "$PIPE_NUM" in
  "1")
    # 'Unit tests' pipeline
    # WCT

    printf "\nCurrent time : $(date +"%T")\n"
    printf "sleep 5 minutes to give first pipeline time to run without clashing\n"
    sleep 300 # seconds
    printf "Time of awaken : $(date +"%T")\n\n"

    trap logSauceCommands EXIT

    echo "Running unit tests against canary versions of the browsers for early diagnosis of polymer failure"
    echo "(If you get a fail, consider if it's Codeship playing up, then check saucelabs then try it manually in that browser.)"

    printf "\n-- Run WCT tests on saucelabs --\n\n"
    cp wct.conf.js.canary wct.conf.js
    gulp test:remote

    rm wct.conf.js

  ;;
  "2")
    # 'Integration tests' pipeline
    # Nightwatch

    printf "\nStart server in the background, wait 20 sec for it to load...\n"
    nohup gulp serve:dist &
    sleep 20 # give the server time to come up
    cat nohup.out

    cd bin/saucelabs
    trap logSauceCommands EXIT

    echo "Running integration tests against canary versions of the browsers for early diagnosis of polymer failure"
    echo "(If you get a fail, consider if its codeship playing up, then check saucelabs then try it manually in that browser)"

    echo " --- Nightwatch  ---"
    ./nightwatch.js --env chrome-on-windows-beta,firefox-on-windows-beta,firefox-on-windows-dev,chrome-on-mac-beta
  ;;
esac
