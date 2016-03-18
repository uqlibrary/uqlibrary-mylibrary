(function(document) {
  'use strict';

  var browserData = browserSupported();

  if (browserData.supported) {

    document.querySelector('#preloader-loading').display = 'block';
    document.querySelector('#preloader-unsupported').display = 'none';

    // The app
    var app = document.querySelector('#app');

    // Sets app default base URL
    app.baseUrl = '/';
    if (window.location.port === '') {  // if production
      // Uncomment app.baseURL below and
      // set app.baseURL to '/your-pathname/' if running from folder in production
      // app.baseUrl = '/polymer-starter-kit/';
    }

    // Listen for template bound event to know when bindings
    // have resolved and content has been stamped to the page
    app.addEventListener('dom-change', function() {

    });

    // See https://github.com/Polymer/polymer/issues/1381
    window.addEventListener('WebComponentsReady', function() {
      document.querySelector('#preloader').style.display = 'none';
      document.querySelector('#mylibrary').style.display = 'block';
    });

    /**
     * Listens for the Toggle Drawer event from child components
     */
    window.addEventListener('uqlibrary-toggle-drawer', function () {
      app.$.paperDrawerPanel.togglePanel();
    });

    app.closeDrawer = function() {
      app.$.paperDrawerPanel.closeDrawer();
    };
  } else {
    console.log(browserData);
    document.querySelector('#browser-name').textContent = browserData.browser;
    document.querySelector('#browser-version').textContent = browserData.version;
  }



})(document);
