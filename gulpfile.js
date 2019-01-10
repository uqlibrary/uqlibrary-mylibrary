/*
 Copyright (c) 2015 The Polymer Project Authors. All rights reserved.
 This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
 The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
 The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
 Code distributed by Google as part of the polymer project is also
 subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
 */

'use strict';

// Include promise polyfill for node 0.10 compatibility
// require('es6-promise').polyfill();

// Include Gulp & tools we'll use
var gulp = require('gulp');
var $ = require('gulp-load-plugins')();
var del = require('del');
var browserSync = require('browser-sync');
var reload = browserSync.reload;
var merge = require('merge-stream');
var path = require('path');
var fs = require('fs');
var glob = require('glob-all');
var historyApiFallback = require('connect-history-api-fallback');
var packageJson = JSON.parse(fs.readFileSync('./package.json', 'utf-8'));
var crypto = require('crypto');
var replace = require('gulp-replace-task');
var cloudfront = require('gulp-invalidate-cloudfront');
var argv = require('yargs/yargs')(process.argv.slice(2));

// Other tasks
var ensureFiles = require('./tasks/ensure-files.js');
var preDeployTasks = require('./tasks/pre-deployment-tasks.js');

// var ghPages = require('gulp-gh-pages');

var AUTOPREFIXER_BROWSERS = [
  'ie >= 10',
  'ie_mob >= 10',
  'ff >= 30',
  'chrome >= 34',
  'safari >= 7',
  'opera >= 23',
  'ios >= 7',
  'android >= 4.4',
  'bb >= 10'
];

var DIST = 'dist';

var dist = function (subpath) {
  return !subpath ? DIST : path.join(DIST, subpath);
};

var styleTask = function (stylesPath, srcs) {
  return gulp.src(srcs.map(function (src) {
      return path.join('app', stylesPath, src);
    }))
    .pipe($.changed(stylesPath, {extension: '.scss'}))
    .pipe($.sass({style: 'expanded'}))
    .pipe($.autoprefixer(AUTOPREFIXER_BROWSERS))
    .pipe(gulp.dest('.tmp/' + stylesPath))
    .pipe($.minifyCss())
    .pipe(gulp.dest(dist(stylesPath)))
    .pipe($.size({title: stylesPath}));
};

var imageOptimizeTask = function (src, dest) {
  return gulp.src(src)
    .pipe($.imagemin({
      progressive: true,
      interlaced: true
    }))
    .pipe(gulp.dest(dest))
    .pipe($.size({title: 'images'}));
};

var optimizeHtmlTask = function (src, dest) {
  return gulp.src(src)
    // Concatenate and minify JavaScript
    .pipe($.if('*.js', $.uglify({
      preserveComments: 'some'
    })))
    // Concatenate and minify styles
    // In case you are still using useref build blocks
    .pipe($.if('*.css', $.minifyCss()))
    .pipe($.useref({
      searchPath: ['.tmp', 'app']
    }))
    // Minify any HTML
    .pipe($.if('*.html', $.minifyHtml({
      quotes: true,
      empty: true,
      spare: true
    })))
    // Output files
    .pipe(gulp.dest(dest))
    .pipe($.size({
      title: 'html'
    }));
};

// Compile and automatically prefix stylesheets
gulp.task('styles', function () {
  return styleTask('styles', ['**/*.scss']);
});

// Ensure that we are not missing required files for the project
// "dot" files are specifically tricky due to them being hidden on
// some systems.
gulp.task('ensureFiles', function (cb) {
  var requiredFiles = ['.bowerrc'];

  ensureFiles(requiredFiles.map(function (p) {
    return path.join(__dirname, p);
  }), cb);
});

// Optimize images
gulp.task('images', function () {
  return imageOptimizeTask('app/images/**/*', dist('images'));
});

// Copy all files at the root level (app)
gulp.task('copy', function () {
  var app = gulp.src([
    'app/*',
    '!app/test',
    '!app/elements',
    '!app/bower_components',
    '!app/cache-config.json',
    '!**/.DS_Store'
  ], {
    dot: true
  }).pipe(gulp.dest(dist()));

  // Copy over only the bower_components we need
  // These are things which cannot be vulcanized
  var bower = gulp.src([
    'app/bower_components/{webcomponentsjs,platinum-sw,sw-toolbox,promise-polyfill}/**/*'
  ]).pipe(gulp.dest(dist('bower_components')));

  var mocks = gulp.src([
    'app/bower_components/uqlibrary-api/mock/**/*'
  ]).pipe(gulp.dest(dist('bower_components/uqlibrary-api/mock')));

  var data = gulp.src([
    'app/bower_components/uqlibrary-api/data/*'
  ]).pipe(gulp.dest(dist('bower_components/uqlibrary-api/data')));

  var browserSupported = gulp.src([
    'app/bower_components/uqlibrary-browser-supported/*'
  ]).pipe(gulp.dest(dist('bower_components/uqlibrary-browser-supported')));

  // Force the app - gulp sometimes bugs out and "forgets" it
  var mainApp = gulp.src([
    'app/scripts/*'
  ]).pipe(gulp.dest(dist('scripts')));

  return merge(app, bower, mocks, data, mainApp, browserSupported)
    .pipe($.size({
      title: 'copy'
    }));
});

// inject browser-update.js code into html pages
gulp.task('inject-browser-update', function () {

  var regEx = new RegExp("//bower_components/uqlibrary-browser-supported/browser-update.js", "g");
  var browserUpdate = fs.readFileSync("app/bower_components/uqlibrary-browser-supported/browser-update.js", "utf8");

  return gulp.src(dist('*'))
    .pipe(replace({patterns: [{match: regEx, replacement: browserUpdate}], usePrefix: false}))
    .pipe(gulp.dest(dist()))
    .pipe($.size({title: 'inject-browser-update'}));
});

// inject preloader.html code into html pages
gulp.task('inject-preloader', function () {

  var regEx = new RegExp("#preloader#", "g");
  var browserUpdate = fs.readFileSync("app/bower_components/uqlibrary-browser-supported/preloader.html", "utf8");

  return gulp.src(dist('*'))
    .pipe(replace({patterns: [{match: regEx, replacement: browserUpdate}], usePrefix: false}))
    .pipe(gulp.dest(dist()))
    .pipe($.size({title: 'inject-preloader'}));
});

// Copy web fonts to dist
gulp.task('fonts', function () {
  return gulp.src(['app/fonts/**'])
    .pipe(gulp.dest(dist('fonts')))
    .pipe($.size({
      title: 'fonts'
    }));
});

// Scan your HTML for assets & optimize them
gulp.task('html', function () {
  return optimizeHtmlTask(
    ['app/**/*.html', '!app/{elements,test,bower_components}/**/*.html'],
    dist());
});

// update paths to bower_components for all components inside bower_components
gulp.task('clean_bower', function () {

  var regEx = new RegExp('bower_components', 'g');

  return gulp.src('app/bower_components/**/*.html')
    .pipe(replace({patterns: [{match: regEx, replacement: ".."}], usePrefix: false}))
    .pipe(gulp.dest('app/bower_components'))
    .pipe($.size({title: 'clean_bower'}));
});

// Vulcanize granular configuration
gulp.task('vulcanize', gulp.series('clean_bower', function () {
  return gulp.src('app/elements/elements.html')
    .pipe($.vulcanize({
      stripComments: true,
      inlineCss: true,
      inlineScripts: true
    }))
    .pipe($.crisper({
      scriptInHead: false,
      onlySplit: false
    }))
    .pipe(gulp.dest(dist('elements')))
    .pipe($.size({title: 'vulcanize'}));
}));

// Generate config data for the <sw-precache-cache> element.
// This include a list of files that should be precached, as well as a (hopefully unique) cache
// id that ensure that multiple PSK projects don't share the same Cache Storage.
// This task does not run by default, but if you are interested in using service worker caching
// in your project, please enable it within the 'default' task.
// See https://github.com/PolymerElements/polymer-starter-kit#enable-service-worker-support
// for more context.
gulp.task('cache-config', function (callback) {
  var dir = dist();
  var config = {
    cacheId: packageJson.name || path.basename(__dirname),
    disabled: false
  };

  glob([
      'index.html',
      './',
      'bower_components/webcomponentsjs/webcomponents-lite.min.js',
      '{elements,scripts,styles}/**/*.*'],
    {cwd: dir}, function (error, files) {
      if (error) {
        callback(error);
      }
      else {
        config.precache = files;

        var md5 = crypto.createHash('md5');
        md5.update(JSON.stringify(config.precache));
        config.precacheFingerprint = md5.digest('hex');

        var configPath = path.join(dir, 'cache-config.json');
        fs.writeFile(configPath, JSON.stringify(config), callback);
      }
    });
});

// Clean output directory
gulp.task('clean', function () {
  return del(['.tmp', dist()]);
});

gulp.task('elements', function () {
  return styleTask('elements', ['**/*.css']);
});

// Watch files for changes & reload
gulp.task('demo', function (done) {
  console.log("Running demonstration server...");
  browserSync({
    open: "external",
    startPath: "/demo.html",
    host: "dev-app.library.uq.edu.au",
    port: 9999,
    server: {
      baseDir: ["app"],
    },
    files: [
      "styles/*.css",
      "elements/**/*.html",
      "elements/**/*.js",
      "scripts/*.js"
    ]
  });
  done();
});


// Watch files for changes & reload
gulp.task('serve', gulp.series('elements', 'styles', 'clean_bower', function (done) {
  browserSync({
    port: 5000,
    notify: false,
    startPath: "/demo.html",
    logPrefix: 'MyLibrary',
    snippetOptions: {
      rule: {
        match: '<span id="browser-sync-binding"></span>',
        fn: function (snippet) {
          return snippet;
        }
      }
    },
    // Run as an https by uncommenting 'https: true'
    // Note: this uses an unsigned certificate which on first access
    //       will present a certificate warning in the browser.
    // https: true,
    server: {
      baseDir: ['.tmp', 'app'],
      middleware: [historyApiFallback()]
    }
  });

  gulp.watch(['app/**/*.html', '!app/bower_components/**/*.html'], gulp.series(reload));
  gulp.watch(['app/styles/**/*.scss'], gulp.series('styles', reload));
  gulp.watch(['app/scripts/**/*.js'], gulp.series(reload));
  gulp.watch(['app/images/**/*'], gulp.series(reload));
  done();
}));

// Build production files, the default task
gulp.task('default', gulp.series(
  // Uncomment 'cache-config' if you are going to use service workers.  
  'clean',
  gulp.parallel('ensureFiles', 'copy', 'styles'),
  gulp.parallel('images', 'fonts', 'html'),
  'vulcanize',
  // 'cache-config',
  'inject-preloader',
  'inject-browser-update',
  'inject-ga-values',
  'rev',
  'monkey-patch-rev-manifest',
  'rev-replace-polymer-fix',
  'app-cache-version-update',
  'rev-appcache-update',
  'remove-rev-file',
  function (cb) {
    cb();
  }
));

// Build and serve the output from the dist build
gulp.task('serve:dist', gulp.series('default', function (done) {
  browserSync({
    port: 5001,
    notify: false,
    logPrefix: 'MyLibrary',
    snippetOptions: {
      rule: {
        match: '<span id="browser-sync-binding"></span>',
        fn: function (snippet) {
          return snippet;
        }
      }
    },
    // Run as an https by uncommenting 'https: true'
    // Note: this uses an unsigned certificate which on first access
    //       will present a certificate warning in the browser.
    // https: true,
    server: dist(),
    middleware: [historyApiFallback()]
  });
  done();
}));

// Build then deploy to GitHub pages gh-pages branch
gulp.task('build-deploy-gh-pages', function (cb) {
  gulp.series(
    'default',
    'deploy-gh-pages',
    cb
  );
});

// Deploy to GitHub pages gh-pages branch
gulp.task('deploy-gh-pages', function () {
  return gulp.src(dist('**/*'))
    .pipe($.ghPages());
});

// Load tasks for web-component-tester
// Adds tasks for `gulp test:local` and `gulp test:remote`
require('web-component-tester').gulp.init(gulp);

/**
 * Command line param:
 *    --path {INVALIDATION_PATH}
 *
 * If no bucket path passed will invalidate production subdir
 */
gulp.task('invalidate', function () {
  var awsConfig = JSON.parse(fs.readFileSync('./aws.json', 'utf-8'));

  var invalidatePath = '';

  if (argv.path) {
    invalidatePath = argv.path + '/*';
  }
  else {
    invalidatePath += '/pages/*';
  }

  $.util.log('Invalidation path: ' + invalidatePath);

  var invalidationBatch = {
    CallerReference: new Date().toString(),
    Paths: {
      Quantity: 1,
      Items: [
        invalidatePath
      ]
    }
  };

  var awsSettings = {
    credentials: {
      accessKeyId: awsConfig.accessKeyId,
      secretAccessKey: awsConfig.secretAccessKey
    },
    distributionId: awsConfig.params.distribution,
    region: awsConfig.params.region
  };

  return gulp.src(['**/*'])
    .pipe(cloudfront(invalidationBatch, awsSettings));
});

// upload package to S3
gulp.task('publish', function () {

  // create a new publisher using S3 options
  var awsConfig = JSON.parse(fs.readFileSync('./aws.json', 'utf-8'));
  var publisher = $.awspublish.create(awsConfig);

  // define custom headers
  var headers = {
    'Cache-Control': 'max-age=315360000, no-transform, public'
  };

  return gulp.src(dist('**/*'))
    .pipe($.rename(function (path) {
      path.dirname = awsConfig.params.bucketSubDir + '/' + path.dirname;
    }))
    // gzip, Set Content-Encoding headers
    .pipe($.awspublish.gzip())

    // publisher will add Content-Length, Content-Type and headers specified above
    // If not specified it will set x-amz-acl to public-read by default
    .pipe(publisher.publish(headers))

    // create a cache file to speed up consecutive uploads
    .pipe(publisher.cache())

    // print upload updates to console
    .pipe($.awspublish.reporter());
});

// Load custom tasks from the `tasks` directory
 require('require-dir')('tasks');
