/**
 * By Jan-Willem Wisgerhof <j.wisgerhof@uq.edu.au>
 */
(function () {
  Polymer({
    is: 'uqlibrary-app-menu',
    properties: {
      /**
       * The current route of the app
       */
      route: {
        type: String,
        value: 'home'
      },
      /**
       * The base of all URLs within the UQL app
       */
      baseUrl: {
        type: String,
        value: ''
      },
      /**
       * Holds the applications used by the menu
       */
      _applications: {
        type: Object,
        observer: '_applicationsChanged'
      },
      /**
       * Holds the user's account
       */
      _account: {
        type: Object,
        value: {
          hasSession: false
        }
      }
    },
    ready: function () {
      var self = this;

      // Load the user's account
      this.$.apiAccount.addEventListener('uqlibrary-api-account-loaded', function (e) {
        if (e.detail.hasSession) {
          self._account = e.detail;
          self.$.apiApplications.get();
        }
      });
      this.$.apiAccount.get();

      // Load the Applications
      this.$.apiApplications.addEventListener('uqlibrary-api-applications-loaded', function(e) {
        self._applications = e.detail;
        self.fire('uqlibrary-menu-loaded');
      });
      this.$.apiApplications.get();
    },
    /**
     * Called when applications have changed. Sets external / internal link
     * @private
     */
    _applicationsChanged: function () {
      for (var i = 0; i < this._applications.length; i++) {
        var item = this._applications[i];

        if (item.isDivider) {
          item.isLink = false;
        } else {
          item.isLink = true;

          if (item.link.indexOf("http") == 0) {
            item.isExternal = true;
          } else {
            item.isExternal = false;
            item.route = item.link.substring(1);
            item.href = this.baseUrl + item.route;
          }
        }
      }
    }
  })
})();
