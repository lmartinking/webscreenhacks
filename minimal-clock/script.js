//(function($) {

jQuery(document).ready( function () {
	var $ = jQuery;

	var clock = {};
	clock.show_seconds = true;
	clock.blink_separators = true;

	function pad(num) {
		if (num < 10) {
			return '0' + num;
		} else {
			return String(num);
		}
	}

	if (!clock.show_seconds) {
		$("#clock").addClass('noseconds');
	}

	function draw_clock(h, m, s) {
		var mins = "<span class='minutes'>" + pad(m) + "</span>";
		var hours = "<span class='hours'>" + pad(h) + "</span>";

		var seconds = s;
		
		var sep;

		if (seconds % 2 == 0 || !clock.blink_separators) {
			sep = "<span class='separator'>:</span>";
		} else {
			sep = "<span class='separator separator-odd'>:</span>";
		}

		var time;

		if (clock.show_seconds) {
			var secs = "<span class='seconds'>" + pad(seconds) + "</span>";
			time = [hours, sep, mins, sep, secs].join("");
		} else {
			time = [hours, sep, mins].join("");
		}

		var newtime = $("<span class='time'>" + time + "</span>");

		var old = $("#clock").children();

		newtime.hide().appendTo("#clock").fadeIn(500, function () {
			$(old).each( function () {
				$(this).remove();
			});
		});
	}

	var hknob;
	var mknob;
	var sknob;

	function setup_knobs() {
		var knobs = $("#knobs");
		hknob = $("<div class='hours'><input class='knob'   id='hknob' data-max='12' data-thickness='0.2' value='0'/><div>").appendTo(knobs);
		mknob = $("<div class='minutes'><input class='knob' id='mknob' data-max='60' data-thickness='0.2' value='0'/><div>").appendTo(knobs);
		sknob = $("<div class='seconds'><input class='knob' id='sknob' data-max='60' data-thickness='0.2' value='0'/><div>").appendTo(knobs);

		knobs.find(".knob").knob();

		hknob = hknob.find(".knob").data('knobControl');
		mknob = mknob.find(".knob").data('knobControl');
		sknob = sknob.find(".knob").data('knobControl');
	}

	function draw_knobs(h, m, s) {
		if (h >= 12) {
			h = h - 12;
		}

		hknob.setVal(h); hknob.draw();
		mknob.setVal(m); mknob.draw();
		sknob.setVal(s); sknob.draw();
	}

	var hbar;
	var mbar;
	var sbar;

	function setup_timebars() {
		var tb = $("#timebars");
		hbar = $("<span class='hours'></span>").appendTo(tb);
		mbar = $("<span class='minutes'></span>").appendTo(tb);
		sbar = $("<span class='seconds'></span>").appendTo(tb);
	}

	var timebar_started = false;

	function draw_timebars(h, m, s) {
		var w = $("#timebars").width();

		hbar.animate({
			'width': (h / 24 * w).toFixed(0) + 'px'
		}, 500);
		mbar.animate({
			'width': (m / 60 * w).toFixed(0) + 'px'
		}, 500);

		if (timebar_started == false) {
			var diff = 59 - s;

			sbar.width(s / 60 * w);
			sbar.animate({
				'width': w
			}, diff * 1000, 'linear');

			timebar_started = true;
		}

		if (s == 59) {
			sbar.stop().animate({
				'width': 0/*(s / 60 * w).toFixed(0) + 'px'*/
			}, 1000);
		}

		if (s == 0) {
			sbar.stop().animate({
				'width': w/*(s / 60 * w).toFixed(0) + 'px'*/
			}, 59000, 'linear');
		}
	}

	function draw_looped() {
		var now = new Date();
		var h = now.getHours();
		var m = now.getMinutes();
		var s = now.getSeconds();

		draw_clock(h, m, s);
		draw_timebars(h, m, s);
		draw_knobs(h, m, s);
		setTimeout( draw_looped, 1000);
	}

	setup_knobs();
	setup_timebars();
	draw_looped(); 
});
