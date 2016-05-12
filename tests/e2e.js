module.exports = {
  'load uqlibrary-mylibrary app': function (client) {
    client
      .url('http://localhost:5001/demo.html')
      .pause(5000)
      .waitForElementVisible('body', 1000)
      .assert.elementPresent('uqlibrary-menu', 'uqlibrary-menu component is present')
      .assert.visible('#home')
      .assert.containsText('uqlibrary-menu paper-menu a.iron-selected', 'My Library')
      .end();
  }
};
