module.exports = function(grunt) {
  var pkg = require('./package.json'),
      manifest = require('./manifest.json'),
      arconf = grunt.file.readYAML('./config.yml');

  grunt.initConfig({
    pkg: pkg,
    jslint: {
      all: {
        src: [
          'Gruntfile.js',
          'src/*.js',
          'lib/*.js',
          'controllers/mapping_contentscript.js',
          'controllers/toolbar_contentscript.js',
          'test/*.js',
          '../common/lib/*.js',
        ],
        options: {}
      }
    },
    jshint: {
      files: [
        'Gruntfile.js',
        'src/*.js',
        'controllers/mapping_contentscript.js',
        'controllers/toolbar_contentscript.js',
        'test/*.js',
        '../common/lib/*.js',
      ],
      options: {
        loopfunc: true
      }
    },
    copy: {
      main: {
        expand: true,
        cwd: '../common/',
        src: ['./lib/*.js', './vendor/*.js'],
        flatten: true,
        dest: 'vendor/',
      }
    },
    // Launch all tests
    jasmine: {
      src: ['lib/*.js'],
      options: {
        specs: ['test/*.js'],
        template: require('grunt-template-jasmine-requirejs'),
        templateOptions: {
          requireConfigFile: 'require_config.js'
        },
      }
    },
    // Concat modules' files in a way that requirejs always work.
    requirejs: {
      ariane: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/ariane',
          out: 'build/ariane.js',
        }
      },
      mapper: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'controllers/mapping_contentscript',
          out: 'build/mapper.js',
        }
      },
      panel: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          include: ['logger', 'jquery', 'jquery-ui', 'jquery-mobile'],
          out: 'build/panel1.js',
        }
      },
    },
    concat: {
      options: {
        separator: '\n\n'
      },
      background: {
        src: [
          'vendor/require.js',
          'require_config.js',
          "build/ariane.js",
          "src/back_chrome_listeners.js"
        ],
        dest: 'build/background.js'
      },
      contentscript: {
        src: [
          'vendor/require.js',
          'require_config.js',
          "build/mapper.js",
        ],
        dest: 'build/contentscript.js'
      },
      panel: {
        src: [
          'vendor/require.js',
          'require_config.js',
          "build/panel1.js",
          "src/panel-iframe.js",
        ],
        dest: 'build/panel2.js'
      },
    },
    uglify: {
      loader: {
        files: {
          'dist/loader.min.js': ['src/loader_cs.js']
        }
      },
      background: {
        files: {
          'dist/background.min.js': ['<%= concat.background.dest %>']
        }
      },
      contentscript: {
        files: {
          'dist/contentscript.min.js': ['<%= concat.contentscript.dest %>']
        }
      },
      panel: {
        files: {
          'dist/panel.min.js': ['<%= concat.panel.dest %>']
        }
      }
    },
    clean: {
      dev: ['vendor'],
      prod: ['build', 'vendor'],
      total: ['build', 'vendor', 'dist', 'node_modules']
    },
    exec: {
      "package": {
        cwd: "../",
        cmd: "google-chrome --pack-extension=ariane --pack-extension-key=priv_keys/ariane.pem && mv -f ariane.crx extensions/",
      }
    },
  });

  // Predefined tasks
  grunt.loadNpmTasks('grunt-jslint');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-exec');

  // My tasks
  grunt.registerTask('version', function() {
    console.log(pkg.version, " -> ", arconf.version);
    // Update package.json
    pkg.version = arconf.version;
    grunt.file.write("package.json", JSON.stringify(pkg, null, 2));
    // Update manifest.json
    manifest.version = arconf.version;
    grunt.file.write("manifest.json", JSON.stringify(manifest, null, 2));
  });

  grunt.registerTask('config', function(profile) {
    var conf = {}, key;
    // Set default conf
    for (key in arconf.default)
      conf[key] = arconf.default[key];
    // Overwrite with profile conf
    for (key in arconf[profile])
      conf[key] = arconf[profile][key];
    grunt.file.write("build/config.js", 'var arconf = ' + JSON.stringify(conf, null, 2) + ';\n');
  });

  grunt.registerTask('manifest', function(arg) {
    switch (arg) {
      case 'min' :
        manifest.background.scripts[0] = 'dist/background.min.js';
        manifest.content_scripts[0].js[0] = 'dist/contentscript.min.js';
        manifest.content_scripts[1].js[0] = 'dist/loader.min.js';
        break;
      default :
        manifest.background.scripts[0] = 'build/background.js';
        manifest.content_scripts[0].js[0] = 'build/contentscript.js';
        manifest.content_scripts[1].js[0] = 'src/loader_cs.js';
    }
    grunt.file.write("manifest.json", JSON.stringify(manifest, null, 2));
  });

  // Alias
  grunt.registerTask('default', ['dev']);
  grunt.registerTask('test', ['version', 'jshint', 'copy', 'jasmine']);
  grunt.registerTask('dev', ['test', 'config:dev', 'requirejs', 'concat', 'manifest:dev', 'clean:dev']);
  grunt.registerTask('prod', ['test', 'config:prod', 'requirejs', 'concat', 'uglify', 'manifest:min', 'clean:prod']);
};