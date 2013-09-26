module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    jshint: {
      files: [
        'Gruntfile.js',
        'src/*.js',
        'test/*.js',
        '../common/mapping.js','../common/viking.js',
      ],
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
    // concat: {
    //   options: {
    //     separator: ';'
    //   },
    //   background: {
    //     src: [
    //       "lib/jquery-1.9.1.min.js",
    //       "lib/uri.js",
    //       'controllers/background.js',
    //     ],
    //     dest: 'build/background.js'
    //   },
    //   contentscript: {
    //     src: [
    //       "lib/underscore-min.js",
    //       "lib/jquery-1.9.1.min.js",
    //       "lib/jquery-ui-1.10.3.custom.min.js",
    //       "lib/css_struct.js",
    //       "lib/html_utils.js",
    //       "lib/path_utils.js",
    //       "controllers/toolbar_contentscript.js",
    //       "controllers/mapping_contentscript.js",
    //     ],
    //     dest: 'build/contentscript.js'
    //   }
    // },
    // uglify: {
    //   options: {
    //     banner: '/*! <%= pkg.name %> <%= grunt.template.today("dd-mm-yyyy") %> */\n'
    //   },
    //   background: {
    //     files: {
    //       'dist/background.min.js': ['<%= concat.background.dest %>']
    //     }
    //   },
    //   contentscript: {
    //     files: {
    //       'dist/contentscript.min.js': ['<%= concat.contentscript.dest %>']
    //     }
    //   }
    // },
  });

  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-contrib-copy');
  // grunt.loadNpmTasks('grunt-contrib-jasmine');
  // grunt.loadNpmTasks('grunt-contrib-concat');
  // grunt.loadNpmTasks('grunt-contrib-uglify');

  // grunt.registerTask('test', ['jshint', 'jasmine']);
  grunt.registerTask('default', ['jshint', 'copy', /*'jasmine', 'concat'*/]);
  // grunt.registerTask('prod', ['jshint', 'copy', jasmine', 'concat', 'uglify']);
};