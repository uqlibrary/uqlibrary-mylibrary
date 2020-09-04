#!/bin/bash

# this is run from codeship-testing.sh - it cannot be run on its own as the variables are missing

# "canarytest" is used by a job that runs weekly to test the polymer repos on the upcoming browser versions
# The intent is to get early notice of polymer 1 failing in modern browsers
# the ordering of the canary browser tests is: test beta, then test dev (beta is closer to ready for prod, per http://www.chromium.org/getting-involved/dev-channel
# win chrome, win firefox and osx chrome are tested -  other options either dont have canaries or usage is too low to justify

trap logSauceCommands EXIT

echo "Running integration tests against canary versions of the browsers for early diagnosis of polymer failure"
echo "(If you get a fail, consider if its codeship playing up, then check saucelabs then try it manually in that browser)"


# "Nightwatch integreation testing" 

printf "\nStart server in the background, wait 40 sec for it to load...\n"
nohup gulp serve:dist &
sleep 40 # give the server time to come up
cat nohup.out

printf "Running standard tests against canary versions of the browsers for early diagnosis of polymer failure\n"
printf "If you get a fail, try it manually in that browser\n\n"

printf "\n --- Saucelabs Integration Testing ---\n\n"
cd bin/saucelabs

printf "\n --- TEST CHROME Beta on WINDOWS (canary test) ---\n\n"
# the env names on the call to nightwatch.js must match the entries in saucelabs/nightwatch.json
./nightwatch.js --env chrome-on-windows-beta --tag e2etest

printf "\n --- TEST CHROME Beta on MAC (canary test) ---\n\n"
# the env names on the call to nightwatch.js must match the entries in saucelabs/nightwatch.json
./nightwatch.js --env chrome-on-mac-beta --tag e2etest

printf "\n --- TEST FIREFOX Beta and Dev on WINDOWS (canary test) ---\n\n"
# the env names on the call to nightwatch.js must match the entries in saucelabs/nightwatch.json
./nightwatch.js --env firefox-on-windows-beta,firefox-on-windows-dev --tag e2etest

cd ../../

# "Unit testing"

printf "\n --- WCT CANARY UNIT TESTING ---\n\n"
cp wct.conf.js.canary wct.conf.js
gulp test:remote
rm wct.conf.js
printf "\n --- WCT unit testing complete---\n\n"

