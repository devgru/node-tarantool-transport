host = '127.0.0.1'
port = 33013

TarantoolTransport = require './'
tt = TarantoolTransport.connect 33013, 'localhost', ->
    echo = (head, body) -> console.log 'ok', head, body
    
    body = new Buffer 17
    body.writeUInt32LE 0, 0 # space
    body.writeUInt32LE 1, 8 # cardinality
    body.writeUInt32LE 0, 4 # flags
    
    body.writeUInt8 4, 12 # field data length
    body.writeUInt32LE Math.floor(4294967295 * Math.random()), 13 # field data
    
    #return
    insert = TarantoolTransport.requestTypes.insert
    tt.request insert, body, ->
    
    body.writeUInt32LE Math.floor(4294967295 * Math.random()), 13 # field data
    body.writeUInt32LE 1, 4 # another flags
    
    tt.request insert, body, ->
    tt.request insert, body, ->
        tt.ping ->
    
        tt.socket.end()
