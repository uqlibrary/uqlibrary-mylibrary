module.exports = {
  'load uqlibrary-mylibrary app': function (client) {
    client
      .url('http://localhost:5001/demo.html')
      .pause(10000)
      .waitForElementVisible('body', 20000)
      .assert.visible('#home')
      .assert.containsText('uqlibrary-menu paper-menu a.iron-selected', 'My Library')
      .assert.elementPresent('uqlibrary-menu', 'uqlibrary-menu component is present')
      .end();
  }
};
