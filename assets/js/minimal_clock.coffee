settings =
	time:
		debug: false
	clock:
		show_seconds: true
		blink_separators: true
		
pad = (num) ->
	if num < 10
		"0#{num}"
	else
		"#{num}"

class Knob
	constructor: (@typ, @$el) ->
	
	setup: ->
		@$el.knob()
		@max = Number(@$el.attr "data-max")
		@control = @$el.data 'knobControl'
		
	draw: (value, forced=false) ->
		@last_value ?= value unless forced
		if value == 0 and @last_value == @max - 1
			@reverse()
		else
			@control.setVal value
			@control.draw()
		
		@last_value = value unless forced
	
	reverse: (value) ->
		val = @max
		interval = undefined
		next_step = =>
			val -= 1
			if val == 0
				clearInterval interval
			else
				@draw val, true
		
		interval = setInterval next_step, Math.floor(1000 / @max)
		
class TimeBar
	constructor: (@typ, @$el) ->
		
	width: (val) ->
		@$el.width val
		
	draw: (width, duration, easing, complete) ->
		@$el.stop().animate {width}, duration, easing, complete

class Knobs
	constructor: (@container) ->
		@elements = ['hours', 'minutes', 'seconds']
		for element in @elements
			@[element] = new Knob(element, $ ".#{element} input", @container)
	
	draw: (h, m, s) ->
		h -= 12 if h >= 12
		@hours.draw(h)
		@minutes.draw(m)
		@seconds.draw(s)
	
	setup: ->
		@[element].setup() for element in @elements

class TimeBars
	constructor: (@$el) ->
		for element in ['seconds', 'minutes', 'hours']
			@[element] = new TimeBar element, $ ".#{element}", @$el
	
	setup:(s) ->
		w = @$el.width()
		diff = 59 - s
		@seconds.width(s / 60 * w)
		@seconds.draw w, diff * 1000, 'linear'		
	
	draw: (h, m, s) ->
		w = @$el.width()

		@hours.draw (h / 24 * w).toFixed(0), 500
		@minutes.draw (m / 60 * w).toFixed(0), 500
		
		if s == 59
			@seconds.draw 0, 1000
		
		else if s == 0
			@seconds.draw w, 59000, 'linear'
	
class Clock
	constructor: (@$el) ->
		@separators = $ ".separator", @$el
		for element in ['seconds', 'minutes', 'hours']
			@[element] = $ ".#{element}", @$el
	
	setup: (start_hidden) ->
		unless settings.clock.show_seconds
			@$el.addClass 'noseconds'
		
		initial_cls = "fadein"
		if start_hidden
			initial_cls = "fadeout"
		
		@hours.addClass initial_cls
		@minutes.addClass initial_cls
		@seconds.addClass initial_cls
		
	draw: (h, m, s) ->			
		@hours.text pad(h)
		@minutes.text pad(m)
		@seconds.text pad(s)
		@$el.show()
	
	toggle: (hidden_seperators) ->
		if settings.clock.blink_separators
			@separators.each -> $(this).toggleClass "transparent"
		
		@hours.toggleClass("fadeout").toggleClass("fadein")
		@minutes.toggleClass("fadeout").toggleClass("fadein")
		@seconds.toggleClass("fadeout").toggleClass("fadein")

# Make a function that returns the time
# Debug version forces time to be just before midnight
make_time_teller = (debug) ->
	unless debug
		time_teller = ->
			now = new Date()
			h = now.getHours()
			m = now.getMinutes()
			s = now.getSeconds()
			[h, m, s]
	else
		# Force it to be next to midnight	
		h = 23
		m = 59
		s = 55
		time_teller = (progress=0) ->
			if s == 60
				s = 0
				m += 1
			
			if m == 60
				m = 0
				h += 1
			
			if h == 24
				h = 0
			
			result = [h, m, s]
			s += progress
			result
	
do ($=jQuery) ->
	$ ->
		# Two clocks so we can do nice fades
		clock1 = new Clock $("#clock1")
		clock2 = new Clock $("#clock2")
		
		knobs = new Knobs $("#knobs")
		timebars = new TimeBars $("#timebars")
		
		# Get function to determine h, m and s
		time_teller = make_time_teller(settings.time.debug)
		
		# Loop that updates drawing
		twitch = ->
			[h, m, s] = time_teller(1)
			
			# Alternate clocks so that number stays the same when fading
			if s % 2 == 0
				clock1.draw h, m, s
			else
				clock2.draw h, m, s
			
			# Toggle both clocks to get the crossfade effect
			clock1.toggle()
			clock2.toggle()
			
			# Knobs and timebars not as complicated as clock !
			knobs.draw h, m, s
			timebars.draw h, m, s
		
		# Setup clocks and make sure one is hidden
		# And make sure that clock1 is the one that starts hidden
		# To align with what happens to clock1 in twitch
		[h, m, s] = time_teller()
		clock1.setup(s % 2 == 0)
		clock2.setup(s % 2 == 1)
		
		# Initial setup
		knobs.setup()
		timebars.setup(new Date().getSeconds())
		
		# Don't need to wait a full second for things to appear
		twitch()
		
		# Make it twitch every second
		setInterval twitch, 1000
