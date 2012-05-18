express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'

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
        app.get href, (req, resp) -> resp.render "hacks#{href}", layout:false

# Export app and give it a start function
exports.app = app
app.start = ->
    port = process.env.VMC_APP_PORT or 3000
    app.listen port, -> console.log "Listening on http://localhost:#{port}"
