'use strict';

var gulp = require('gulp');
var open = require('open');
var bower = require('./bower.json');
var $ = require('gulp-load-plugins')();

gulp.task('clean', function () {
	return gulp.src(['dist'], { read: false }).pipe($.clean());
});

gulp.task('dist', ['clean'], function(callback){
	gulp.src(['SWAN/**/*']).pipe(gulp.dest('dist/SWAN/'));
	gulp.src(['CN51/**/*']).pipe(gulp.dest('dist/CN51/'));
	return gulp.src(['WIDGET/**/*']).pipe(gulp.dest('dist/WIDGET/'));
});

gulp.task('deploy', ['dist'], function () {
	return gulp.src('dist/**/*').pipe($.ghPages({
		remoteUrl: bower.repository.url
	}));
});

gulp.task('serve:app', function () {
	$.connect.server({
		root: ['./'],
		port: 9000,
		livereload: true
	});
	open('http://localhost:9000/SWAN/index.html');
});

gulp.task('serve:dist', ['dist'], function () {
	$.connect.server({
		root: ['dist'],
		port: 9001,
		livereload: false
	});
	open('http://localhost:9001/SWAN/index.html');
});

gulp.task('serve', ['serve:app'], function () {
	gulp.watch([
		'SWAN/**/**',
		'WIDGET/**/**',
		'CN51/**/**'
	], function (event) {
		return gulp.src(event.path).pipe($.connect.reload());
	});
});