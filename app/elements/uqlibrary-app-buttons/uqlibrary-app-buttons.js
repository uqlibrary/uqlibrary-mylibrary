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
       * Holds the service link(s)
       */
      _services: {
        type: Array,
        value: []
      },
      /**
       * Whether the show services
       */
      _showServices: {
        type: Boolean,
        value: false
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
          self._getServices();
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
     * Checks if this user has service links
     * @returns {boolean}
     * @private
     */
    _hasServices: function () {
      return (this._services && this._services.length > 0);
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

          if (item.link.indexOf("http") === 0) {
            item.isExternal = true;
          } else {
            item.isExternal = false;
            item.route = item.link.substring(1);
            item.href = window.location.protocol + '//' + window.location.host + window.location.pathname + '#!' + item.route;
          }

          if (item.route !== "home") {
            apps.push(item);
          }
        }
      }

      if (apps.length !== this.applications.length) {
        this.applications = apps;
      }

      this.fire('uqlibrary-app-buttons-loaded', this.applications);
    },
    /**
     * Returns an app item
     * @private
     */
    _getServices: function () {
      var community = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-community',
        title: 'Services for community'
      };
      var hospitalStaff = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-hospital-staff',
        title: 'Services for hospital staff'
      };
      var researchers = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-researchers',
        title: 'Services for researchers'
      };
      var secondarySchools = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-secondary-schools',
        title: 'Services for secondary schools'
      };
      var student = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-students',
        title: 'Services for students'
      };
      var alumni = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-uq-alumni',
        title: 'Services for UQ alumni'
      };
      var teachingStaff = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-teaching-staff',
        title: 'Services for teaching staff'
      };
      var profStaff = {
        link: 'https://www.library.uq.edu.au/library-services/services-for-professional-staff',
        title: 'Services for professional staff'
      };
      var borrowingExternal = {
        link: 'https://web.library.uq.edu.au/borrowing-requesting/how-borrow/borrowing-external-and-remote-students',
        title: 'Services for external and remote students'
      };

      var serviceItems = [];
      switch(this._account.type) {
        case 1:
        case 11:
        case 21:
          serviceItems = [ student, borrowingExternal ];
          break;
        case 31:
          serviceItems = [ student, borrowingExternal ];
          break;
        case 2:
        case 22:
          serviceItems = [ researchers, student, borrowingExternal ];
          break;
        case 3:
        case 15:
          serviceItems = [ profStaff, researchers, teachingStaff ];
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
          serviceItems = [ community, hospitalStaff, profStaff, researchers, secondarySchools, student, teachingStaff, alumni, borrowingExternal ];
          break;
      }

      this._services = serviceItems;
      this._showServices = (serviceItems.length > 0);
    },
    /**
     * Called when a service is clicked
     * @param e
     * @private
     */
    _serviceClicked: function (e) {
      window.location = e.model.item.link;
    }
  })
})();
