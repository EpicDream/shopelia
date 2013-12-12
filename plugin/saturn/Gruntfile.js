module.exports = function(grunt) {
  var pkg = require('./package.json'),
      manifest = require('./manifest.json'),
      satconf = grunt.file.readYAML('./config.yml');

  grunt.initConfig({
    pkg: pkg,
    // Check syntax and other stuff
    coffee_jshint: {
      options: {
        loopfunc: true,
        browser: true,
        devel: true,
        globals: ['window', 'document', 'console', 'module', 'define', 'require', 'chrome', '__utils__'],
      },
      source: {
        src: ['../common/lib/*.js.coffee', 'src/**.coffee'],
      },
    },
    // Check syntax and other stuff
    jshint: {
      files: [
        'Gruntfile.js',
        'src/**/*.js',
        'lib/*.js',
        'test/*.js',
        '../common/lib/*.js',
        '../common/test/**',
      ],
      options: {
        loopfunc: true,
        multistr: true,
        browser: true,
        devel: true,
        globals: { // options here to override JSHint defaults
          jQuery: true,
          module: true,
        }
      }
    },
    // Copy all needed libs to "vendor/" repository
    copy: {
      main: {
        expand: true,
        cwd: '../common/',
        src: ['./lib/*.js', './vendor/*.js'],
        flatten: true,
        dest: 'vendor/',
      }
    },
    // Compile *.coffee files to *.js files
    coffee: {
      src: {
        expand: true,
        flatten: false,
        src: ['src/**/*.coffee'],
        dest: 'build/',
        ext: '.js',
      },
      compile: {
        files: {
          'vendor/chrome_logger.js': '../common/lib/chrome_logger.js.coffee',
          'vendor/casper_logger.js': '../common/lib/casper_logger.js.coffee',
        }
      },
    },
    // Launch all tests
    jasmine: {
      main: {
        // src: ['src/*.js'],
        options: {
          '--web-security' : false,
          '--local-to-remote-url-access' : true,
          '--ignore-ssl-errors' : true,
          specs: ['test/*.js', '../common/test/lib/*.js'],
          // specs: ['test/saturn_test.js', 'test/saturn_session_test.js', '../common/test/lib/*.js'], //'test/*.js', 
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
      crawler: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'crawler',
          include: ['satconf', 'src/helper'],
          out: 'build/crawler.js',
        }
      },
      chrome_saturn: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/chrome/saturn',
          out: 'build/chrome_saturn.js',
        }
      },
      // node_saturn: {
      //   options: {
      //     baseUrl: '',
      //     mainConfigFile: "require_config.js",
      //     optimize: "none",
      //     name: 'src/saturn',
      //     out: 'build/saturn.js',
      //   }
      // },
      // casper_saturn: {
      //   options: {
      //     baseUrl: '',
      //     mainConfigFile: "require_config.js",
      //     optimize: "none",
      //     name: 'src/casper/casper_saturn',
      //     out: 'build/casper_saturn.js',
      //   }
      // },
      // casper_crawler: {
      //   options: {
      //     baseUrl: '',
      //     mainConfigFile: "require_config.js",
      //     optimize: "none",
      //     name: 'src/casper/crawler',
      //     out: 'build/casper_crawler.js',
      //   }
      // },
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
          'build/chrome_saturn.js',
          'build/src/chrome/adblock.js',
          'build/src/chrome/main.js'
        ],
        dest: 'dist/background.js'
      },
      contentscript: {
        src: [
          'vendor/require.js',
          'require_config.js',
          'vendor/chrome_logger.js',
          "build/crawler.js",
          "build/src/chrome/crawler.js",
        ],
        dest: 'dist/contentscript.js'
      },
      // node_main: {
      //   src: [
      //     "build/saturn.js",
      //     'src/casper/node_saturn.js',
      //   ],
      //   dest: 'dist/node_main.js'
      // },
      // casper_main: {
      //   src: [
      //     'vendor/require.js',
      //     'require_config.js',
      //     'build/casper_saturn.js',
      //     "src/casper/main.js",
      //   ],
      //   dest: 'dist/casper.js'
      // },
      // casper_injected: {
      //   src: [
      //     'vendor/require.js',
      //     'require_config.js',
      //     "build/casper_crawler.js",
      //   ],
      //   dest: 'build/casper_injected.js'
      // },
    },
    // Uglify them in prod.
    uglify: {
      chrome_back: {
        files: {
          'dist/background.min.js': ['<%= concat.background.dest %>']
        }
      },
      chrome_crawler: {
        files: {
          'dist/contentscript.min.js': ['<%= concat.contentscript.dest %>']
        }
      }
    },
    clean: {
      dev: ['vendor', 'src/casper/*.js'],
      prod: ['build', 'vendor'],
      all: ['build', 'vendor', 'dist', 'node_modules']
    },
    exec: {
      "package": {
        cwd: "../",
        cmd: "google-chrome --pack-extension=saturn --pack-extension-key=priv_keys/saturn.pem && mv -f saturn.crx extensions/",
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
    grunt.file.write("manifest.json", JSON.stringify(manifest, null, 2));
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
        manifest.background.scripts[0] = 'dist/background.min.js';
        manifest.content_scripts[0].js[0] = 'dist/contentscript.min.js';
        break;
      default :
        manifest.background.scripts[0] = 'dist/background.js';
        manifest.content_scripts[0].js[0] = 'dist/contentscript.js';
    }
    grunt.file.write("manifest.json", JSON.stringify(manifest, null, 2));
  });

  // Alias
  grunt.registerTask('default', ['dev-prod']);
  grunt.registerTask('cof', ['coffee_jshint', 'default']);
  grunt.registerTask('test', ['version', 'jshint', 'config:test', 'copy', 'coffee', 'jasmine:main']); 
  grunt.registerTask('dev', ['test', 'config:dev', 'requirejs', 'concat', 'manifest:dev']);
  grunt.registerTask('dev-prod', ['test', 'config:dev-prod', 'requirejs', 'concat', 'manifest:dev', 'clean:dev']);
  grunt.registerTask('prod-dev', ['test', 'config:prod-dev', 'requirejs', 'concat', 'manifest:dev', 'clean:dev']);
  grunt.registerTask('staging', ['test', 'config:staging', 'requirejs', 'concat', 'manifest', 'clean:prod']);
  grunt.registerTask('prod', ['test', 'config:prod', 'requirejs', 'concat', 'manifest', 'clean:prod']);
  grunt.registerTask('test-mappings', ['test', 'jasmine:mappings']);

  grunt.registerTask('casper', ['version', 'copy', 'coffee', 'config:dev-prod', 'requirejs', 'concat', 'manifest:dev', 'clean:dev']);
};
