module.exports = {
  'load uqlibrary index page' : function (client) {
    client
        .url('http://localhost:5001')
        .pause(5000)
        .waitForElementVisible('body', 1000)
        .assert.elementPresent('uqlibrary-menu', 'uqlibrary-menu component is present')
        .end();
  }
};
