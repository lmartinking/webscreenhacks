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
            expect(analyser.text).toBe @text
            expect(analyser.actionstream).toBe @actionstream
            expect(analyser.keyboard_map).toBe @keyboard_map
        
        it "starts index at 0", ->
            expect(@analyser.index).toBe 0
        
        it "starts token as undefined", ->
            refute.defined @analyser.token
        
        it "starts since_last_mistake as undefined", ->
            refute.defined @analyser.since_last_mistake
