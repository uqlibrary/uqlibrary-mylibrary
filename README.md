# uqlibrary-mylibrary 
[ ![Codeship Status for uqlibrary/uqlibrary-mylibrary](https://codeship.com/projects/7accd470-cee9-0133-67f3-5ed74b30bb55/status?branch=master)](https://codeship.com/projects/141087)

This project acts as a container for all individual uqlibrary applications. 

> [Demo](http://app.library.uq.edu.au/master/mylibrary/demo.html)

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
* gulp test:local
* gulp test:remote
* Nightwatch is also run on Codeship for deployment testing. No gulp interface provided

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
* Any commits to master are automatically deployed to [app.library](http://app.library.uq.edu.au/master/mylibrary/index.html)
* To deploy a feature branch create a deployment pipe line in codeship, feature branch will be deployed to app.library/[feature branch]/mylibrary
* Any commits to production will go live on the main UQ Library website (http://www.library.uq.edu.au/mylibrary)



