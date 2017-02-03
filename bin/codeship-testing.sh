#!/bin/bash

if [ -z $CI_BRANCH ]; then
  branch=$(git rev-parse --abbrev-ref HEAD)
else
  branch=$CI_BRANCH
fi

case "$branch" in
"master")
  case "$PIPE_NUM" in
  "1")
    echo "local unit testing"
    gulp test
  ;;
  "2")
    echo "local integration testing"
    echo "install selenium"
    curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s
    cd bin/local
    echo "Installed selenium. Running Nightwatch"
    ./nightwatch.js
    ./nightwatch.js --env chrome
  ;;
  "3")
    echo "saucelabs testing not performed on master branch"
  ;;
  esac
  ;;
*)
  case "$PIPE_NUM" in
  "1")
    echo "local unit testing"
    gulp test
    echo "remote unit testing"
    gulp test:remote
  ;;
  "2")
    echo "local integration testing"
    echo "install selenium"
    curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/selenium_server.sh | bash -s
    cd bin/local

    echo "test firefox (default)"
    ./nightwatch.js

    echo "test chrome"
    ./nightwatch.js --env chrome
  ;;
  "3")
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

  ;;
  esac
  ;;
esac
