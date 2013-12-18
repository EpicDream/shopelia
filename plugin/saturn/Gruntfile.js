module.exports = function(grunt) {
  var pkg = require('./package.json'),
      manifest = require('./manifest.json'),
      satconf = grunt.file.readYAML('./config.yml');

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
      }
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
        dest: 'vendor/',
      },
      chrome: {
        files: [
          {src: ['img/*'], dest: 'extension/', expand: true, flatten: true},
          {src: ['src/alert_inhibiter.js'], dest: 'extension/', expand: true, flatten: true}
        ]
      }
    },
    // Compile *.coffee files to *.js files
    coffee: {
      libs: {
        files: {
          'vendor/chrome_logger.js': '../common/lib/chrome_logger.js.coffee',
          'vendor/casper_logger.js': '../common/lib/casper_logger.js.coffee',
          'vendor/node_logger.js': '../common/lib/node_logger.js.coffee',
        }
      },
      chrome: {
        expand: true,
        flatten: false,
        options: {
          bare: true
        },
        src: ['src/chrome/*.coffee'],
        dest: 'build/',
        ext: '.js',
      },
      casper: {
        expand: true,
        flatten: false,
        options: {
          bare: true
        },
        src: ['src/node/*.coffee', 'src/casper/*.coffee'],
        dest: 'build/',
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
            requireConfigFile: 'require_config.js'
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
            requireConfigFile: 'require_config.js'
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
            requireConfigFile: 'require_config.js'
          },
        }
      }
    },
    // Concat modules' files in a way that requirejs always work.
    requirejs: {
      chrome_crawler: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/chrome/crawler',
          out: 'build/chrome_crawler.js',
        }
      },
      chrome_main: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/chrome/main',
          out: 'build/chrome_main.js',
        }
      },
      casper_saturn: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/casper/saturn',
          out: 'build/casper_saturn.js',
        }
      },
      casper_crawler: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/casper/crawler',
          out: 'build/casper_crawler.js',
        }
      },
    },
    // Add requirejs and "main files" that require others modules.
    concat: {
      options: {
        separator: '\n\n'
      },
      background: {
        src: [
          'vendor/require.js',
          'require_config.js',
          'build/chrome_main.js',
        ],
        dest: 'extension/background.js'
      },
      contentscript: {
        src: [
          'vendor/require.js',
          'require_config.js',
          "build/chrome_crawler.js",
        ],
        dest: 'extension/contentscript.js'
      },
      casper_main: {
        src: [
          'vendor/require.js',
          'require_config.js',
          'build/casper_saturn.js',
          "build/src/casper/main.js",
        ],
        dest: 'dist/casper.js'
      },
      casper_injected: {
        src: [
          'vendor/require.js',
          'require_config.js',
          "build/casper_crawler.js",
        ],
        dest: 'build/casper_injected.js'
      },
    },
    // Uglify them in prod.
    uglify: {
      chrome_back: {
        files: {
          'extension/background.min.js': ['<%= concat.background.dest %>']
        }
      },
      chrome_crawler: {
        files: {
          'extension/contentscript.min.js': ['<%= concat.contentscript.dest %>']
        }
      }
    },
    clean: {
      vendor: ['vendor'],
      build: ['build'],
      chrome: ['vendor', 'build', 'extension', 'vendor/jquery.js'],
      node: ['vendor/jquery.js'],
      all: ['build', 'vendor', 'dist', 'node_modules']
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
  grunt.registerTask('version', function() {
    console.log(pkg.version, " -> ", satconf.version);
    // Update package.json
    pkg.version = satconf.version;
    grunt.file.write("package.json", JSON.stringify(pkg, null, 2));
    // Update manifest.json
    manifest.version = satconf.version;
    grunt.file.write("extension/manifest.json", JSON.stringify(manifest, null, 2));
  });

  grunt.registerTask('config', function(profile) {
    var conf = {}, key;
    // Set default conf
    for (key in satconf.default)
      conf[key] = satconf.default[key];
    // Overwrite with profile conf
    for (key in satconf[profile])
      conf[key] = satconf[profile][key];
    grunt.file.write("build/config.js", 'var satconf = ' + JSON.stringify(conf, null, 2) + ';\n');
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
    grunt.file.write("extension/manifest.json", JSON.stringify(manifest, null, 2));
  });

  // Alias
  grunt.registerTask('default', []);

  // Chrome
  grunt.registerTask('chrome-lint', ['jshint:main', 'jshint:libs', 'coffee_jshint:chrome']);
  grunt.registerTask('chrome-compile', ['coffee:libs', 'coffee:chrome']);
  grunt.registerTask('chrome-jasmine', ['jasmine:main', 'jasmine:libs']);
  grunt.registerTask('chrome-test', ['chrome-lint', 'chrome-compile', 'version', 'config:test', 'copy:libs', 'chrome-jasmine', 'copy:chrome']);
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
  grunt.registerTask('casper-test', ['casper-lint', 'casper-compile', 'version', 'config:test', 'copy:libs', 'casper-jasmine']);
  grunt.registerTask('casper-requirejs', ['requirejs:casper_saturn', 'requirejs:casper_crawler']);
  grunt.registerTask('casper-concat', ['concat:casper_main', 'concat:casper_injected']);

  grunt.registerTask('casper', ['casper-test', 'config:dev-prod', 'casper-requirejs', 'casper-concat', 'clean:node']);
};
