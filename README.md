# uqlibrary-mylibrary

[![Codeship Status for uqlibrary/uqlibrary-mylibrary](https://codeship.com/projects/7accd470-cee9-0133-67f3-5ed74b30bb55/status?branch=master)](https://codeship.com/projects/141087)
[![Dependency Status](https://david-dm.org/uqlibrary/uqlibrary-mylibrary.svg)](https://david-dm.org/uqlibrary/uqlibrary-mylibrary)
[![Dev Dependency Status](https://david-dm.org/uqlibrary/uqlibrary-mylibrary/dev-status.svg)](https://david-dm.org/uqlibrary/uqlibrary-mylibrary?type=dev)

This project acts as a container for all individual uqlibrary applications.

The current master build can be viewed [here](https://app.library.uq.edu.au/master/mylibrary/).

## Setting up the project

### Prerequisites

You need the following installed

1. NodeJS, with `npm` available in path (Check `package.json` for the required version)
1. Java version 8

   - You can have multiple versions of Java installed on your system, while being able to switch between them using a tool like <https://www.jenv.be/>
   - On Debian-based systems, you can use the following command:

     ```bash
     sudo update-alternatives --config java
     ```
   - On OSX, java can be installed via brew. Note you need version 8. [stack overflow](https://stackoverflow.com/questions/24342886/how-to-install-java-8-on-mac) has instructions for what packages are current

Run these commands in your Terminal to get all the required dev utilities.

```bash
npm install -g bower gulp-cli nightwatch web-component-tester npm@6
```

### Install dependencies

```bash
npm install
```

This will install the local npm dev dependencies as well as bower dependencies used by the app.

## Developing

- Follow the [Polymer style guide-lines](http://polymerelements.github.io/style-guide/)
- Run `npm start` to run a local environment
- Refer to [directions here](https://github.com/uqlibrary/uqlibrary-pages#updating-uql-component-dependencies) for post-dev steps to make sure that changes from child components make it to this repo.

- IMPORTANT! Before each change, update our saucelab operating system versions for [nightwatch](https://github.com/uqlibrary/uqlibrary-mylibrary/blob/master/bin/saucelabs/nightwatch.json) and [wct](https://github.com/uqlibrary/uqlibrary-mylibrary/blob/master/wct.conf.*.js) by using the [saucelabs configurator](https://wiki.saucelabs.com/display/DOCS/Platform+Configurator#/) so we are testing against recent versions (browser versions are mostly automatic). Also check the [latest ESR version for firefox](https://www.mozilla.org/en-US/firefox/organizations/) (Browser versions are mostly automatic). (ESR versions are deployed in our Standard Environment across the Libraries).

## Default setup for pages (index.html, etc)

- Follow requirements from [uqlibrary-pages](https://github.com/uqlibrary/uqlibrary-pages/blob/master/README.md#default-setup-for-pages-indexhtml-etc)

## Developing a new app

1. Clone [uqlibrary-starter-kit](https://github.com/uqlibrary/uqlibrary-starter-kit)
1. Make sure the element contains the paper-toolbar
1. Make sure the element has a "standAlone" attribute and a "\_toggleDrawerPanel" function
1. When the App is ready, [publish the release on GitHub](https://help.github.com/en/articles/creating-releases). The releases are named in the format `v<major>.<minor>.<patch>`, for example: `v1.0.0`.
1. In uqlibrary-mylibrary, `bower install` the element (eg. `bower install uqlibrary/uqlibrary-starter-kit`)
   - The bower dependencies are built into `app/bower_components`, next to the projects' root folder.
1. Add the element in `app/elements/elements.html`
1. Add a section containing the element in `app/index.html`
1. Add a menu item in uqlibrary-api (applications HTML)
1. Add a route via PageJS in `app/elements/routing.html`

## Tests

1. Update bower to include your changes:

   ```bash
   bower update
   ```

   This is automatically run after `npm install`.

1. To get the complete test package, run the test setup script:

   ```bash
   ./bin/test-setup.sh
   ```

   This will produce a long set of dated 'starting' and 'finishing' lines. This is automatically run before `npm test`.

### Run Tests Locally

```bash
npm run test:local
```

You should see over 50 tests run and 1 or 2 minutes of run time - a fast response time means no tests were run

### Run Tests Remotely

```bash
cp wct.conf.js.default wct.conf.js
npm run test:remote
```

Note: It seems that remote runs the file with the first file alphabetically that satisfies the pattern wct.conf*js. Make sure it is wct.conf.js

When you run this command, you may get the error:

"Missing Sauce credentials. Did you forget to set SAUCE_USERNAME and/or SAUCE_ACCESS_KEY?"

To set these fields:

1. Visit the [Mylibrary Codeship Environment Variable page](https://codeship.com/projects/141087/configure_environment)
2. Note the values for SAUCE_USERNAME and for SAUCE_ACCESS_KEY
3. export these as local variables on your box, eg:

   `$ export SAUCE_ACCESS_KEY='XXX'`

then run the `npm run test:remote` command again

### Nightwatch tests

Nightwatch is also run on Codeship for deployment testing. No gulp interface provided.

You can also run them locally:

- Run Selenium server. Selenium is required to run tests locally [Selenium Installer](http://selenium-release.storage.googleapis.com/index.html)

  ```sh
  java -jar selenium-server-standalone-{VERSION}.jar
  ```

  or `brew install selenium-server-standalone` then `selenium-server -port 4444`

- start server (will start server and project will be accessible at <http://localhost:5001>)

  ```sh
  gulp serve:dist
  ```

- start testing

  ```sh
  cd bin/local
  ./nightwatch.js
  ```

You will need to use more than one tab as gulp serve continues running.

You can also restrict to one browser:

```bash
./nightwatch.js --env chrome
```

## Running with live data locally

- Add dev-app.library.uq.edu.au to your /etc/hosts or equivalent file
- Comment out the cookies which control mock data in demo.html (or create a new file)
- Run the gulp task

  ```bash
  gulp demo
  ```

- If you still have the mock cookies in your browser, delete them via your browser.
- Use the Masquerading function at <https://www.library.uq.edu.au/mylibrary/> to masquerade as another user to view library as this user
- Return to your demo page and you should be getting live data.

## Publishing

- Make sure MyLibrary functions properly when using `gulp serve:dist`
- Before committing to master, run `gulp test`
- Any commits to master are automatically deployed to [app.library](https://app.library.uq.edu.au/master/mylibrary/index.html)
- To deploy a feature branch create a deployment pipe line in codeship, feature branch will be deployed to: `https://app.library.uq.edu.au/[feature branch]/mylibrary/index.html`
- Any commits to production will go live on the main UQ Library website (<http://www.library.uq.edu.au/mylibrary>)

## Canary Tests

- The canarytest branch is used in a weekly job started from AWS as [repo-periodic-test-mylibrary](https://ap-southeast-2.console.aws.amazon.com/ecs/home?region=ap-southeast-2#/clusters/default/scheduledTasks) in Scheduled Tasks that checks that our sites work in future browsers. See `bin/codeship-test.sh`
- Scheduled Tasks: in Amazon, go to ECS > Clusters > Default > Scheduled Tasks tab which may be [here](https://ap-southeast-2.console.aws.amazon.com/ecs/home?region=ap-southeast-2#/clusters/default/scheduledTasks) and note task `repo-periodic-test-mylibrary`.
- This can be run manually from the Tasks tab - (put in repo-periodic-test-mylibrary as the Name and I think you have to click open Advanced Options so you can add the same extra parameter as the scheduled task?)

## Codeship config (at 11/Jan/2019)

Setup Commands:

```bash
jdk_switcher use oraclejdk8
chmod a+x -R bin/*
bin/codeship-setup.sh
bin/test-setup.sh
```

3 Test Pipelines:

Unit tests:

```bash
export PIPE_NUM=1
bin/codeship-testing.sh
```

Test Commands:

```bash
export PIPE_NUM=3
bin/codeship-testing.sh
```

Nightwatch:

```bash
export PIPE_NUM=2
bin/codeship-testing.sh
```
