"use strict"

# Listen on port 35729
LIVERELOAD_PORT = 35729

lrSnippet = require('connect-livereload')( port: LIVERELOAD_PORT )
folderMount = (connect, base) ->
  # Server static files.
  connect.static ( require("path").resolve base )

module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig

    ####
    ## standalone-server config.
    ####
    connect:
      options:
        port: 9000
        hostname: "localhost"
      dev:
        options:
          middleware: (connect, options) ->
            [lrSnippet, folderMount(connect, "src")]
      dist:
        options:
          middleware: (connect, options) ->
            [lrSnippet, folderMount(connect, "dist")]

    watch:
      options:
        livereload: true
      dev:
        options:
          cwd: "./src"
          livereload: LIVERELOAD_PORT
        files: ["**/*.html", "css/**/*.css", "js/**/*.js"]
      dist:
        options:
          cwd: "./src"
          livereload: LIVERELOAD_PORT
        files: [ "**/*.html", "css/**/*.css", "js/**/*.js" ]
        tasks: [ "clean", "copy",
                 "useminPrepare",
                 "concat", "uglify", "cssmin",
                 "usemin" ]

    ####
    ## output files config.
    ####
    clean:
      dist: [ ".tmp", "dist" ]

    copy:
      dist:
        files: [
          expand: true,
          dot: true,
          cwd: "src/"
          dest: "dist/"
          src: [
            "*"
            "css/**"
            "js/**"
          ]
          filter: "isFile"
        ]

    useminPrepare:
      options:
        root: "src"
        dest: "dist"
      html: ["dist/**/*.html"]

    usemin:
      options:
        dirs: ["dist/"]
      html: ["dist/**/*.html"]

  # modules load
  require('matchdep').filterDev('grunt-*').forEach grunt.loadNpmTasks

  # task configure
  grunt.registerTask "default", "server"

  grunt.registerTask "server", (target) ->

    if( target != "dist" )
      console.log "Development Server Mode..."
      return grunt.task.run ["connect:dev", "watch:dev"]
    else
      console.log "Distroduction Server Mode..."
      return grunt.task.run [ "clean", "copy", "useminPrepare",
                              "concat", "uglify", "cssmin",
                              "usemin", "connect:dist", "watch:dist" ]