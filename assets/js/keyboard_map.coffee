class window.KeyboardMap
    constructor: ->
        nil = @nil = null  
        @layout = [
            [
                ['`', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', nil]
                [nil, 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\\']
                [nil, 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'", nil, nil]
                [nil, 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', nil, nil, nil]
                [nil, nil, nil, ' ', ' ', ' ', ' ', ' ', nil, nil, nil, nil, nil, nil]
            ]
            [
                ['~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', nil]
                [nil, 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '|']
                [nil, 'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', nil, nil]
                [nil, 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', nil, nil, nil]
                [nil, nil, nil, ' ', ' ', ' ', ' ', ' ', nil, nil, nil, nil, nil, nil]
            ]
        ]
        
        @alphabet = []
        @map ?= @create_map()

    create_map: ->
        map = {}
        for lines, typ in @layout
            for line, row in lines
                for char, col in line
                    if char isnt @nil
                        @alphabet.push char
                        map[char] = @similar_for(lines, row, col)
        map
    
    add_line: (lst, line, col) ->
        # left
        unless col == 0
            nxt = line[col - 1]
            lst.push nxt unless nxt is @nil
        
        # center
        nxt = line[col]
        lst.push nxt unless nxt is @nil
        
        # right
        unless col == line.length - 1
            nxt = line[col + 1]
            lst.push nxt unless nxt is @nil

    similar_for: (lines, row, col) ->
        similar = []
        # top
        unless row == 0
            @add_line similar, lines[row - 1], col
        
        # current line
        @add_line similar, lines[row], col
        
        # bottom
        unless row == lines.length - 1
            @add_line similar, lines[row + 1], col
        
        similar

    close_to: (char) ->
        # Return random character close to char on the keyboard
        # Choose from all characters if don't know about char
        set = @map[char] ? @alphabet
        set[Math.ceil((set.length - 1) * Math.random())]
    
    dyslexic_line: (line) ->
        # Map line to array of characters close to those in the line
        if toString.call(line) == '[object String]'
            line = line.split("")
        
        for char in line
            @close_to(char)
