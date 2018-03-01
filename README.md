# uqlibrary-mylibrary 
[ ![Codeship Status for uqlibrary/uqlibrary-mylibrary](https://codeship.com/projects/7accd470-cee9-0133-67f3-5ed74b30bb55/status?branch=master)](https://codeship.com/projects/141087)
[![Dependency Status](https://david-dm.org/uqlibrary/uqlibrary-mylibrary.svg)](https://david-dm.org/uqlibrary/uqlibrary-mylibrary)
[![Dev Dependency Status](https://david-dm.org/uqlibrary/uqlibrary-mylibrary/dev-status.svg)](https://david-dm.org/uqlibrary/uqlibrary-mylibrary?type=dev)

This project acts as a container for all individual uqlibrary applications. 

> [Demo](https://app.library.uq.edu.au/master/mylibrary/demo.html)

## Setting up the project

Run these commands in your Terminal to get a local server working 

(note the first one must be run as super user)

    sudo npm install -g gulp bower
    npm install
    bower install
  
## Developing
* Follow the [Polymer style guide-lines](http://polymerelements.github.io/style-guide/)
* Run ```gulp serve``` to run a local environment

## Default setup for pages (index.html, etc) 
* Follow requirements from [uqlibrary-pages](https://github.com/uqlibrary/uqlibrary-pages/blob/master/README.md#default-setup-for-pages-indexhtml-etc)

### IMS force login
1. IMS script should be included in the header to force on-campus users to login to be able to access content on S3 and Internet
```
  <!-- force IMS login for on-campus users -->
  <script src="//www.library.uq.edu.au/js/ims.js"></script>
```
  
## Developing a new app
1. Clone [uqlibrary-starter-kit](https://github.com/uqlibrary/uqlibrary-starter-kit)
1. Make sure the element contains the paper-toolbar
1. Make sure the element has a "standAlone" attribute and a "_toggleDrawerPanel" function
1. When the App is ready, tag a release, eg git tag -a v1.0.0 -m 'First release'
1. In uqlibrary-mylibrary, bower install the element (eg. bower install uqlibrary/uqlibrary-starter-kit#v1.0.0) (Note that bower_components subfolders are no longer used and bower components are build into the parent directory, above each project)
1. Add the element in app/elements/elements.html
1. Add a section containing the element in app/index.html
1. Add a menu item in uqlibrary-api (applications HTML)
1. Add a route via PageJS in app/elements/routing.html

## Tests

Obviously, update bower to include your changes:

    $ bower update

To get the complete test package, run the test setup script:

    $ ./bin/test-setup.sh

(This will produce a long set of dated 'starting' and 'finishing'
 lines.)

### Run Tests Locally

    $ gulp test:local

(You should see over 50 tests run and 1 or 2 minutes of run time - a fast response time means no tests were run)

### Run Tests Remotely 

    $ gulp test:remote

When you run this command, you may get the error:

"Missing Sauce credentials. Did you forget to set SAUCE_USERNAME and/or SAUCE_ACCESS_KEY?"

To set these fields: 

1. Visit the [Mylibrary Codeship Environment Variable page](https://codeship.com/projects/141087/configure_environment)
2. Note the values for SAUCE_USERNAME and for SAUCE_ACCESS_KEY
3. export these as local variables on your box, eq:

    `$ export SAUCE_ACCESS_KEY='XXX'`

then run the `gulp test:remote` command again


### Nightwatch tests

Nightwatch is also run on Codeship for deployment testing. No gulp interface provided

You can also run them locally:

* Run Selenium server. Selenium is required to run tests locally [Selenium Installer] (http://selenium-release.storage.googleapis.com/index.html)

```sh
  java -jar selenium-server-standalone-{VERSION}.jar
```

or `brew install selenium-server-standalone` then `selenium-server -port 4444`

* start server (will start server and project will be accessible at http://localhost:5001)

```sh
  gulp serve:dist
```

* start testing

```sh
  cd bin/local
  ./nightwatch.js
```  

(You will need to use more than one tab as gulp serve continues running.)

You can also restrict to one browser:

    $ ./nightwatch.js --env chrome

## Running with live data locally

* Add dev-app.library.uq.edu.au to your /etc/hosts or equivalent file
* Comment out the cookies which control mock data in demo.html (or create a new file)
* Run the gulp task
```
gulp demo
```
* If you still have the mock cookies in your browser, delete them via your browser.
* Use the Masquerading function at https://www.library.uq.edu.au/mylibrary/#!masquerade to masquerade as another user to view library as this user
* Return to your demo page and you should be getting live data.

## Publishing
* Make sure MyLibrary functions properly when using ```gulp serve:dist```
* Before committing to master, run ```gulp test```
* Any commits to master are automatically deployed to [app.library](https://app.library.uq.edu.au/master/mylibrary/index.html)
* To deploy a feature branch create a deployment pipe line in codeship, feature branch will be deployed to: `https://app.library.uq.edu.au/[feature branch]/mylibrary/index.html`
* Any commits to production will go live on the main UQ Library website (http://www.library.uq.edu.au/mylibrary)


## Codeship config (at Jan/2017)
Setup Commands:
```
  jdk_switcher use oraclejdk8
  chmod a+x -R bin/*
  bin/codeship-setup.sh
  npm cache clear
  rm -rf node_modules
  npm install
  bin/test-setup.sh
```
3 Test Pipelines:
  
Unit tests:
```
  export PIPE_NUM=1
  bin/codeship-testing.sh
```

Test Commands:
```
  export PIPE_NUM=3
  echo "start server in the background, wait 20 sec for it to load"
  nohup bash -c "gulp serve:dist 2>&1 &" && sleep 20; cat nohup.out
  bin/codeship-testing.sh
```

Nightwatch:
```
  export PIPE_NUM=2
  echo "start server in the background, wait 20 sec for it to load"
  nohup bash -c "gulp serve:dist 2>&1 &" && sleep 20; cat nohup.out
  bin/codeship-testing.sh
```
