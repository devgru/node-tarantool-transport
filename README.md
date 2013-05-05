Beta version of [Tarantool](http://tarantool.org) transport for [node.js](http://nodejs.org)

Transport deals with:
- tcp connection incapsulation
- composing request headers
- parsing response headers
- callback management
- response composition from several tcp packets **(still untested)**

[Connector] @devgru/node-tarantool uses Transport to compose and parse request and response bodies.
More likely you will want to use Connector, not Transport.

How to use
----------

```coffee
Transport = require 'tarantool-transport'

tarantoolConnection = tc = Transport.connect 33013, 'localhost', ->
    console.log 'connected to local tarantool'
    
    tc.request 65280, '', ->
        console.log 'got ping response'
```

Check src/test.coffee for examples of usage.

API
---

### new Transport (Socket) -> Transport

Creates Transport using Socket, which can be any object, with `write(Buffer or String)`, `end()` and `on(String, Function)` methods.

### Transport.connect (port, host, callback) -> Transport

Creates a network Socket and a new Transport connected to it.

### transport.request (type, body, callback) ->

Sends Tarantool request.
Type must be Integer, any valid request type.
Body must be Buffer (preferrable) or String (empty string is usable, see example above).
Callback will receive Buffer, containing response body.

### transport.end () ->

Calls [`end()`](http://nodejs.org/api/net.html#net_socket_end_data_encoding) on Socket.
