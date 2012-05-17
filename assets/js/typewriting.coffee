randomString = (length) ->
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
		@offset = 0
		@mistake = false
	
	draw: ->
		if @mistake
			@backspace()
			@mistake = false
		else
			if Math.random() > 0.9
				@add_character randomString(1)
				@mistake = true;
			else
				@add_character()
		
		# Return mistake to alter next timeout
		@mistake
	
	backspace: ->
		txt = @$el.text()
		@$el.text txt.substring(0, txt.length - 1)
    
	add_character: (str) ->
		@$el.append str ? @next_character()
	
	next_character: ->
		if @offset > @text.length
			str = " "
			@offset = 0
		else
			str = @text[@offset]
			@offset += 1
		str

do ($=jQuery) ->
	$ ->
		typewriter = new TypeWriter $("#typewriting")
		typewriter.setup()
		
		twitch = ->
			mistake = typewriter.draw()
			if mistake
				timeout = 50 + Math.random() * Math.random() * 2000;
			else
				timeout = 50 + Math.random() * Math.random() * 1000;
			
			setTimeout twitch, timeout
		
		twitch()
