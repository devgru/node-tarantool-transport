Beta version of [Tarantool](http://tarantool.org) transport for [node.js](http://nodejs.org)

Transport deals with low-level protocol tasks:
- composing request headers
- parsing response headers
- callback management
- socket incapsulation
- response composition from several data packets **(still untested)**

[Connector](https://github.com/devgru/node-tarantool) uses Transport to compose and parse request and response bodies.

**More likely you are looking for [Connector](https://github.com/devgru/node-tarantool), not Transport.**

Transport can be used to create your own implementation of Tarantool-protocol composer or parser.

NPM
---

```shell
npm install tarantool-transport
```

How to use
----------

```coffee
Transport = require 'tarantool-transport'

tarantoolConnection = Transport.connect 33013, 'localhost', ->
    console.log 'connected to local tarantool'
    
    tarantoolConnection.request 65280, '', ->
        console.log 'got ping response'
```

Check src/test.coffee for examples of usage.

API
---

### new Transport (Socket) -> Transport

Creates Transport using Socket, which can be any object, with `write(Buffer or String)`, `ref()`, `unref()` and `on(String, Function)` methods.

### Transport.connect (port, host, callback) -> Transport

Creates a network Socket and a new Transport connected to it.

### transport.request (type, body, callback) ->

Sends Tarantool request.
Type must be Integer, any valid request type.
Body must be Buffer (preferrable) or String (empty string is usable, see example above).
Callback will receive Buffer, containing response body.

LICENSE
-------

Tarantool Transport for node.js is published under MIT license.
