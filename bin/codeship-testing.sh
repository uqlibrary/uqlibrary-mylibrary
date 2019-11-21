#!/bin/bash

set -e

# if you want to log any saucelab errors to the codeship log, set LOG_SAUCELAB_ERRORS to true in the codeship variables
# at https://app.codeship.com/projects/131650/environment/edit;
# else leave it missing in codeship environment variables or false
if [[ -z $LOG_SAUCELAB_ERRORS ]]; then
    LOG_SAUCELAB_ERRORS=false
fi
if [[ "$LOG_SAUCELAB_ERRORS" == true ]]; then
    if [[ -z ${TMPDIR} ]]; then # codeship doesnt seem to set this
      TMPDIR="/tmp/"
    fi
    SAUCELABS_LOG_FILE="${TMPDIR}sc.log"
    echo "On failure, will look for Saucelabs error log here: ${SAUCELABS_LOG_FILE}"
fi

function logSauceCommands {
  if [[ "$LOG_SAUCELAB_ERRORS" != true ]]; then
    echo "An error happened and (presumably) saucelabs failed but we arent reporting the output - set LOG_SAUCELAB_ERRORS to true in Codeship Environment Variables to see the log next time (it is details very specific to the internals of saucelabs - really only needed if saucelabs are asking to see it to diagnose a problem)"
    return
  fi

  if [[ ! -f "$SAUCELABS_LOG_FILE" ]]; then # testing with wct? it writes to a subdirectory, eg /tmp/wct118915-6262-1w0uwzy.q8it/sc.log
    echo "$SAUCELABS_LOG_FILE not found - looking for alt file"
    ALTERNATE_SAUCE_LOCN="$(find ${TMPDIR} -name 'wct*')"
    if [[ -d "${ALTERNATE_SAUCE_LOCN}" ]]; then
      SAUCELABS_LOG_FILE="${ALTERNATE_SAUCE_LOCN}/sc.log"
    else # debug
      echo "Could not find alternate log file ${ALTERNATE_SAUCE_LOCN}"
    fi
  fi
  if [[ -f "$SAUCELABS_LOG_FILE" ]]; then
    echo "Command failed - dumping $SAUCELABS_LOG_FILE for debug of saucelabs"
    cat $SAUCELABS_LOG_FILE
  else
    echo "Command failed - attempting to dump saucelabs log file but $SAUCELABS_LOG_FILE not found - did we reach the saucelabs section?"
  fi
}

if [[ -z $CI_BRANCH ]]; then
    CI_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

if [[ -z $PIPE_NUM ]]; then
    PIPE_NUM=1
fi

# "canarytest" is used by a job that runs weekly to test the polymer repos on the upcoming browser versions
# The intent is to get early notice of polymer 1 failing in modern browsers
if [[ ${CI_BRANCH} == "canarytest" ]]; then
  source ./bin/codeship-testing-canary.sh
  exit 0
fi

case "$PIPE_NUM" in
  "1")
    # 'Unit tests' pipeline
    # WCT

    printf "\n-- Running unit tests on chrome --\n\n"
    # test chrome on every build
    cp wct.conf.js.local wct.conf.js
    gulp test
    rm wct.conf.js

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        echo "we use saucelabs as a way to test browsers that codeship doesnt offer"

        # test most common browsers on master and prod
        # (also splits tests into two runs so it doesnt slam saucelabs quite so hard)
        trap logSauceCommands EXIT

        printf "\n-- Remote unit testing on Saucelabs for most popular browsers (master and production) --\n\n"
        # check analytics at least annually to confirm correct browser choice
        # Win/Chrome is our most used browser, 2018
        # Win/FF is our second most used browser, 2018 - we have the ESR release on Library Desktop SOE
        # IE11 should be tested on master for earlier detection of problematic js
        cp wct.conf.js.masterprod wct.conf.js
        gulp test:remote
        rm wct.conf.js
    fi

    if [[ ${CI_BRANCH} == "production" ]]; then
        sleep 10 # seconds

        printf "\n-- Remote unit testing on Saucelabs for remaining browsers (production) --\n\n"
        cp wct.conf.js.prod wct.conf.js
        gulp test:remote
        rm wct.conf.js
    fi
  ;;
  "2")
    # 'Integration tests' pipeline
    # Nightwatch

    printf "\n --- Start server in the background, wait 20 sec for it to load...\n\n"
    nohup gulp serve:dist &
    sleep 20 # give the server time to come up
    cat nohup.out

    printf "\n --- Installing Selenium...\n\n"
    curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s

    printf "\n --- Installed Selenium. Running Nightwatch locally.\n\n"

    cd bin/local

    printf "\n --- TEST FIREFOX (default) ON WINDOWS --- \n\n"
    echo "we can test this locally on codeship"
    # all branches do a quick test on firefox
    # even though we could do everything in saucelabs, its good to have this - when saucelabs fails its reassuring to have one test that passes...
    ./nightwatch.js

    cd ../../

    if [[ (${CI_BRANCH} == "master" || ${CI_BRANCH} == "production") ]]; then
        cd bin/saucelabs
        # we use saucelabs as a way to test browsers that codeship doesnt offer

        trap logSauceCommands EXIT

        # The FF ESR releases are what we put on Library Desktop SOE
        # IE11 should be tested on each build for earlier detection of problematic js
        echo "Saucelabs testing only performed on master and production branch"
        printf "\n --- Use saucelabs to TEST most popular browsers (change this as analytics changes) ---\n\n"
        ./nightwatch.js --env chrome-on-windows,safari-on-mac,ie11-browser

        # Edge test disabled as the tests ALWAYS failed despite the page working fine. Do try it though!
        # ./nightwatch.js --env edge-browser
    fi

    if [[ (${CI_BRANCH} == "production") ]]; then
        printf "\n --- Use saucelabs to test all other browsers above around 2% usage ---\n\n"
        ./nightwatch.js --env chrome-on-mac,firefox-on-windows-esr,firefox-on-mac,firefox-on-mac-esr

        # ff/win done in codeship
        # ./nightwatch.js --env firefox-on-windows

        # commented out browsers with %age too low
        # ./nightwatch.js --env chrome-on-mac,firefox-on-mac,safari-on-mac,firefox-on-mac-esr
    fi

  ;;
esac
