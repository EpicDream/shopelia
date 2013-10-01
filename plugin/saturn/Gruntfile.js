module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      options: {
        separator: ';'
      },
      background: {
        src: ["lib/utils.js","lib/jquery-1.9.1.min.js","lib/uri.js","src/tree.js", 'src/saturn_options.js', 'src/saturn_session.js', 'src/saturn.js'],
        dest: 'build/background.js'
      },
      crawler: {
        src: ["lib/utils.js", "lib/underscore-min.js", "lib/jquery-1.9.1.min.js", "lib/html_utils.js", "src/crawler.js"],
        dest: 'build/crawler.js'
      },
      chrome_back: {
        src: ['<%= concat.background.dest %>', 'src/chrome/chrome_saturn.js'],
        dest: 'build/chrome_background.js'
      },
      chrome_crawler: {
        src: ['<%= concat.crawler.dest %>', 'src/chrome/chrome_crawler.js'],
        dest: 'build/chrome_crawler.js'
      },
    },
    uglify: {
      options: {
        banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
      },
      chrome_back: {
        files: {
          'dist/chrome_background.min.js': ['<%= concat.chrome_back.dest %>']
        }
      },
      chrome_crawler: {
        files: {
          'dist/chrome_crawler.min.js': ['<%= concat.chrome_crawler.dest %>']
        }
      }
    },
    jasmine: {
      src: ['src/*.js'],
      options: {
        vendor: ['lib/*.js'],
        specs: ['test/*.js']
      }
    },
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
  });

  function updateManifest(env) {
    var manifest = grunt.file.readJSON("manifest.json");
    switch (env) {
      case 'prod' :
        manifest.background.scripts[0] = 'dist/chrome_background.min.js';
        manifest.content_scripts[0].js[0] = 'dist/chrome_crawler.min.js';
        break;
      default :
        manifest.background.scripts[0] = 'build/chrome_background.js';
        manifest.content_scripts[0].js[0] = 'build/chrome_crawler.js';
    }
    grunt.file.write("manifest.json", JSON.stringify(manifest));
  }

  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-jasmine');
  grunt.loadNpmTasks('grunt-contrib-concat');

  grunt.registerTask('manifest', updateManifest);
  grunt.registerTask('test', ['jshint', 'jasmine']);
  grunt.registerTask('default', ['jshint', 'jasmine', 'concat', 'manifest:dev']);
  grunt.registerTask('prod', ['jshint', 'jasmine', 'concat', 'uglify', 'manifest:prod']);

};
