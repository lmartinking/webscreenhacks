########################
#   TOKENS FOR THE TOKEN STREAM
########################

class PauseToken
	constructor: (@timeout) ->
		@timeout ?= Math.random() * 500

class BackspaceToken
	constructor: (@taking) ->

class CharacterToken
	constructor: (@mistake, @char) ->

########################
#   TOKENS STREAM GENERATOR
########################

# Action Stream generates tokens instructing what order things should happen
# What happens with these tokens, when the next token should be generated etc is not it's responsiblity
# It keeps track of when mistakes are made and how long since a mistake was made

class ActionStream
	constructor: ->
		@stack = []
		@needs_pause = false
	
	next: ->
		token = if @should_backspace()
				@stack = []
				@needs_pause = true
				@make_backspace()
			else
				if @needs_pause
					@make_pause()
				else
					@make_character()
		
		if token.mistake or @stack.length > 0
			@stack.push token
		token
	
	make_pause: ->
		@needs_pause = false
		new PauseToken()
	
	make_backspace: ->
		new BackspaceToken @stack.pop()
	
	make_character: ->
		new CharacterToken @make_accident()
	
	make_accident: ->
		Math.random() > 0.9
	
	should_backspace: ->
		@stack.length > 0 and @notice_mistake()
	
	notice_mistake: ->
		@stack.length > 5 or Math.random() > 0.8

########################
#   TOKEN STREAM CONSUMER
########################

# Takes tokens from the ActionStream and converts single tokens into one or more characters/actions
# What is done with these characters/actions isn't up to the analyser

class StreamAnalyser
	constructor: (@actionstream, @text, @keyboard_map) ->
		@index = -1
		@token = undefined
		@since_last_mistake = undefined
	
	next: ->
		token = @token ?= @actionstream.next()
		switch @token.constructor
			when BackspaceToken
				taking_mistake = @since_last_mistake.pop()
				if not taking_mistake
					@index -= 1
				
				# No more backspace if no mistakes
				if @since_last_mistake.length == 0
					@token = undefined
					@since_last_mistake = undefined
			
			when PauseToken
				# Only pause once
				@token = undefined
				
			when CharacterToken
				# Make planned if haven't planned this token yet
				@planned ?= @plan_string token.mistake
				if token.mistake
					@since_last_mistake ?= []
				
				# Get next char from plan
				# And add to since_last_mistake if we have such a a list
				char = @planned.pop()
				if @since_last_mistake?
					@since_last_mistake.push token.mistake
				
				# Return a token with the next character
				token = new CharacterToken token.mistake, char
				
				# Need a new token if run out of planned
				if @planned.length == 0
					@token = undefined
					@planned = undefined
			
			else
				# Unkown token, go to the next one
				@token = undefined
		
		token
	
	plan_string: (mistake) ->
		random = Math.random()
		length = Math.ceil(Math.abs(random - 0.5) * random) || 1
		max_length = @text.length - @index
		length = max_length if length > max_length
		
		correct = for i in [0...length]
			@text[@index + i]
		
		if mistake
			@keyboard_map.dyslexic_line(correct)
		else
			@index += length
			correct
	
	exhausted: ->
		@index == @text.length

########################
#   TYPEWRITER
########################

# Takes characters/actions from the StreamAnalyser and displays them
# It is also responsible for how long between each character/action it should do things

class TypeWriter
	constructor: (@$el) ->
	
	draw: (analyser) ->
		token = analyser.next()
		switch token.constructor
			when BackspaceToken
				txt = @$el.text()
				@$el.text txt.substring(0, txt.length - 1)
				@backspace_timeout()
			
			when PauseToken
				token.timeout
			
			when CharacterToken
				@$el.append token.char
				@character_timeout(token.mistake)
	
	backspace_timeout: -> 100
	
	character_timeout: (mistake) ->
		multiplier = if mistake then 2000 else 1000
		50 + Math.random() * Math.random() * multiplier

do ($=jQuery) ->
	$ ->
		typewriter = new TypeWriter $("#typewriting")
		actionstream = new ActionStream()
		keyboard_map = new KeyboardMap()
		
		text = """
			Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
			Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
			Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
			Excepeur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. 
		"""
		
		analyser = undefined
		
		twitch = ->
			if not analyser? or analyser.exhausted()
				analyser = new StreamAnalyser(actionstream, text, keyboard_map)
			
			timeout = typewriter.draw(analyser)
			setTimeout twitch, timeout
		
		twitch()
