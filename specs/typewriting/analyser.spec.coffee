_ = require 'underscore'
{typing} = require '../../assets/js/typewriting'

describe "Typewriting", ->
    describe "Stream Analyser", ->
        beforeEach ->
            @text = {}
            @actionstream = {}
            @keyboard_map = {}
            @analyser = new typing.StreamAnalyser @actionstream, @text, @keyboard_map
        
        it "takes in actionstream, text and keyboard_map", ->
            analyser = new typing.StreamAnalyser @actionstream, @text, @keyboard_map
            assert.same analyser.text, @text
            assert.same analyser.actionstream, @actionstream
            assert.same analyser.keyboard_map, @keyboard_map
        
        it "starts index at 0", ->
            assert.same @analyser.index, 0
        
        it "starts token as undefined", ->
            refute.defined @analyser.token
        
        it "starts since_last_mistake as undefined", ->
            refute.defined @analyser.since_last_mistake

        describe "Getting next action", ->
            it "process current token if defined", ->
                token = name:'token'
                result = name:'result'
                
                @analyser.token = token
                @actionstream.next = @stub()
                @stub(@analyser, "process_token").returns result
                
                # Make sure analyser.next
                # * returns result of process_token
                # * Gives process_token existing token on analyser
                # * Doesn't get token from actionstream
                # * Leaves alone the token on the analyser
                assert.same @analyser.next(), result
                assert.calledWith @analyser.process_token, token
                refute.called @actionstream.next
                assert.same @analyser.token, token
            
            it "creates new token and sets it on the analyser if none defined", ->
                token = name:'token'
                result = name:'result'
                
                @analyser.token = undefined
                @actionstream.next = @stub().returns token
                @stub(@analyser, "process_token").returns result
                
                # Make sure analyser.next
                # * returns result of process_token
                # * Gives process_token a token from actionstream
                # * Puts token on the analyser
                assert.same @analyser.next(), result
                assert.calledWith @analyser.process_token, token
                assert.called @actionstream.next
                assert.same @analyser.token, token
        
        describe "Processing a token", ->
            it "determines function from the name of the constructor of the function", ->
                token = constructor:{name:'cons'}
                result = name:'result'
                func = @analyser.analyse_cons = @stub().returns result
                
                assert.same @analyser.process_token(token), result
                assert.calledWith func, token
            
            it "defaults to analyser.unknown_token if constructor not known", ->
                token = constructor:{name:'cons'}
                result = name:'result'
                func = @analyser.unknown_token = @stub().returns result
                
                assert.same @analyser.process_token(token), result
                assert.calledWith func, token
                
        describe "Determining if exhauseted", ->
            it "is exhausted when index is same as length of text", ->
                @analyser.index = 20
                @analyser.text = length:20
                assert @analyser.exhausted()
                
                @analyser.text = length:40
                refute @analyser.exhausted()
                
                @analyser.index = 50
                refute @analyser.exhausted()
                
                @analyser.index = 40
                assert @analyser.exhausted()
        
        describe "Analysing unknown token", ->
            it "returns given token", ->
                token = name:'token'
                assert.same @analyser.unknown_token(token), token
            
            it "sets token on the analyser to undefined", ->
                @analyser.token = name:'token'
                @analyser.unknown_token(@analyser.token)
                refute.defined @analyser.token
        
        describe "Analysing Pause token", ->
            it "returns given token", ->
                token = name:'token'
                assert.same @analyser.analyse_PauseToken(token), token
            
            it "sets token on the analyser to undefined", ->
                @analyser.token = name:'token'
                @analyser.analyse_PauseToken(@analyser.token)
                refute.defined @analyser.token
        
        describe "Analysing BackspaceToken", ->
            it "pops since_last_mistake", ->
                @analyser.since_last_mistake = [1, 2]
                @analyser.analyse_BackspaceToken(name:'token')
                assert.equals @analyser.since_last_mistake, [1]
            
            it "takes one from index if last thing since_last_mistake is false", ->
                @analyser.since_last_mistake = [true, false]
                @analyser.index = 20
                @analyser.analyse_BackspaceToken(name:'token')
                assert.equals @analyser.index, 19
            
            it "leaves index alone if last thing since_last_mistake is true", ->
                @analyser.since_last_mistake = [true, true]
                @analyser.index = 20
                @analyser.analyse_BackspaceToken(name:'token')
                assert.equals @analyser.index, 20
            
            it "sets token to undefined if since_last_mistake is empty after pop", ->
                token = name:'token'
                @analyser.token = token
                @analyser.since_last_mistake = [true]
                @analyser.analyse_BackspaceToken(token)
                refute.defined @analyser.token
            
            it "leaves token if since_last_mistake is not empty after pop", ->
                token = name:'token'
                @analyser.token = token
                @analyser.since_last_mistake = [true, true]
                @analyser.analyse_BackspaceToken(name:'token')
                assert.same @analyser.token, token
            
            it "sets since_last_mistake to undefined if since_last_mistake is empty after pop", ->
                token = name:'token'
                @analyser.token = token
                @analyser.since_last_mistake = [true]
                @analyser.analyse_BackspaceToken(token)
                refute.defined @analyser.token
            
            it "leaves since_last_mistake if since_last_mistake is not empty after pop", ->
                token = name:'token'
                @analyser.token = token
                @analyser.since_last_mistake = [true, true]
                @analyser.analyse_BackspaceToken(name:'token')
                assert.equals @analyser.since_last_mistake, [true]
            
            it "returns the token given to it", ->
                token = name:'token'
                @analyser.since_last_mistake = [true]
                assert.same @analyser.analyse_BackspaceToken(token), token

        describe "Analysing Character Token", ->
            it "records token", ->
                token = name:'token'
                stubbed = @stub @analyser, "record_character_token"
                @analyser.analyse_CharacterToken token
                assert.calledWith stubbed, token
                
            it "returns new character token", ->
                assert.equals @analyser.analyse_CharacterToken(name:'token').constructor.name, 'CharacterToken'
            
            describe "returned character token", ->
                it "sets mistake to token.mistake", ->
                    mistake = name:'mistake'
                    token = {name:'token', mistake}
                    stubbed = @stub(@analyser, "plan_for_character_token").returns [1, 2]
                    
                    result = @analyser.analyse_CharacterToken(token)
                    assert.same result.mistake, mistake
                
                it "sets char to char from plan_for_character_token", ->
                    char = name:'char'
                    token = name:'token'
                    correct_char = name:'correct_char'
                    
                    stubbed = @stub(@analyser, "plan_for_character_token").returns [char, correct_char]
                    result = @analyser.analyse_CharacterToken(token)
                    assert.same result.char, char
                    
                it "sets noticeable to whether results from plan_for_character_token are different", ->
                    char = name:'char'
                    token = name:'token'
                    correct_char = name:'correct_char'
                    
                    stubbed = @stub @analyser, "plan_for_character_token"
                    
                    stubbed.returns [1, 2]
                    assert @analyser.analyse_CharacterToken(token).noticeable
                    
                    stubbed.returns [1, 1]
                    refute @analyser.analyse_CharacterToken(token).noticeable
                
            describe "Recording character token", ->
                it "adds token.mistake to since_last_mistake", ->
                    mistake = name:'mistake'
                    token = {name:'token', mistake}
                    @analyser.since_last_mistake = [1]
                    @analyser.record_character_token token
                    assert.equals @analyser.since_last_mistake, [1, mistake]
                
                it "doesn't add to since_last_mistake if it is undefined and token isn't a mistake", ->
                    token = name:'token', 'mistake':false
                    @analyser.since_last_mistake = undefined
                    @analyser.record_character_token token
                    refute.defined @analyser.since_last_mistake
                
                it "creates since_last_mistake if it is undefined and token is a mistake", ->
                    token = name:'token', 'mistake':true
                    @analyser.since_last_mistake = undefined
                    @analyser.record_character_token token
                    assert.equals @analyser.since_last_mistake, [true]
            
            describe "planning for character token", ->
                it "uses existing planned if defined", ->
                    planned = [[1, 2], [3, 4]]
                    @analyser.planned = planned
                    stubbed = @stub @analyser, 'plan_string'
                    
                    assert.equals @analyser.plan_for_character_token(name:'token'), [4, 2]
                    refute.called stubbed
                    assert.same @analyser.planned, planned
                    
                it "uses plan_string to create and set planned if planned not already defined", ->
                    planned = [[1, 2], [3, 4]]
                    @analyser.planned = undefined
                    stubbed = @stub(@analyser, 'plan_string').returns planned
                    
                    assert.equals @analyser.plan_for_character_token(name:'token'), [4, 2]
                    assert.called stubbed
                    assert.same @analyser.planned, planned
                
                it "returns the pop of the two things in defined", ->
                    @analyser.planned = [[1, 5], [3, 6]]
                    assert.equals @analyser.plan_for_character_token(name:'token'), [6, 5]
                
                it "sets token to undefined if second list in planned is empty after pop", ->
                    @analyser.token = name:'token'
                    @analyser.planned = [[1], [3]]
                    assert.equals @analyser.plan_for_character_token(name:'token'), [3, 1]
                    refute.defined @analyser.token
                
                it "leaves token if second list in planned isn't empty after pop", ->
                    token = name:'token'
                    @analyser.token = token
                    @analyser.planned = [[1, 2], [3, 4]]
                    assert.equals @analyser.plan_for_character_token(name:'token'), [4, 2]
                    assert.same @analyser.token, token
                    
                it "sets planned to undefined if second list in planned is empty after pop", ->
                    @analyser.planned = [[1], [3]]
                    assert.equals @analyser.plan_for_character_token(name:'token'), [3, 1]
                    refute.defined @analyser.planned
                    
                it "leaves planned if second list in planned isn't empty after pop", ->
                    @analyser.planned = [[1, 7], [3, 8]]
                    assert.equals @analyser.plan_for_character_token(name:'token'), [8, 7]
                    assert.equals @analyser.planned, [[1], [3]]
