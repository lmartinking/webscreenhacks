if typeof module != "undefined" and typeof require != "undefined"
    require('buster').spec.expose()
else
    buster.spec.expose()
