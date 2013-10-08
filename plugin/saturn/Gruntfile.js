module.exports = function(grunt) {
  var pkg = require('./package.json'),
      manifest = require('./manifest.json');

  grunt.initConfig({
    pkg: pkg,
    jshint: {
      files: ['Gruntfile.js', 'src/**/*.js', 'lib/tree.js', 'test/*.js'],
      options: {
        loopfunc: true,
        globals: { // options here to override JSHint defaults
          jQuery: true,
          console: true,
          module: true,
          document: true
        }
      }
    },
    // Copy all needed libs to "vendor/" repository
    copy: {
      main: {
        files: [
          {expand: true, cwd: '../common/', src: ['*.js'], dest: 'vendor/'}
        ]
      }
    },
    // Launch all tests
    jasmine: {
      src: ['src/*.js'],
      options: {
        vendor: ['lib/*.js'],
        specs: ['test/*.js'],
        template: require('grunt-template-jasmine-requirejs'),
        templateOptions: {
          requireConfigFile: 'require_config.js'
        },
      }
    },
    // Concat modules' files in a way that requirejs always work.
    requirejs: {
      crawler: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/crawler',
          include: ["lib/utils"],
          out: 'build/crawler.js',
        }
      },
      chrome_saturn: {
        options: {
          baseUrl: '',
          mainConfigFile: "require_config.js",
          optimize: "none",
          name: 'src/chrome/chrome_saturn',
          include: ["lib/utils"],
          out: 'build/chrome_saturn.js',
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
          'build/chrome_saturn.js',
          'src/chrome/main.js'
        ],
        dest: 'build/background.js'
      },
      contentscript: {
        src: [
          'vendor/require.js',
          'require_config.js',
          "build/crawler.js",
          "src/chrome/chrome_crawler.js",
        ],
        dest: 'build/contentscript.js'
      }
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
      dev: ['vendor'],
      prod: ['build', 'vendor'],
      total: ['build', 'vendor', 'dist', 'node_modules']
    },
    exec: {
      "package": {
        cwd: "../",
        cmd: "google-chrome --pack-extension=saturn --pack-extension-key=priv_keys/saturn.pem && mv -f saturn.crx extensions/",
      }
    },
  });

  function updateManifest(env) {
    manifest.version = pkg.version;
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

  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-requirejs');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-exec');

  grunt.registerTask('manifest', updateManifest);
  grunt.registerTask('test', ['jshint', 'jasmine']);
  grunt.registerTask('default', ['jshint', 'copy', 'jasmine', 'requirejs', 'concat', 'manifest:dev', 'clean:dev']);
  grunt.registerTask('prod', ['jshint', 'copy', 'jasmine', 'requirejs', 'concat', 'uglify', 'manifest:prod', 'clean:prod', 'exec:package']);

};
