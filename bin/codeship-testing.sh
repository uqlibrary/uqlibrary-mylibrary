#!/bin/bash

set -e

if [ -z ${TMPDIR} ]; then # codeship doesnt seem to set this
  TMPDIR="/tmp/"
fi
SAUCELABS_LOG_FILE="${TMPDIR}sc.log"
echo "On failure, will look for Saucelabs error log here: ${SAUCELABS_LOG_FILE}"

function logSauceCommands {
  if [ ! -f "$SAUCELABS_LOG_FILE" ]; then
    echo "$SAUCELABS_LOG_FILE not found - looking for alt file"
    # testing with check /tmp/sc.log presencewct? it writes to a subdirectory, eg /tmp/wct118915-6262-1w0uwzy.q8it/sc.log
    ALTERNATE_SAUCE_LOCN="$(find ${TMPDIR} -name 'wct*')"
    if [ -d "${ALTERNATE_SAUCE_LOCN}" ]; then
      SAUCELABS_LOG_FILE="${ALTERNATE_SAUCE_LOCN}/sc.log"
    else # debug
      echo "Could not find alternate log file ${ALTERNATE_SAUCE_LOCN}"
    fi
  fi
  if [ -f "$SAUCELABS_LOG_FILE" ]; then
    echo "Command failed - dumping $SAUCELABS_LOG_FILE for debug of saucelabs"
    cat $SAUCELABS_LOG_FILE
  else
    echo "Command failed - attempting to dump saucelabs log file but $SAUCELABS_LOG_FILE not found - did we reach the saucelabs section?"
  fi
}

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
        echo "Running local tests"
        cp wct.conf.js.local wct.conf.js
        gulp test
        rm wct.conf.js
    fi

    if [ ${CI_BRANCH} == "production" ]; then
        trap logSauceCommands EXIT

        # because we cant run local test at all, we must run saucelabs test on every push :(
        printf "remote unit testing on saucelabs \n\n"
        cp wct.conf.js.fullA wct.conf.js
        gulp test:remote
        rm wct.conf.js

        sleep 10 # seconds

        # split testing into 2 runs so it doesnt occupy so many saucelab resources in one hit
        cp wct.conf.js.fullB wct.conf.js
        gulp test:remote
        rm wct.conf.js
    fi

    if [ ${CI_BRANCH} == "canarytest" ]; then
        trap logSauceCommands EXIT

        printf "Running standard tests against canary versions of the browsers for early diagnosis of polymer failure\n"
        printf "(If you get a fail, consider if its codeship playing up, then check saucelabs then try it manually in that browser)\n"

        printf "\n-- Run WCT tests on saucelabs -- \n"
        cp wct.conf.js.canary wct.conf.js
        gulp test:remote
        rm wct.conf.js

        printf "\n-- WCT tests on saucelabs complete --"
    fi
  ;;
  "2")
    # 'Nightwatch' pipeline
    # Integration testing

    echo "start server in the background, wait 20 sec for it to load"
    nohup gulp serve:dist &
    sleep 20 # give the server time to come up
    cat nohup.out

    if [ ${CI_BRANCH} != "canarytest" ]; then
        echo "install selenium"
        curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s

        echo "Installed selenium. Running Nightwatch locally"

        printf "\n Not testing firefox here atm - selenium would need an upgrade to use a recent enough geckodriver that recent firefox will work - see https://app.codeship.com/projects/141087/builds/35995050 \n\n"

        cd bin/local

        printf "\n --- TEST CHROME ON WINDOWS --- \n\n"
        ./nightwatch.js --env chrome
    fi

    if [ ${CI_BRANCH} == "canarytest" ]; then
        trap logSauceCommands EXIT

        printf "Running standard tests against canary versions of the browsers for early diagnosis of polymer failure\n"
        printf "(If you get a fail, consider if its codeship playing up, then check saucelabs then try it manually in that browser)\n"

        cd bin/saucelabs

        printf "\n --- TEST Beta and Dev versions of Firefox and Chrome on Mac and Windows  ---\n\n"
        ./nightwatch.js --env chrome-on-windows-beta,chrome-on-windows-dev,firefox-on-windows-beta,firefox-on-windows-dev,chrome-on-mac-beta,chrome-on-mac-dev
    fi
  ;;
  "3")
    # 'Test commands' pipeline
    # integration testing at saucelabs

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        trap logSauceCommands EXIT

        echo "Start server in the background, wait 20 sec for it to load"
        nohup gulp serve:dist &
        sleep 20 # give the server time to come up
        cat nohup.out

        cd bin/saucelabs

        # Win/FF is our second most used browser, 2018 - we have the ESR release on Library Desktop SOE
        echo "Saucelabs testing only performed on master and production branch"
        printf "\n --- TEST Popular browsers ---\n\n"
        ./nightwatch.js --env default,firefox-on-windows-esr

    fi

    if [[ (${CI_BRANCH} == "production") ]]; then
        printf "\n --- TEST All other browsers ---\n\n"
        echo "Note: Edge test disabled."
        # ./nightwatch.js --env edge-browser,ie11-browser,firefox-on-windows,chrome-on-mac,firefox-on-mac,safari-on-mac,firefox-on-mac-esr
        ./nightwatch.js --env ie11-browser,firefox-on-windows,chrome-on-mac,firefox-on-mac,safari-on-mac,firefox-on-mac-esr
    fi

  ;;
esac
