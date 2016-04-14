# uqlibrary-mylibrary 
[ ![Codeship Status for uqlibrary/uqlibrary-mylibrary](https://codeship.com/projects/7accd470-cee9-0133-67f3-5ed74b30bb55/status?branch=master)](https://codeship.com/projects/141087)

This project acts as a container for all individual uqlibrary applications. 

> [Demo](http://assets.library.uq.edu.au/master/mylibrary/index.html)

## Setting up the project
* npm install -g gulp bower
* npm install
* bower install

## Developing
* Follow the [Polymer style guide-lines](http://polymerelements.github.io/style-guide/)
* Run ```gulp serve``` to run a local environment

## Developing a new app
1. Clone [uqlibrary-starter-kit](https://github.com/uqlibrary/uqlibrary-starter-kit)
1. Make sure the element contains the paper-toolbar
1. Make sure the element has a "standAlone" attribute and a "_toggleDrawerPanel" function
1. When the App is ready, tag a release, eg git tag -a v1.0.0 -m 'First release'
1. In uqlibrary-mylibrary, bower install the element (ie. bower install uqlibrary/uqlibrary-starter-kit#v1.0.0)
1. Add the element in app/elements/elements.html
1. Add a section containing the element in app/index.html
1. Add a menu item in uqlibrary-api (applications HTML)
1. Add a route via PageJS in app/elements/routing.html

## Tests
* gulp test:local
* gulp test:remote
* Nightwatch is also run on Codeship for deployment testing. No gulp interface provided

## Publishing
* Make sure MyLibrary functions properly when using ```gulp serve:dist```
* Before committing to master, run ```gulp test```
* Any commits to master are automatically deployed to [assets](http://assets.library.uq.edu.au/master/mylibrary/index.html)
* Any commits to production will go live on the main UQ Library website



