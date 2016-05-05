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

      // Add service apps
      var serviceApps = this._getServiceItems();
      _.forEach(serviceApps, function (value) {
        value.isExternal = true;
        value.isLink = true;

        apps.push(value);
      });

      if (apps.length != this.applications.length) {
        this.applications = apps;
      }

      this.fire('uqlibrary-app-buttons-loaded', this.applications);
    },
    /**
     * Returns an app item
     * @private
     */
    _getServiceItems: function () {
      var student = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-students',
        icon: 'hardware:developer-board',
        title: 'Services for students'
      };
      var researchers = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-researchers',
        icon: 'hardware:developer-board',
        title: 'Services for researchers'
      };
      var alumni = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-uq-alumni',
        icon: 'hardware:developer-board',
        title: 'Services for UQ alumni'
      };
      var secondarySchools = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-secondary-schools',
        icon: 'hardware:developer-board',
        title: 'Services for secondary schools'
      };
      var community = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-community',
        icon: 'hardware:developer-board',
        title: 'Services for community'
      };
      var hospitalStaff = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-hospital-staff',
        icon: 'hardware:developer-board',
        title: 'Services for hospital staff'
      };

      var serviceItems = [];
      switch(this._account.type) {
        case 1:
        case 11:
        case 21:
        case 31:
          serviceItems = [ student ];
          break;
        case 2:
        case 22:
          serviceItems = [ researchers ];
          break;
        case 4:
        case 14:
          serviceItems = [ alumni ];
          break;
        case 7:
          serviceItems = [ secondarySchools ];
          break;
        case 8:
          serviceItems = [ community ];
          break;
        case 9:
          serviceItems = [ hospitalStaff ];
          break;
        case 17:
        case 18:
          serviceItems = [ student, researchers, secondarySchools, community, hospitalStaff, alumni ];
          break;
      }

      return serviceItems;
    }
  })
})();
