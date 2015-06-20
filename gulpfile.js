var gulp = require('gulp');
var sass = require('gulp-sass');
var autoprefixer = require('gulp-autoprefixer');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');

gulp.task('sass', function () {
  gulp.src('./sass/*.scss')
    .pipe(sass())
    .pipe(autoprefixer())
    .pipe(gulp.dest('./www/css/'));
});

gulp.task('js', function () {
  gulp.src('./www/js/*.js')
    .pipe(sourcemaps.init({loadMaps: true}))
    .pipe(uglify())
    .pipe(sourcemaps.write('../maps'))
    .pipe(gulp.dest('./www/js/min/'));
});

gulp.task('default', function() {
  gulp.watch('./sass/*.scss',['sass']);
  gulp.watch('./www/js/*.js',['js']);
});
