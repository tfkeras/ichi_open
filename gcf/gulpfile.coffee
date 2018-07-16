gulp = require 'gulp'
coffee = require 'gulp-coffee'
gulp.task 'default', () ->
  gulp.src(['*.coffee',"!gulpfile.coffee","!webpack.config.coffee"])
    .pipe(coffee())
    .pipe(gulp.dest('./dist/'))
  gulp.src('*.json').pipe(gulp.dest('./dist/'))
