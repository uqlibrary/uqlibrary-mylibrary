#!/bin/bash

set -e

# if you want to log any saucelab errors to the codeship log, set LOG_SAUCELAB_ERRORS to true in the codeship variables
# at https://app.codeship.com/projects/131650/environment/edit;
# else leave it missing in codeship environment variables or false
if [[ -z $LOG_SAUCELAB_ERRORS ]]; then
    LOG_SAUCELAB_ERRORS=false
fi
if [[ "$LOG_SAUCELAB_ERRORS" == true ]]; then
    if [ -z ${TMPDIR} ]; then # codeship doesnt seem to set this
      TMPDIR="/tmp/"
    fi
    SAUCELABS_LOG_FILE="${TMPDIR}sc.log"
    echo "On failure, will look for Saucelabs error log here: ${SAUCELABS_LOG_FILE}"
fi

function logSauceCommands {
  if [[ "$LOG_SAUCELAB_ERRORS" != true ]]; then
    echo "An error happened and (presumably) saucelabs failed but we arent reporting the output - set LOG_SAUCELAB_ERRORS to true in Codeship Environment Variables to see the log next time"
    return
  fi

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
    CI_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

if [[ -z $PIPE_NUM ]]; then
    PIPE_NUM=1
fi

case "$PIPE_NUM" in
  "1")
    # 'Unit tests' pipeline
    # WCT

#    if [ ${CI_BRANCH} == "canarytest" ]; then
    if [ ${CI_BRANCH} == "canary-163684472" ]; then
        printf "sleep to give other pipelines time to run without clashing\n"
        sleep 600 # seconds
        printf "Time of awaken : $(date +"%T")\n\n"
    fi

    # we dont run general tests that aren't relevent for canary test
#    if [ ${CI_BRANCH} != "canarytest" ]; then
    if [ ${CI_BRANCH} != "canary-163684472" ]; then
        echo "Running local tests"
        cp wct.conf.js.local wct.conf.js
        gulp test
        rm wct.conf.js
    fi

    if [ ${CI_BRANCH} == "production" ]; then
        trap logSauceCommands EXIT

        # because we cant run local test at all, we must run saucelabs test on every push :(
        printf "\n-- Remote unit testing on Saucelabs --\n\n"
        cp wct.conf.js.fullA wct.conf.js
        gulp test:remote
        rm wct.conf.js

        sleep 10 # seconds

        # split testing into 2 runs so it doesnt occupy so many saucelab resources in one hit
        cp wct.conf.js.fullB wct.conf.js
        gulp test:remote
        rm wct.conf.js
    fi

#    if [ ${CI_BRANCH} == "canarytest" ]; then
    if [ ${CI_BRANCH} == "canary-163684472" ]; then
        trap logSauceCommands EXIT

        echo "Running unit tests against canary versions of the browsers for early diagnosis of polymer failure"
        echo "(If you get a fail, consider if it's Codeship playing up, then check saucelabs then try it manually in that browser.)"

        printf "\n-- Run WCT tests on saucelabs --\n\n"
        cp wct.conf.js.canary wct.conf.js
        gulp test:remote
        rm wct.conf.js
    fi
  ;;
  "2")
    # 'Integration tests' pipeline
    # Nightwatch

    echo "Start server in the background, wait 20 sec for it to load..."
    nohup gulp serve:dist &
    sleep 20 # give the server time to come up
    cat nohup.out

#    if [ ${CI_BRANCH} != "canarytest" ]; then
    if [ ${CI_BRANCH} != "canary-163684472" ]; then
        echo "Installing Selenium..."
        curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s

        echo "Installed Selenium. Running Nightwatch locally."

        printf "\n Not testing firefox here atm - selenium would need an upgrade to use a recent enough geckodriver"
        printf " that recent firefox will work - see https://app.codeship.com/projects/141087/builds/35995050 \n\n"

        cd bin/local

        printf "\n --- TEST CHROME ON WINDOWS --- \n\n"
        ./nightwatch.js --env chrome

        cd ../../
    fi

#    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production" || ${CI_BRANCH} == "canarytest") ]]; then
    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production" || ${CI_BRANCH} == "canary-163684472") ]]; then
        cd bin/saucelabs
        trap logSauceCommands EXIT
    fi

#    if [ ${CI_BRANCH} == "canarytest" ]; then
    if [ ${CI_BRANCH} == "canary-163684472" ]; then
        echo "Running integration tests against canary versions of the browsers for early diagnosis of polymer failure"
        echo "(If you get a fail, consider if its codeship playing up, then check saucelabs then try it manually in that browser)"

        printf "\n --- TEST Beta and Dev versions of Firefox and Chrome on Mac and Windows  ---\n\n"
        ./nightwatch.js --env chrome-on-windows-beta,chrome-on-windows-dev,firefox-on-windows-beta,firefox-on-windows-dev,chrome-on-mac-beta,chrome-on-mac-dev
    fi

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        # Win/FF is our second most used browser, 2018 - we have the ESR release on Library Desktop SOE
        echo "Saucelabs testing only performed on master and production branch"
        printf "\n --- TEST Chrome and Firefox ESR (popular browsers) ---\n\n"
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
