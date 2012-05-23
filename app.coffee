express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
request = require 'request'

# Examples that we provide
examples = [
    {href:'/minimal_clock', title:"Minimal clock"}
    {href:'/typewriting', title:"Dyslexic typewriter"}
    ]

# Setup the server
app = express.createServer()
app.set 'view engine', 'jade'

app.use assets()
app.use("/fonts", express.static(__dirname + '/assets/fonts'))

# Setup the urls
app.get '/', (req, resp) -> resp.render 'index', {examples, layout:false}

for {href} in examples
    do (href) ->
        app.get href, (req, resp) ->
            resp.render "hacks#{href}", layout:false

request = request.defaults {headers: {'User-Agent': 'WebScreenHacks'}}

fetch = (url, resp) ->
    console.log 'fetch: ' + url
    request url, (error, response, body) ->
        unless error
            resp.send body, response.headers, response.statusCode
        else
            resp.send "error", 500

# Simple proxy for ajax requests
app.get '/ajax_proxy', (req, resp) ->
    url = req.query.url
    if url
       fetch url, resp
    else
        resp.send "url parameter missing", 401

# Export app and give it a start function
exports.app = app
app.start = ->
    port = process.env.VMC_APP_PORT or 3000
    app.listen port, -> console.log "Listening on http://localhost:#{port}"
