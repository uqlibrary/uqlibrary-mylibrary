/**
 * By Jan-Willem Wisgerhof <j.wisgerhof@uq.edu.au>
 */
(function () {
  Polymer({
    is: 'uqlibrary-home',
    properties: {
      /**
       * header title - application name
       */
      headerTitle: {
        type: String,
        value: 'My Library'
      }
    },
    ready: function () {

    },
    /**
     * Toggles the drawer panel of the main UQL app
     * @private
     */
    _toggleDrawerPanel: function () {
      this.fire('uqlibrary-toggle-drawer');
    }
  })
})();
