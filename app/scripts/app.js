(function(document) {
  'use strict';

  var app = document.querySelector('#app');

  // Sets app default base URL
  app.baseUrl = '/';
  if (window.location.port === '') {  // if production
    // Uncomment app.baseURL below and
    // set app.baseURL to '/your-pathname/' if running from folder in production
    // app.baseUrl = '/polymer-starter-kit/';
  }

  app.displayInstalledToast = function() {
    // Check to make sure caching is actually enabled—it won't be in the dev environment.
    if (!Polymer.dom(document).querySelector('platinum-sw-cache').disabled) {
      Polymer.dom(document).querySelector('#caching-complete').show();
    }
  };

  // Listen for template bound event to know when bindings
  // have resolved and content has been stamped to the page
  app.addEventListener('dom-change', function() {

  });

  // See https://github.com/Polymer/polymer/issues/1381
  window.addEventListener('WebComponentsReady', function() {
    document.querySelector('#preloader').style.display = 'none';
    document.querySelector('#paperDrawerPanel').style.display = 'block';
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

})(document);
