// doc: https://github.com/Polymer/tools/tree/master/packages/web-component-tester
var path = require('path');

var ret = {
    'suites': ['app/test'],
    'webserver': {
        'pathMappings': []
    },
    plugins: {
        sauce: {
            browsers: [
                'OS X 10.14/firefox',
                'OS X 10.14/firefox@68',
                'OS X 10.14/chrome',
                'Windows 10/firefox@68' // ESR - check # at https://www.mozilla.org/en-US/firefox/organizations/
            ]
        }
    }
};

var mapping = {};
var rootPath = (__dirname).split(path.sep).slice(-1)[0];

mapping['/components/' + rootPath  +
'/app/bower_components'] = 'bower_components';

ret.webserver.pathMappings.push(mapping);

module.exports = ret;
