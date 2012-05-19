_ = require 'underscore'
{typing} = require '../assets/js/typewriting'

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
