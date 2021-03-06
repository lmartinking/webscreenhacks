_ = require 'underscore'
{typing} = require '../../assets/js/typewriting'

describe "Typewriting", ->
    describe "Tokens", ->
        describe "Pause Token", ->
            it "uses timeout to the one given to it", ->
                timeout = {}
                expect(new typing.PauseToken(timeout).timeout).toBe timeout
                
            it "defaults timeout to a random number if none given", ->
                timeout1 = new typing.PauseToken().timeout
                timeout2 = new typing.PauseToken().timeout
                timeout3 = new typing.PauseToken().timeout
                for timeout in [timeout1, timeout2, timeout3]
                    expect(_.isNumber timeout).toBe true
                
                expect(_.uniq([timeout1, timeout2, timeout3]).length).toBe 3
        
        describe "Backspace Token", ->
            it "sets first parameter to taking", ->
                taking = {}
                expect(new typing.BackspaceToken(taking).taking).toBe taking
        
        describe "Character Token", ->
            it "takes parameters as mistake, char, noticeable", ->
                char = {}
                mistake = {}
                noticeable = {}
                token = new typing.CharacterToken(mistake, char, noticeable)
                expect(token.char).toBe char
                expect(token.mistake).toBe mistake
                expect(token.noticeable).toBe noticeable

    describe "Action Stream", ->
        beforeEach ->
            @stream = new typing.ActionStream()
        
        it "defaults stack to empty list", ->
            expect(@stream.stack).toEqual []
        
        it "defaults needs_pause to false", ->
            expect(@stream.needs_pause).toBe false
        
        describe "Determining next action", ->
            it "returns a backspace if it should", ->
                backspace_token = {}
                @stub(@stream, 'should_backspace').returns true
                @stub(@stream, 'make_backspace').returns backspace_token
                expect(@stream.next()).toBe backspace_token
            
            it "returns a pause if no backspace but pause is needed", ->
                pause_token = {}
                @stub(@stream, 'should_backspace').returns false
                @stream.needs_pause = true
                
                @stub(@stream, 'make_pause').returns pause_token
                expect(@stream.next()).toBe pause_token
                
            it "returns a character if no backspace or pause", ->
                character_token = {}
                @stub(@stream, 'should_backspace').returns false
                @stream.needs_pause = false
                
                @stub(@stream, 'make_character').returns character_token
                expect(@stream.next()).toBe character_token
            
            it "doesn't make a pause or character if should backspace", ->
                @stub(@stream, 'make_pause')
                @stub(@stream, 'make_character')
                @stub(@stream, 'should_backspace').returns true
                @stream.next()
                
                refute.called(@stream.make_pause)
                refute.called(@stream.make_character)
            
            it "doesn't make a backspace or character if should pause", ->
                @stub(@stream, 'make_backspace')
                @stub(@stream, 'make_character')
                @stub(@stream, 'should_backspace').returns false
                @stream.needs_pause = true
                @stream.next()
                
                refute.called(@stream.make_backspace)
                refute.called(@stream.make_character)
            
            it "doesn't make a backspace or pause if should pause", ->
                @stub(@stream, 'make_pause')
                @stub(@stream, 'make_backspace')
                @stub(@stream, 'should_backspace').returns false
                @stream.needs_pause = false
                @stream.next()
                
                refute.called(@stream.make_pause)
                refute.called(@stream.make_backspace)
            
            describe "When backspacing", ->
                it "sets stack to empty", ->
                    @stream.stack = [1, 2]
                    @stub(@stream, 'should_backspace').returns true
                    @stream.next()
                    expect(@stream.stack).toEqual []
                
                it "sets needs_pause to true", ->
                    @stream.stack.needs_pause = true
                    @stub(@stream, 'should_backspace').returns true
                    @stream.next()
                    expect(@stream.needs_pause).toBe true
            
            describe "When Pausing", ->
                it "does not add pause to the stack when stack is empty", ->
                    @stream.stack = []
                    @stub(@stream, 'should_backspace').returns false
                    @stream.needs_pause = true
                    expect(@stream.next().constructor).toEqual typing.PauseToken
                    expect(@stream.stack).toEqual []
                
                it "does not add pause to the stack when stack is not empty", ->
                    @stream.stack = [1, 2]
                    @stub(@stream, 'should_backspace').returns false
                    @stream.needs_pause = true
                    expect(@stream.next().constructor).toEqual typing.PauseToken
                    expect(@stream.stack).toEqual [1, 2]
            
            describe "When a Character", ->
                beforeEach ->
                    @stream.needs_pause = false
                    @stub(@stream, 'should_backspace').returns false
                
                it "adds character to empty stack only if character is a mistake", ->
                    character = mistake:true, constructor:typing.CharacterToken
                    @stub(@stream, 'make_character').returns character
                    
                    @stream.stack = []
                    expect(@stream.next()).toBe character
                    expect(@stream.stack).toEqual [character]
                
                it "doesn't add character to empty stack if not a mistake", ->
                    character = mistake:false, constructor:typing.CharacterToken
                    @stub(@stream, 'make_character').returns character
                    
                    @stream.stack = []
                    expect(@stream.next()).toBe character
                    expect(@stream.stack).toEqual []
                    
                it "adds non-mistake character to stack if not empty", ->
                    character = mistake:false, constructor:typing.CharacterToken
                    @stub(@stream, 'make_character').returns character
                    
                    @stream.stack = [1, 2]
                    expect(@stream.next()).toBe character
                    expect(@stream.stack).toEqual [1, 2, character]
            
            describe "Making a pause", ->
                it "sets needs_pause to false", ->
                    @stream.needs_pause = true
                    @stream.make_pause()
                    expect(@stream.needs_pause).toBe false
                
                it "returns an instance of PauseToken()", ->
                    expect(@stream.make_pause().constructor).toBe typing.PauseToken
            
            describe "Making a backspace", ->
                it "makes a backspace token", ->
                    @stream.stack = [1]
                    expect(@stream.make_backspace().constructor).toBe typing.BackspaceToken
                
                it "gives token the last thing on the stack", ->
                    last = {}
                    @stream.stack = [1, 2, last]
                    expect(@stream.make_backspace().taking).toBe last
                    expect(@stream.stack).toEqual [1, 2]
            
            describe "Making a character", ->
                it "makes a character token", ->
                    expect(@stream.make_character().constructor).toBe typing.CharacterToken
                
                it "tells it if it's a mistake via make_accident()", ->
                    accident = {}
                    @stub(@stream, 'make_accident').returns accident
                    expect(@stream.make_character().mistake).toBe accident
            
            describe "Determining if accident should be made", ->
                it "returns whether random number is greater than 0.9", ->
                    spied_random = @stub(Math, 'random')
                    spied_random.returns(0.4)
                    expect(@stream.make_accident()).toBe false
                    
                    spied_random.returns(0.8)
                    expect(@stream.make_accident()).toBe false
                    
                    spied_random.returns(0.9)
                    expect(@stream.make_accident()).toBe false
                    
                    spied_random.returns(0.91)
                    expect(@stream.make_accident()).toBe true
                    
                    spied_random.returns(0.94)
                    expect(@stream.make_accident()).toBe true
                    
                    spied_random.returns(1.0)
                    expect(@stream.make_accident()).toBe true
            
            describe "Determining if backspace should be made", ->
                it "says yes if we have a stack and a mistake is noticed", ->
                    @stub(@stream, 'notice_mistake').returns true
                    @stream.stack = [1, 2]
                    expect(@stream.should_backspace()).toBe true
                
                it "says no if the stack is empty", ->
                    @stub(@stream, 'notice_mistake').returns true
                    @stream.stack = []
                    expect(@stream.should_backspace()).toBe false
                
                it "says no if we have a stack but mistake isn't noticed", ->
                    @stub(@stream, 'should_backspace').returns false
                    @stream.stack = [1, 2]
                    expect(@stream.should_backspace()).toBe false
            
            describe "Noticing a mistake", ->
                it "returns whether random number is greater than 0.8", ->
                    spied_random = @stub(Math, 'random')
                    @stream.stack = [1]
                    
                    spied_random.returns(0.4)
                    expect(@stream.notice_mistake()).toBe false
                    
                    spied_random.returns(0.8)
                    expect(@stream.notice_mistake()).toBe false
                    
                    spied_random.returns(0.81)
                    expect(@stream.notice_mistake()).toBe true
                    
                    spied_random.returns(0.94)
                    expect(@stream.notice_mistake()).toBe true
                    
                    spied_random.returns(1.0)
                    expect(@stream.notice_mistake()).toBe true
                
                it "returns true if length of stack is greater than 5", ->
                    @stub(Math, 'random')
                    @stream.stack = [1, 2, 3, 4, 5, 6]
                    expect(@stream.notice_mistake()).toBe true
                    refute.called(Math.random)
