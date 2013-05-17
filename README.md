Beta version of [Tarantool](http://tarantool.org) transport for [node.js](http://nodejs.org)

Transport deals with low-level protocol tasks:
- composing request headers
- parsing response headers
- callback management
- socket incapsulation
- response composition from several data packets

[Connector](https://github.com/devgru/node-tarantool) uses Transport to compose and parse request and response headers.

**More likely you are looking for [Connector](https://github.com/devgru/node-tarantool), not Transport.**

Transport can be used to create your own implementation of Tarantool-protocol driver.

## NPM

```shell
npm install tarantool-transport
```
## Notes
There are two ways to create `transport` — `Transport.connect port, host, callback` and `new Transport socket`.
First one is preferrable. Transport uses `socket.ref()` and `socket.unref()` when it receives requests and responses. So, `socket` used by `transport` will not wait to receive something if it is not awaiting responses. You don't have to call `end()` on `socket`.

Connected `transport` has one method: `transport.request type, body, callback`.
Type must be unsigned 32-bit integer, any [valid request type](https://github.com/mailru/tarantool/blob/master/doc/box-protocol.txt#L46).
Body must be Buffer (preferrable) or String (empty string is usable, see example above).
Callback will receive Buffer, containing response body.
**All arguments are obligatory.**

## API and usage

```coffee
Transport = require 'tarantool-transport'

# type and body for ping
type = 65280
body = ''
responseCallback = -> console.log 'got ping response'

# when transport connected, use it
connectedCallback = -> transport.request type, body, responseCallback

# create Transport
transport = Transport.connect port, host, connectedCallback
# OR the other way, if you need to do something with socket
transport = new Transport (require 'net').connect port, host, connectedCallback
```

LICENSE
-------
Tarantool Transport for node.js is published under MIT license.
