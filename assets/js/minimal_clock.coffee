do ($=JQuery) ->
	clock =
		show_seconds: true
		blink_separators: true

	pad = (num) ->
		if num < 10
			"0#{num}"
		else
			"#{num}"

	unless clock.show_seconds
		$("#clock").addClass('noseconds')

	draw_clock = (h, m, s) ->
		mins = "<span class='minutes'>#{pad(m)}</span>"
		hours = "<span class='hours'>#{pad(h)}</span>"
		seconds = s

		sep = if seconds % 2 == 0 or not clock.blink_separators
				"<span class='separator'>:</span>"
			else
				"<span class='separator separator-odd'>:</span>"

		if clock.show_seconds
			secs = "<span class='seconds'>#{pad(seconds)}</span>";
			time = [hours, sep, mins, sep, secs].join("")
		else
			time = [hours, sep, mins].join("")

		newtime = $("<span class='time'>#{time}</span>")

		old = $("#clock").children()

		newtime.hide().appendTo("#clock").fadeIn 500, ->
			$(old).each ->
				$(this).remove()

	hknob = undefined
	mknob = undefined
	sknob = undefined
	
	setup_knobs = ->
		knobs = $("#knobs")
		hknob = $("<div class='hours'><input class='knob'   id='hknob' data-max='12' data-thickness='0.2' value='0'/><div>").appendTo(knobs)
		mknob = $("<div class='minutes'><input class='knob' id='mknob' data-max='60' data-thickness='0.2' value='0'/><div>").appendTo(knobs)
		sknob = $("<div class='seconds'><input class='knob' id='sknob' data-max='60' data-thickness='0.2' value='0'/><div>").appendTo(knobs)

		knobs.find(".knob").knob()

		hknob = hknob.find(".knob").data('knobControl')
		mknob = mknob.find(".knob").data('knobControl')
		sknob = sknob.find(".knob").data('knobControl')

	draw_knobs = (h, m, s) ->
		h -= 12 if h >= 12
		hknob.setVal(h); hknob.draw()
		mknob.setVal(m); mknob.draw()
		sknob.setVal(s); sknob.draw()

	hbar = undefined
	mbar = undefined
	sbar = undefined

	setup_timebars = ->
		tb = $("#timebars")
		hbar = $("<span class='hours'></span>").appendTo(tb)
		mbar = $("<span class='minutes'></span>").appendTo(tb)
		sbar = $("<span class='seconds'></span>").appendTo(tb)

	timebar_started = false

	draw_timebars = (h, m, s) ->
		w = $("#timebars").width()

		hbar.animate
			width: (h / 24 * w).toFixed(0)
		, 500
		
		mbar.animate
			width: (m / 60 * w).toFixed(0)
		, 500

		unless timebar_started
			diff = 59 - s

			sbar.width(s / 60 * w)
			sbar.animate
				width: w
			, diff * 1000
			, 'linear'

			timebar_started = true

		if s == 59
			sbar.stop().animate
				width: 0
			, 1000
		
		if s == 0
			sbar.stop().animate
				width: w
			, 59000
			, 'linear'

	draw_looped = ->
		now = new Date()
		h = now.getHours()
		m = now.getMinutes()
		s = now.getSeconds()

		draw_clock(h, m, s)
		draw_timebars(h, m, s)
		draw_knobs(h, m, s)
		setTimeout( draw_looped, 1000)

	setup_knobs()
	setup_timebars()
	draw_looped()
