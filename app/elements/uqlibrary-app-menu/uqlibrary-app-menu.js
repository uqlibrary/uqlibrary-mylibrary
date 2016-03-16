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
      }
    },
    ready: function () {
      var self = this;
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
            this._applications[i].isExternal = true;
          } else {
            this._applications[i].isExternal = false;
            this._applications[i].route = this._applications[i].link.substring(1)
          }
        }
      }
    }
  })
})();
