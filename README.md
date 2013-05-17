# [node.js](http://nodejs.org) Transport for [Tarantool](http://tarantool.org) is a low-level Tarantool driver.

Transport composes request headers, parses response headers, manages callbacks and incapsulates socket composing response from several data packets.

**Use [Connector](https://github.com/devgru/node-tarantool)** as a high-level driver, or create your own.

## NPM

```shell
npm install tarantool-transport
```
## Notes
There are two ways to instantiate `transport` — `Transport.connect port, host, callback` and `new Transport socket`.
First one is preferrable.

Transport calls `socket.ref()` when it receives request and `socket.unref()` when it receives last awaited response. Thus, `socket` used by `transport` will not prevent node from shutting down if it is not awaiting responses. You don't have to call `end()` on `socket`.

Connected `transport` has one method: `transport.request type, body, callback`.
Type must be unsigned 32-bit integer, any [valid request type](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L46).
Body must be Buffer (preferrable) or String (empty string is usable, see example above).
Callback will receive response body as Buffer, maybe empty.
**All arguments are obligatory.**

## API and usage

```coffee
Transport = require 'tarantool-transport'

# type and body for ping
PING = 65280
responseCallback = -> console.log 'got ping response'

# when transport connected, use it
connectedCallback = -> transport.request PING, '', responseCallback

# create Transport
transport = Transport.connect port, host, connectedCallback
# OR the other way, if you need to do something with socket
transport = new Transport (require 'net').connect port, host, connectedCallback
```

LICENSE
-------
Tarantool Transport for node.js is published under MIT license.
