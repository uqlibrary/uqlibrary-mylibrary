/**
 * By Jan-Willem Wisgerhof <j.wisgerhof@uq.edu.au>
 */
(function () {
  Polymer({
    is: 'uqlibrary-app-buttons',
    properties: {
      /**
       * Holds the applications used by the menu
       */
      applications: {
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

      // Load the Applications
      this.$.apiApplications.addEventListener('uqlibrary-api-applications-loaded', function(e) {
        self.applications = e.detail;
      });

      this.$.apiAccount.get();
      this.$.apiApplications.get();
    },
    /**
     * Called when an app button has been clicked
     * @param e
     * @private
     */
    _appClicked: function (e) {
      this.fire("uqlibrary-app-button-clicked", e.detail);
    },
    /**
     * Called when applications have changed. Sets external / internal link
     * @private
     */
    _applicationsChanged: function () {
      var apps = [];

      for (var i = 0; i < this.applications.length; i++) {
        var item = this.applications[i];

        if (item.isDivider) {
          item.isLink = false;
        } else {
          item.isLink = true;

          if (item.link.indexOf("http") == 0) {
            item.isExternal = true;
          } else {
            item.isExternal = false;
            item.route = item.link.substring(1);
            item.href = item.route;

            if (item.route != "home") {
              apps.push(item);
            }
          }
        }
      }

      if (apps.length != this.applications.length) {
        this.applications = apps;
      }

      this.fire('uqlibrary-app-buttons-loaded', this.applications);
    }
  })
})();
