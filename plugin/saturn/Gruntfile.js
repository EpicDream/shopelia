module.exports = function(grunt) {
  var pkg = require('./package.json'),
      manifest = require('./manifest.json'),
      satconf = grunt.file.readYAML('./config.yml');

  if (grunt.option('make-dir')) {
    if (grunt.option('make-dir').search(/\/$/) === -1)
      grunt.option('make-dir', grunt.option('make-dir')+'/');
  } else {
    grunt.option('make-dir', '');
  }
  grunt.option('vendor-dir', grunt.option('make-dir') + 'vendor/');
  grunt.option('build-dir', grunt.option('make-dir') + 'build/');
  grunt.option('extension-dir', grunt.option('make-dir') + 'extension/');
  grunt.option('require_config', grunt.option('build-dir')+'require_config.js');

  // Update require_config file.
  var require_config = grunt.file.read("./require_config.js", {encodinf: 'utf8'});
  require_config = require_config.replace(/\bvendor\//g, grunt.option('vendor-dir'));
  require_config = require_config.replace(/\bbuild\//g, grunt.option('build-dir'));
  grunt.file.write(grunt.option('require_config'), require_config, {encoding: 'utf8'});

  grunt.initConfig({
    pkg: pkg,
    // Check syntax and other stuff
    jshint: {
      main: {
        src: [
          'Gruntfile.js',
          'src/*.js',
          'lib/*.js',
          'test/*.js',
        ],
        options: {
          loopfunc: true,
          multistr: true,
          browser: true,
          devel: true,
        }
      },
      libs: {
        src: [
          '../common/lib/*.js',
          '../common/test/**',
        ],
        options: {
          loopfunc: true,
          multistr: true,
          browser: true,
          devel: true,
        }
      },
      adblock: {
        src: [
          '../common/vendor/adblock/filterNotifier.js',
          '../common/vendor/adblock/filterClasses.js',
          '../common/vendor/adblock/matcher.js',
        ],
        options: {
          loopfunc: true,
          multistr: true,
          browser: true,
          devel: true,
          '-W065': true,
          '-W103': true,
        }
      },
    },
    // Check syntax and other stuff
    coffee_jshint: {
      chrome: {
        options: {
          jshintOptions: ["browser", "devel"],
          globals: ['FileError', 'define', 'requirejs', 'chrome', 'satconf'],
        },
        src: ['src/chrome/*.coffee', '../common/lib/chrome_logger.js.coffee']
      },
      casper: {
        options: {
          jshintOptions: ["node", "browser", "devel"],
          globals: ['define', 'requirejs', '__utils__', 'casper', 'satconf'],
        },
        src: ['src/node/*.coffee', 'src/casper/*.coffee', '../common/lib/casper_logger.js.coffee', '../common/lib/node_logger.js.coffee']
      }
    },
    // Copy all needed libs to "vendor/" repository
    copy: {
      libs: {
        expand: true,
        cwd: '../common/',
        src: ['./lib/*.js', './vendor/*.js'],
        flatten: true,
        dest: grunt.option('vendor-dir'),
      },
      adblock: {
        expand: true,
        cwd: '../common/vendor',
        src: ['./adblock/**'],
        flatten: false,
        dest: grunt.option('vendor-dir'),
      },
      chrome: {
        files: [
          {src: ['img/*'], dest: grunt.option('extension-dir'), expand: true, flatten: true},
          {src: ['src/alert_inhibiter.js'], dest: grunt.option('extension-dir'), expand: true, flatten: true}
        ]
      }
    },
    // Compile *.coffee files to *.js files
    coffee: {
      libs: {
        expand: true,
        flatten: true,
        options: {
          bare: true
        },
        src: ['../common/lib/*.coffee'],
        dest: grunt.option('vendor-dir'),
        ext: '.js',
      },
      chrome: {
        expand: true,
        flatten: false,
        options: {
          bare: true
        },
        src: ['src/chrome/*.coffee'],
        dest: grunt.option('build-dir'),
        ext: '.js',
      },
      casper: {
        expand: true,
        flatten: false,
        options: {
          bare: true
        },
        src: ['src/node/*.coffee', 'src/casper/*.coffee'],
        dest: grunt.option('build-dir'),
        ext: '.js',
      },
    },
    // Launch all tests
    jasmine: {
      main: {
        options: {
          '--web-security' : false,
          '--local-to-remote-url-access' : true,
          '--ignore-ssl-errors' : true,
          specs: ['test/*.js'],
          template: require('grunt-template-jasmine-requirejs'),
          templateOptions: {
            requireConfigFile: grunt.option('require_config'),
          },
        }
      },
      libs: {
        options: {
          '--web-security' : false,
          '--local-to-remote-url-access' : true,
          '--ignore-ssl-errors' : true,
          specs: ['../common/test/lib/*.js'],
          template: require('grunt-template-jasmine-requirejs'),
          templateOptions: {
            requireConfigFile: grunt.option('require_config'),
          },
        }
      },
      mappings: {
        src: ['src/*.js'],
        options: {
          '--web-security' : false,
          '--local-to-remote-url-access' : true,
          '--ignore-ssl-errors' : true,
          specs: ['../common/test/mappings/*.js'],
          template: require('grunt-template-jasmine-requirejs'),
          templateOptions: {
            requireConfigFile: grunt.option('require_config'),
          },
        }
      }
    },
    // Concat modules' files in a way that requirejs always work.
    requirejs: {
      chrome_crawler: {
        options: {
          baseUrl: '',
          mainConfigFile: grunt.option('require_config'),
          paths: {
            'vendor': grunt.option('vendor-dir'),
            'build': grunt.option('build-dir')
          },
          optimize: "none",
          name: 'src/chrome/crawler',
          out: grunt.option('build-dir')+'chrome_crawler.js',
        }
      },
      chrome_main: {
        options: {
          baseUrl: '',
          mainConfigFile: grunt.option('require_config'),
          paths: {
            'vendor': grunt.option('vendor-dir'),
            'build': grunt.option('build-dir')
          },
          optimize: "none",
          name: 'src/chrome/main',
          out: grunt.option('build-dir')+'chrome_main.js',
        }
      },
      casper_saturn: {
        options: {
          baseUrl: '',
          mainConfigFile: grunt.option('require_config'),
          paths: {
            'vendor': grunt.option('vendor-dir'),
            'build': grunt.option('build-dir')
          },
          optimize: "none",
          name: 'src/casper/saturn',
          out: grunt.option('build-dir')+'casper_saturn.js',
        }
      },
      casper_crawler: {
        options: {
          baseUrl: '',
          mainConfigFile: grunt.option('require_config'),
          paths: {
            'vendor': grunt.option('vendor-dir'),
            'build': grunt.option('build-dir')
          },
          optimize: "none",
          name: 'src/casper/crawler',
          out: grunt.option('build-dir')+'casper_crawler.js',
        }
      },
      casper_adblock: {
        options: {
          baseUrl: '',
          mainConfigFile: grunt.option('require_config'),
          paths: {
            'vendor': grunt.option('vendor-dir'),
            'build': grunt.option('build-dir')
          },
          optimize: "none",
          name: 'src/casper/adblock',
          out: grunt.option('build-dir')+'casper_adblock.js',
        }

      }
    },
    // Add requirejs and "main files" that require others modules.
    concat: {
      options: {
        separator: '\n\n'
      },
      background: {
        src: [
          grunt.option('vendor-dir')+'require.js',
          grunt.option('require_config'),
          grunt.option('build-dir')+'chrome_main.js',
        ],
        dest: grunt.option('extension-dir')+'background.js'
      },
      contentscript: {
        src: [
          grunt.option('vendor-dir')+'require.js',
          grunt.option('require_config'),
          grunt.option('build-dir')+'chrome_crawler.js',
        ],
        dest: grunt.option('extension-dir')+'contentscript.js'
      },
      casper_main: {
        src: [
          grunt.option('vendor-dir')+'require.js',
          grunt.option('require_config'),
          grunt.option('build-dir')+'casper_saturn.js',
          grunt.option('build-dir')+'src/casper/main.js',
        ],
        dest: grunt.option('build-dir')+'casper.js'
      },
      casper_injected: {
        src: [
          grunt.option('vendor-dir')+'require.js',
          grunt.option('require_config'),
          grunt.option('build-dir')+'casper_crawler.js',
        ],
        dest: grunt.option('build-dir')+'casper_injected.js'
      },
    },
    // Uglify them in prod.
    uglify: {
      chrome_back: {
        files: {
          "<%= grunt.option('extension-dir')+'background.min.js' %>": ['<%= concat.background.dest %>']
        }
      },
      chrome_crawler: {
        files: {
          "<%= grunt.option('extension-dir')+'contentscript.min.js' %>": ['<%= concat.contentscript.dest %>']
        }
      }
    },
    clean: {
      options: { force: true },
      vendor: [grunt.option('vendor-dir')],
      build: [grunt.option('build-dir')],
      chrome: [grunt.option('vendor-dir'), grunt.option('build-dir'), grunt.option('extension-dir')],
      node: [grunt.option('vendor-dir')+'jquery.js'],
      all: [grunt.option('build-dir'), grunt.option('vendor-dir'), 'node_modules']
    },
    exec: {
      "package": {
        cmd: "google-chrome --pack-extension=saturn --pack-extension-key=priv_keys/saturn.pem",
      }
    },
  });

  // Predefined tasks
  grunt.loadNpmTasks('grunt-coffee-jshint');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-exec');

  // My tasks
  grunt.registerTask('package', function() {
    console.log(pkg.version, " -> ", satconf.version);
    // Update package.json
    pkg.version = satconf.version;
    grunt.file.write("package.json", JSON.stringify(pkg, null, 2));
  });

  grunt.registerTask('config', function(profile) {
    var conf = {}, key;
    // Set default conf
    for (key in satconf.default)
      conf[key] = satconf.default[key];
    // Overwrite with profile conf
    for (key in satconf[profile])
      conf[key] = satconf[profile][key];
    grunt.file.write(grunt.option('build-dir')+"config.js", 'var satconf = ' + JSON.stringify(conf, null, 2) + ';\n');
  });

  grunt.registerTask('manifest', function(arg) {
    switch (arg) {
      case 'min' :
        manifest.background.scripts[0] = 'background.min.js';
        manifest.content_scripts[0].js[0] = 'contentscript.min.js';
        break;
      default :
        manifest.background.scripts[0] = 'background.js';
        manifest.content_scripts[0].js[0] = 'contentscript.js';
    }
    // Update manifest.json
    manifest.version = satconf.version;
    grunt.file.write(grunt.option('extension-dir')+"manifest.json", JSON.stringify(manifest, null, 2));
  });

  // Alias
  grunt.registerTask('default', []);

  // Chrome
  grunt.registerTask('chrome-lint', ['jshint:main', 'jshint:libs', 'coffee_jshint:chrome']);
  grunt.registerTask('chrome-compile', ['coffee:libs', 'coffee:chrome']);
  grunt.registerTask('chrome-jasmine', ['jasmine:main', 'jasmine:libs']);
  grunt.registerTask('chrome-test', ['chrome-lint', 'chrome-compile', 'config:test', 'copy:libs', 'chrome-jasmine', 'copy:chrome']);
  grunt.registerTask('chrome-requirejs', ['requirejs:chrome_crawler', 'requirejs:chrome_main']);
  grunt.registerTask('chrome-concat', ['concat:background', 'concat:contentscript']);

  grunt.registerTask('chrome', ['chrome-dev-prod']);
  grunt.registerTask('chrome-dev', ['chrome-test', 'config:dev', 'chrome-requirejs', 'chrome-concat', 'manifest:dev']);
  grunt.registerTask('chrome-dev-prod', ['chrome-test', 'config:dev-prod', 'chrome-requirejs', 'chrome-concat', 'manifest:dev', 'clean:vendor']);
  grunt.registerTask('chrome-prod-dev', ['chrome-test', 'config:prod-dev', 'chrome-requirejs', 'chrome-concat', 'manifest:dev', 'clean:vendor']);
  grunt.registerTask('chrome-staging', ['chrome-test', 'config:staging', 'chrome-requirejs', 'chrome-concat', 'manifest', 'clean:vendor', 'clean:build']);
  grunt.registerTask('chrome-prod', ['chrome-test', 'config:prod', 'chrome-requirejs', 'chrome-concat', 'manifest', 'clean:vendor', 'clean:build']);

  // Casper
  grunt.registerTask('casper-lint', ['jshint:main', 'jshint:libs', 'coffee_jshint:casper']);
  grunt.registerTask('casper-compile', ['coffee:libs', 'coffee:casper']);
  grunt.registerTask('casper-jasmine', ['jasmine:main', 'jasmine:libs']);
  grunt.registerTask('casper-test', ['casper-lint', 'casper-compile', 'version', 'config:test', 'copy:libs', 'copy:adblock', 'casper-jasmine']);
  grunt.registerTask('casper-requirejs', ['requirejs:casper_saturn', 'requirejs:casper_crawler', 'requirejs:casper_adblock']);
  grunt.registerTask('casper-concat', ['concat:casper_main', 'concat:casper_injected']);

  grunt.registerTask('casper', ['casper-test', 'config:dev-prod', 'casper-requirejs', 'casper-concat', 'clean:node']);
};
