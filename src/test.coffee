host = '127.0.0.1'
port = 33013

Tarantool = require './'
tt = new Tarantool.Transport 'localhost', 33013, ->
    echo = (head, body) -> console.log 'ok', head, body
    
    body = new Buffer(17)
    body.writeUInt32LE 0, 0 # space
    body.writeUInt32LE 1, 8 # cardinality
    body.writeUInt32LE 0, 4 # flags
    
    body.writeUInt8 4, 12 # field data length
    body.writeUInt32LE Math.floor(4294967295 * Math.random()), 13 # field data
    
    #return
    tt.request Tarantool.REQUEST_TYPE.insert, body, ->
    
    body.writeUInt32LE Math.floor(4294967295 * Math.random()), 13 # field data
    body.writeUInt32LE 1, 4 # another flags
    
    tt.request Tarantool.REQUEST_TYPE.insert, body, ->
    tt.request Tarantool.REQUEST_TYPE.insert, body, ->
        tt.ping ->
    
        tt.socket.end()
