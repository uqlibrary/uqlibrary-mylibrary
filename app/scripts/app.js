var browserData = browserSupported();

if (!browserData.supported) {
  if (document.getElementById('preloader-unsupported'))
    document.getElementById('preloader-unsupported').style.display = 'block';
} else {
  if(document.getElementById('preloader-loading')) {
    document.getElementById('preloader-loading').style.display = 'block';
  }
}

(function(document) {
  'use strict';

    // The app
    var app = document.querySelector('#app');

    // Sets app default base URL
    app.baseUrl = '/';
    if (window.location.port === '') {  // if production
      // Uncomment app.baseURL below and
      // set app.baseURL to '/your-pathname/' if running from folder in production
      app.baseUrl = '<DeploymentUrl>';
    }

    // Listen for template bound event to know when bindings
    // have resolved and content has been stamped to the page
    app.addEventListener('dom-change', function() {

    });

    // See https://github.com/Polymer/polymer/issues/1381
    window.addEventListener('WebComponentsReady', function() {
      //only display unsupported big message if web components can't be loaded
      if (document.getElementById('preloader-unsupported'))
        document.getElementById('preloader-unsupported').style.display = 'none';

      if (document.getElementById('preloader-loading'))
        document.getElementById('preloader-loading').style.display = 'none';
    });

    window.addEventListener('uqlibrary-api-account-loaded', function (e) {
      if (e.detail.hasSession) {
        if (document.getElementById('preloader'))
          document.getElementById('preloader').style.display = 'none';

        if(document.getElementById('mylibrary'))
          document.getElementById('mylibrary').style.display = 'block';
        
      } else {
        app.$.accountApi.login(document.location.href);
      }
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
