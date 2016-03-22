module.exports = {
  'load uqlibrary-mylibrary app' : function (client) {
    client
        .url('http://localhost:5001')
        .pause(5000)
        .waitForElementVisible('body', 1000)
        .assert.elementPresent('uqlibrary-app-menu', 'uqlibrary-app-menu component is present')
        .end();
  }
};
