host = '127.0.0.1'
port = 33013

Tarantool = require './' 
tt = new Tarantool 'localhost', 33013, ->
    echo = (head, returnCode, body) -> console.log 'ping ok', head, returnCode, body
    
    body = new Buffer(17)
    body.writeUInt32LE 0, 0 # space
    body.writeUInt32LE 1, 4 # flags
    body.writeUInt32LE 1, 8 # cardinality
    
    body.writeUInt8 4, 12 # field data length
    body.writeUInt32LE Math.floor(4294967295 * Math.random()), 13 # field data

    #return
    tt.request Tarantool.requestTypes.insert, body, ->
    body.writeUInt32LE Math.floor(4294967295 * Math.random()), 13 # field data
    tt.request Tarantool.requestTypes.insert, body, ->
    tt.ping ->
