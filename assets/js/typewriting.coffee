random_string = (length) ->
	chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz"
	result = []

	for i in [0...length]
		rnum = Math.floor(Math.random() * chars.length)
		result.push chars.substring(rnum, rnum + 1)

	result.join ""
		
class TypeWriter
	constructor: (@$el) ->
	
	setup: ->
		@text = 
		      "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. "
			+ "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. "
			+ "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. "
			+ "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		@stack = []
		@offset = 0
		@removing = false
		@finished_backspace = false
	
	draw: ->
		if @should_backspace()
			@backspace()
		else
			if @finished_backspace
				# Looks a bit weird if it doesn't pause after backspacing
				@finished_backspace = false
			else
				@add_character()
	
	backspace: ->
		txt = @$el.text()
		@$el.text txt.substring(0, txt.length - 1)
		if @stack.length > 0
			[mistake, char] = @stack.pop()
			if not mistake
				@offset -= 1
    
	add_character: ->
		accident = @make_accident()
		if accident?
			str = accident
			for index in [0...str.length]
				@stack.push [true, str.charAt(index)]
		else
			str = (@next_character() for i in [0...2 * Math.random()]).join ''
			if @stack.length > 0
				for index in [0...str.length]
					@stack.push [false, str.charAt(index)]
		
		@$el.append str
	
	next_character: ->
		if @offset < 0
			@offset = 0
		
		if @offset >= @text.length
			str = " "
			@offset = 0
		else
			str = @text[@offset]
			@offset += 1
		str
		
	should_backspace: ->
		if @removing and @stack.length == 0
			@finished_backspace = true
			@removing = false
		
		@removing = @removing or @stack.length > 10 or (@stack.length > 0 and @notice_mistake())
	
	notice_mistake: ->
		@stack.length > 10 or Math.random() > 0.8
	
	make_accident: ->
		random = Math.random()
		if random > 0.9
			length = @random_length random, 0.9
			random_string length
	
	random_length: (random, take) ->
		Math.ceil(Math.abs(random - take) * 100 / 4) || 1

do ($=jQuery) ->
	$ ->
		typewriter = new TypeWriter $("#typewriting")
		typewriter.setup()
		
		twitch = ->
			typewriter.draw()
			timeout = if typewriter.removing
					timeout = 100
				else
					if Math.random() > 0.5
						timeout = 50 + Math.random() * Math.random() * 2000;
					else
						timeout = 50 + Math.random() * Math.random() * 1000;
			
			setTimeout twitch, timeout
		
		twitch()
