Transport = require '../src'

PING = 65280

exports['connect'] = (test) ->
    test.expect 1
    test.doesNotThrow ->
        Transport.connect 33013, 'localhost', ->
            test.done()

exports['ping'] = (test) ->
    test.expect 3
    transport = Transport.connect 33013, 'localhost', ->
        test.doesNotThrow ->
            transport.request PING, '', (response) ->
                test.ok Buffer.isBuffer response
                test.equals response.length, 0
                test.done()
###
exports['pings'] = (test) ->
    transport = Transport.connect 33013, 'localhost', ->
        transport.request PING, '', (-> console.log 'ok' ) for i in [0..100]
        setInterval ( -> test.done()), 500
###
