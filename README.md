# Tarantool [node.js](http://nodejs.org) Transport — low-level [Tarantool](http://tarantool.org) driver.

Transport composes request headers, parses response headers, manages callbacks and incapsulates socket composing response from several data packets.

**Use [Connector](https://github.com/devgru/node-tarantool)** as a high-level driver, or create your own.

## NPM

```shell
npm install tarantool-transport
```
## Notes
There are two ways to instantiate `transport` — `Transport.connect port, host, callback` and `new Transport socket`. First one is preferrable.

Transport does `socket.ref()` on request and `socket.unref()` on last awaited response. Thus, `socket` used by `transport` will not prevent node from shutting down if it is not awaiting responses. You don't have to call `end()` on `socket`.

Connected `transport` will `unref()` the `socket` immediately and await for requests via its only method: `transport.request type, body, callback`.
Type must be unsigned 32-bit integer, any [valid request type](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L46).
Body must be Buffer (preferrable) or String (empty string is usable, see example above).
Callback will receive response body as Buffer, maybe empty.
**All arguments are obligatory.**

## API and usage

```coffee
Transport = require 'tarantool-transport'

# ping request type
PING = 65280
responseCallback = -> console.log 'got ping response'

# when transport connected, use it
connectedCallback = -> transport.request PING, '', responseCallback

# create Transport
transport = Transport.connect port, host, connectedCallback
# OR the other way, if you want to do something with socket
# transport = new Transport (require 'net').connect port, host, connectedCallback
```

## Inner variables

For those who want to hack Transport — list of inner variables:
- `socket` — `net` socket or Object you passed to constructor
- `remainder` — Buffer, will prepend next data chunk in order to compose responses from several data packets
- `callbacks` — Hash (Object), keys are numeric response ids, values are passed callbacks
- `responsesAwaiting` — non-negative Number, incremented on request, decremented on response, stored to know when `ref()` and `unref()` the `socket`

## Bugs and issues
Bug reports and pull requests are welcome.

LICENSE
-------
Tarantool Transport for node.js is published under MIT license.
