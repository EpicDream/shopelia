module.exports = function(grunt) {
  var pkg = require('./package.json'),
      manifest = require('./manifest.json'),
      config = require('./config.json');

  grunt.initConfig({
    pkg: pkg,
    jslint: {
      all: {
        src: [
          'Gruntfile.js',
          'src/*.js',
          'controllers/mapping_contentscript.js',
          'controllers/toolbar_contentscript.js',
          'test/*.js',
          '../common/mapping.js','../common/viking.js',
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
        '../common/mapping.js','../common/viking.js',
      ],
      options: {
        loopfunc: true
      }
    },
    copy: {
      main: {
        files: [
          {expand: true, cwd: '../common/', src: ['*.js'], dest: 'build/'}
        ]
      }
    },
    // jasmine: {
    //   src: ['controllers/*.js'],
    //   options: {
    //     vendor: ['lib/*.js']
    //   }
    // },
    concat: {
      options: {
        separator: ';'
      },
      background: {
        src: [
          "build/require.js",
          "build/uri.js",
          "build/sprintf.js",
          "build/jquery.min.js",
          "build/logger.js",
          "build/viking.js",
          "src/ariane.js",
          "src/back_chrome_listeners.js"
        ],
        dest: 'build/background.js'
      },
      contentscript: {
        src: [
          "build/require.js",
          "build/underscore.min.js",
          "build/jquery.min.js", 
          "build/jquery-ui.min.js",
          "build/uri.js",
          "build/sprintf.js",
          "build/logger.js",
          "build/viking.js",
          "build/html_utils.js",
          "lib/css_struct.js",
          "lib/path_utils.js",
          "controllers/toolbar_contentscript.js",
          "controllers/mapping_contentscript.js"
        ],
        dest: 'build/contentscript.js'
      }
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
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
      }
    },
  });

  // Update package.json
  pkg.version = config.version;
  grunt.file.write("package.json", JSON.stringify(pkg, null, 2));

  function updateConfigFile(env) {
    config.env = env;
    grunt.file.write("config.json", JSON.stringify(config, null, 2));
  }

  function updateManifest(env) {
    // var manifest = grunt.file.readJSON("manifest.json");
    manifest.version = config.version;
    switch (env) {
      case 'prod' :
        manifest.background.scripts[0] = 'dist/background.min.js';
        manifest.content_scripts[0].js[0] = 'dist/contentscript.min.js';
        break;
      default :
        manifest.background.scripts[0] = 'build/background.js';
        manifest.content_scripts[0].js[0] = 'build/contentscript.js';
    }
    grunt.file.write("manifest.json", JSON.stringify(manifest, null, 2));
  }

  grunt.loadNpmTasks('grunt-jslint');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-copy');
  // grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('configFile', updateConfigFile);
  grunt.registerTask('manifest', updateManifest);
  // grunt.registerTask('test', ['jshint', 'jasmine']);
  grunt.registerTask('default', ['jshint', 'copy', /*'jasmine', */'concat', 'configFile:dev', 'manifest:dev']);
  grunt.registerTask('prod', ['jshint', 'copy', /*'jasmine', */'concat', 'uglify', 'configFile:prod', 'manifest:prod']);
};