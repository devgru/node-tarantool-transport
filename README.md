# Tarantool [node.js](http://nodejs.org) Transport — low-level [Tarantool](http://tarantool.org) driver.

Transport composes request headers, parses response headers, manages callbacks and incapsulates socket composing response from several data packets.

**Use [Connector](https://github.com/devgru/node-tarantool)** as a high-level driver, or create your own.

## NPM

```shell
npm install tarantool-transport
```
## Notes
There are two ways to instantiate `transport` — `Transport.connect port, host, callback` and `new Transport socket`. First one is preferrable.

Call `transport.request type, body, callback` to send request.
`type` must be unsigned 32-bit integer, any [valid request type](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L46).
`body` must be Buffer (preferrable) or String (empty string is usable, see example below).
`callback` will receive response body as Buffer, maybe empty, never `null` or `undefined`.
**All arguments are obligatory.**

## API and usage

```coffee
Transport = require 'tarantool-transport'

# ping request type
PING = 65280

# create Transport
transport = Transport.connect port, host, ->
    # this callback is called on socket connection
    transport.request PING, '', ->
        # this callback is called on response
        console.log 'got ping response'

# the other way, if you want to prepare socket somehow
# socket = (require 'net').connect port, host, connectedCallback
# transport = new Transport socket
```

# Hacking

## Notes on implementation

Before reading source please note:
- In Tarantool, request and response headers are sequences of unsigned little-endian 32-bit integers.
- Tarantool allows to set `request_id`. Server will just pass this value to `response`, never checking or comparing it. In `transport` we call this field `callback_id` — we pass callbacks and one response calls means one callback here.

## Interaction with Socket

Constructed `transport` sets up `socket` in this way:
- `socket.unref()` to let `node.js` exit if we're not awaiting responses
- `socket.setNoDelay()` to reduce latency (added in 0.2.3)
- `socket.on('data', cb)` to parse and process responses

`transport` does `socket.ref()` on request and `socket.unref()` on last awaited response. Thus, `socket` prevents `node.js` from shutting down until it receives all responses.

This is the most common use case, but you can play with `socket` in any way, at your own risk.

## Inner variables

For those who want to hack Transport — list of inner variables:
- `socket` — `net` socket or Object you passed to constructor
- `remainder` — Buffer, will prepend next data chunk in order to compose responses from several data packets
- `callbacks` — Hash (Object), keys are numeric response ids, values are passed callbacks
- `nextCallbackId` — non-negative Number, incremented on request, when reaches 4294967296 overflows to 0, you can use it to describe request frequency
- `responsesAwaiting` — non-negative Number, incremented on request, decremented on response, stored to know when `ref()` and `unref()` the `socket`

## Bugs and issues
Bug reports and pull requests are welcome.

LICENSE
-------
Tarantool Transport for node.js is published under MIT license.
