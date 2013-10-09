module.exports = function(grunt) {
  var pkg = require('./package.json'),
      manifest = require('./manifest.json'),
      satconf = grunt.file.readYAML('./config.yml');

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

  // Update package.json
  pkg.version = satconf.version;
  grunt.file.write("package.json", JSON.stringify(pkg, null, 2));

  function updateConfigFile(env) {
    var conf = {};
    for (var key in satconf)
      conf[key] = satconf[key];

    if (env)
      conf.env = env;
    else if (! satconf.env)
      conf.env = "dev";

    if (! satconf.log_level)
      switch (conf.env) {
        case "test" :
          conf.log_level = satconf.default_test_log_level || "NONE";
          break;
        case "dev" :
          conf.log_level = satconf.default_dev_log_level || "ALL";
          break;
        default :
          conf.log_level = satconf.default_prod_log_level || "WARN";
      }

    if (! satconf.run_mode)
      switch (conf.env) {
        case "staging" :
        case "prod" :
          conf.run_mode = "auto";
          break;
        default :
          conf.run_mode = "manual";
      }

    grunt.file.write("build/config.js", 'var satconf = ' + JSON.stringify(conf, null, 2) + ';\n');
  }

  function updateManifest(env) {
    manifest.version = satconf.version;
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

  // Predefined tasks
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
        manifest.background.scripts[0] = 'build/background.js';
        manifest.content_scripts[0].js[0] = 'build/contentscript.js';
    }
    grunt.file.write("manifest.json", JSON.stringify(manifest, null, 2));
  });

  // Alias
  grunt.registerTask('default', ['dev-prod']);
  grunt.registerTask('test', ['version', 'jshint', 'config:test', 'copy', 'jasmine']);
  grunt.registerTask('dev', ['test', 'config:dev', 'requirejs', 'concat', 'manifest:dev']);
  grunt.registerTask('dev-prod', ['test', 'config:dev-prod', 'requirejs', 'concat', 'manifest:dev', 'clean:dev']);
  grunt.registerTask('prod-dev', ['test', 'config:prod-dev', 'requirejs', 'concat', 'manifest:dev', 'clean:dev']);
  grunt.registerTask('staging', ['test', 'config:staging', 'requirejs', 'concat', 'uglify', 'manifest:min', 'clean:prod']);
  grunt.registerTask('prod', ['test', 'config:prod', 'requirejs', 'concat', 'uglify', 'manifest:min', 'clean:prod', 'exec:package']);
};
