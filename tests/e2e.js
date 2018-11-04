module.exports = {
  'load uqlibrary-mylibrary app': function (client) {
    client
      .url('http://localhost:5001/demo.html')
      .pause(10000)
      .waitForElementVisible('body', 20000)
      .waitForElementVisible('#home', 20000)
      .assert.containsText('uqlibrary-menu paper-menu a.iron-selected', 'My Library')
      .assert.elementPresent('uqlibrary-menu', 'uqlibrary-menu component is present')

      .assert.elementPresent('.applications', 'button block is present')
      // .assert.elementPresent('.applications > paper-button:nth-of-type(14)', 'all buttons present')
      // .assert.elementNotPresent('.applications > paper-button:nth-of-type(15)', 'no extra buttons found')

      .end();
  }
};
